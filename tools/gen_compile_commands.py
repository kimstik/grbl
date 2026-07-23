#!/usr/bin/env python3
"""gen_compile_commands.py - compile_commands.json for clangd/LSP, no third-party deps.

Grbl's platform Makefiles (grbl/platform/<platform>/Makefile) already know the
exact compiler, flags and -include chain needed to build each translation
unit for a given target. Rather than reverse-engineer that (or depend on
`bear`/`compiledb`, which aren't always available and don't ship in this
repo's toolchain), this script asks `make` itself: it runs the real Makefile
with `-n` (dry run: print the recipe, don't execute it) and `-B` (treat
everything as out of date, so every compile line is emitted even on a build
tree that's already up to date or has no toolchain installed at all - `-n`
never actually invokes the compiler, so this works without arm-none-eabi-gcc/
avr-gcc/riscv64-unknown-elf-gcc present).

It then parses the printed recipe lines for compiler invocations and turns
each one into a compile_commands.json entry, preserving every flag - notably
the `-include gpio.h -include ../common/gpio.h ...` chain that is this
project's "invisible porting" mechanism (see grbl/platform/common/gpio.h) -
verbatim, so clangd sees exactly what the real build sees.

Usage:
    tools/gen_compile_commands.py <platform> [<platform> ...] [options]

Examples:
    tools/gen_compile_commands.py samd21
    tools/gen_compile_commands.py samd21 --board generic
    tools/gen_compile_commands.py stm32f103 stm32h523 sg2002
    tools/gen_compile_commands.py samd21 --build RELEASE
    tools/gen_compile_commands.py samd21 --var TOOLCHAIN_PATH=/opt/gcc-arm/bin

Each <platform> must be a directory name under grbl/platform/ that has its
own Makefile (samd21, stm32f103, stm32h523, sg2002, ...). Passing more than
one platform merges their compile commands into a single
compile_commands.json (later platforms win on files both define, e.g. a
core grbl/*.c file built by two platforms).

Only python3 standard library is used - no bear, no compiledb, no pip
installs required.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

# Recipe lines we care about always contain a literal " -c " (compile-only,
# don't link) token boundary. Everything else (mkdir -p, rm -f, the final
# link step, `make: Entering directory` chatter, etc.) is ignored by this
# cheap substring pre-filter before we bother tokenizing the line.
COMPILE_MARKER = " -c "

# Recognize a compiler token by its basename: plain gcc/clang/cc, or any
# cross-compiler prefix ending in one of those (avr-gcc, arm-none-eabi-gcc,
# riscv64-unknown-elf-gcc, x86_64-linux-gnu-gcc-11, ...).
_COMPILER_SUFFIXES = ("gcc", "g++", "clang", "clang++", "cc", "c++")
_COMPILER_RE = re.compile(
    r"(^|-)(" + "|".join(re.escape(s) for s in _COMPILER_SUFFIXES) + r")(-[0-9][0-9.]*)?$"
)

_ENTER_RE = re.compile(r"^make(?:\[\d+\])?: Entering directory '(?P<dir>.*)'$")
_LEAVE_RE = re.compile(r"^make(?:\[\d+\])?: Leaving directory '(?P<dir>.*)'$")


def is_compiler_token(token: str) -> bool:
    base = os.path.basename(token)
    return bool(_COMPILER_RE.search(base))


def find_repo_root(start: Path) -> Path:
    """Locate the grbl repo root, starting from this script's location."""
    candidate = start.resolve().parent
    for d in (candidate, *candidate.parents):
        if (d / ".git").exists() and (d / "grbl").is_dir():
            return d
    # Fall back to `git rev-parse --show-toplevel` in case the script was
    # copied elsewhere but is still run from inside a checkout.
    try:
        out = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=start.resolve().parent,
            capture_output=True,
            text=True,
            check=True,
        )
        return Path(out.stdout.strip())
    except Exception:
        raise SystemExit("error: could not locate grbl repo root (no .git/grbl found)")


def platform_dir(repo_root: Path, platform: str) -> Path:
    d = repo_root / "grbl" / "platform" / platform
    if (d / "Makefile").is_file():
        return d
    if platform == "atmega328p" and (repo_root / "Makefile").is_file():
        # atmega328p has no grbl/platform/atmega328p/Makefile - it is built
        # from the repo-root Makefile instead. Documented convenience only;
        # every other platform lives under grbl/platform/<platform>/.
        return repo_root
    raise SystemExit(
        f"error: no Makefile found for platform '{platform}' "
        f"(looked in {d}/Makefile)"
    )


def run_make_dry(make_exe: str, mdir: Path, cwd: Path, build: str, board: str | None,
                  extra_vars: list[str]) -> str:
    args = [make_exe, "-C", str(mdir), "-nB", f"BUILD={build}"]
    if board:
        args.append(f"BOARD={board}")
    args.extend(extra_vars)
    proc = subprocess.run(args, cwd=cwd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise SystemExit(
            f"error: '{' '.join(args)}' failed (exit {proc.returncode}); "
            "see make output above"
        )
    return proc.stdout


def parse_compile_lines(make_output: str, default_dir: Path) -> list[dict]:
    entries = []
    dir_stack = [str(default_dir)]
    for raw_line in make_output.splitlines():
        line = raw_line.strip()

        m = _ENTER_RE.match(line)
        if m:
            dir_stack.append(m.group("dir"))
            continue
        m = _LEAVE_RE.match(line)
        if m:
            if len(dir_stack) > 1:
                dir_stack.pop()
            continue

        if COMPILE_MARKER not in raw_line:
            continue

        try:
            tokens = shlex.split(raw_line)
        except ValueError:
            continue  # unbalanced quotes in make chatter we don't understand; skip
        if not tokens or not is_compiler_token(tokens[0]):
            continue
        if "-c" not in tokens:
            continue

        c_idx = tokens.index("-c")
        if c_idx + 1 >= len(tokens):
            continue
        src = tokens[c_idx + 1]

        out_path = None
        if "-o" in tokens:
            o_idx = tokens.index("-o")
            if o_idx + 1 < len(tokens):
                out_path = tokens[o_idx + 1]

        directory = dir_stack[-1]
        abs_src = os.path.normpath(os.path.join(directory, src))
        entry = {
            "directory": directory,
            "file": abs_src,
            "arguments": tokens,
        }
        if out_path:
            entry["output"] = os.path.normpath(os.path.join(directory, out_path))
        entries.append(entry)
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate compile_commands.json from grbl's platform Makefiles "
                     "(stdlib-only, no bear/compiledb).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "platforms", nargs="+",
        help="Platform directory name(s) under grbl/platform (e.g. samd21 stm32f103 "
             "stm32h523 sg2002). 'atmega328p' falls back to the repo-root Makefile.",
    )
    parser.add_argument("--board", help="BOARD make variable (e.g. megarm|generic for samd21)")
    parser.add_argument("--build", default="DEBUG", help="BUILD make variable (default: DEBUG)")
    parser.add_argument(
        "--var", action="append", default=[], metavar="KEY=VALUE",
        help="Extra make variable, repeatable (e.g. --var TOOLCHAIN_PATH=/opt/gcc-arm/bin)",
    )
    parser.add_argument(
        "--output", default=None,
        help="Output path for compile_commands.json (default: <repo_root>/compile_commands.json)",
    )
    parser.add_argument("--make", default="make", help="make executable to invoke (default: make)")
    args = parser.parse_args()

    repo_root = find_repo_root(Path(__file__))
    out_path = Path(args.output) if args.output else repo_root / "compile_commands.json"

    by_file: dict[str, dict] = {}
    total_lines = 0
    for platform in args.platforms:
        mdir = platform_dir(repo_root, platform)
        make_output = run_make_dry(args.make, mdir, repo_root, args.build, args.board, args.var)
        entries = parse_compile_lines(make_output, mdir)
        total_lines += len(entries)
        if not entries:
            sys.stderr.write(
                f"warning: no compile commands parsed for platform '{platform}' - "
                "check that its Makefile prints ' -c ' recipe lines under -nB\n"
            )
        for e in entries:
            by_file[e["file"]] = e  # later platforms win on shared core files

    compdb = list(by_file.values())
    compdb.sort(key=lambda e: e["file"])

    out_path.write_text(json.dumps(compdb, indent=2) + "\n")
    sys.stderr.write(
        f"wrote {len(compdb)} entries ({total_lines} parsed, "
        f"{total_lines - len(compdb)} de-duplicated) to {out_path}\n"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
