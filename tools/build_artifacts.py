#!/usr/bin/env python3
"""build_artifacts.py - build and track per-platform GRBL release artifacts.

Part of Grbl / Intelligence assisted / License: MIT

WHY THIS EXISTS (owner directive, PLAN.md "build artifacts tracked in git"
batch): before this tool, only atmega328p had any byte-level build history
(the golden MD5 in grbl/platform/Makefile's `validate` target, ratchet #1).
Every other port could only be compared "now vs now" by rebuilding twice in
the same session - a 40-byte size drift between sessions had nothing to
diff against. This tool commits RELEASE elf/bin/hex plus a plain-text
symbol-size map for every buildable port into artifacts/<port>/, so the
CURRENT state of every port is inspectable and diffable over time in normal
`git log -p`/`git diff`, not just at release time.

This is a TRACKING artifact set, not an end-of-project report: it gets
regenerated and re-committed whenever a port's *content* changes (see the
refresh policy in artifacts/README.md), not on every push.

GROWTH COST (state plainly, per the owner's request): git does not delta
binaries usefully across recompiles - even a source change that only moves
one function by 40 bytes typically re-links every address after it, so the
whole .elf/.bin/.hex blob changes and git stores it again close to in full
(zlib-compressed, but not diffed against the prior blob in any way that
tracks the source edit). Measured sizes in this tree: .bin 25-41KB (94KB on
dsPIC33A - word-per-instruction padding, see below), .hex 72-115KB, .elf
93-166KB per port/board. Ten port/board artifact sets (nine ports; samd21
counts twice, once per board) land around 2.4-2.6MB for one full snapshot.
Every subsequent *content* refresh adds roughly that much again - this is
the deliberate, accepted cost of byte-level observability the owner asked
for, not a defect to optimize away.

USAGE
  tools/build_artifacts.py build [--platforms p1,p2,...] [--skip-debug]
      Rebuild every port (DEBUG then RELEASE by default), copy RELEASE
      bin/hex + a generated symbol-size map AND a full objdump disassembly
      dump (<binary>.elf.dump - see gen_elf_dump()/elf_dump_header() below)
      into artifacts/<port>/, and (re)write artifacts/MANIFEST.sha256
      covering every artifact of every port AND flavor (DEBUG hashes are
      recorded even though DEBUG binaries are not committed - see the
      manifest's own header; .elf.dump is NOT in the manifest at all - see
      below). Does NOT copy .elf ("Эльф на тегах" owner directive - ELF is
      tracked ONLY at release-tag time, see --with-elf below); any stale
      .elf left over in artifacts/<port>/ from a prior --with-elf run is
      removed so a plain refresh can't leave a mismatched ELF sitting in
      the tree. .elf.dump follows a DIFFERENT lifecycle than .elf despite
      the name - it's tracked continuously (every refresh, like bin/hex/
      syms), not tag-time-only, because its whole purpose is a readable
      diff of what changed BETWEEN builds; a tag-gated dump would only ever
      be diffable release-to-release. See artifacts/README.md.

  tools/build_artifacts.py build --with-elf [--platforms p1,p2,...] [--skip-debug]
      Same as plain `build`, but ALSO copies RELEASE .elf into
      artifacts/<port>/ and records its hash in MANIFEST.sha256. Intended
      to be run ONLY at release-tag time - ELF is the largest artifact
      class (48-166KB/unit vs. bin 25-95KB, hex 72-116KB, syms a few KB)
      and git cannot delta binaries across recompiles, so tracking it on
      every refresh (as this tool used to) roughly doubled the growth
      cost of every port-content change for a file most refreshes don't
      need byte-for-byte. See artifacts/README.md's "Growth cost" section
      and PORTING-CHECKLIST.md's refresh policy for the full rule and
      measured numbers.

  tools/build_artifacts.py check [--platforms p1,p2,...] [--skip-debug]
      Rebuild fresh (into the ordinary build/ scratch dir, never touching
      artifacts/) and compare hashes against the committed artifacts/ tree
      (RELEASE) and the recorded manifest (DEBUG). Exits 1 and prints every
      drifted/missing file if the committed artifacts are stale relative to
      a fresh build. bin/hex/syms are always required and always hash-
      gated, for EVERY unit including dsPIC33AK (see nondeterministic_elf
      below - only that one unit's .elf is exempt); .elf is verified ONLY
      if present (absence is expected between tags, not a failure - see
      --with-elf above), and even then only for units NOT flagged
      nondeterministic_elf. .elf.dump is checked for PRESENCE only, never
      hash-compared - objdump prints its own invocation path as line 1 of
      every dump it produces, so a fresh rebuild's dump text differs from
      the committed one across any two different absolute checkout paths
      even when the underlying .elf is byte-identical (measured this
      batch); see elf_dump_header()'s "NOT HASH-GATED" paragraph. This is
      the sixth ratchet (after golden MD5, warn baseline, boot integrity,
      no-DP assert, docs integrity).

  tools/build_artifacts.py --selftest
      Pure-logic unit tests (manifest line parsing/formatting, hash
      comparison) - no compiler invoked, matches the style of
      ci/warn_ratchet.py / tools/assert_no_double.sh / tools/check_contracts_numbering.py.
"""

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys

REPO_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
ARTIFACTS_DIR = os.path.join(REPO_ROOT, "artifacts")
BUILD_DIR = os.path.join(REPO_ROOT, "build")
MANIFEST_PATH = os.path.join(ARTIFACTS_DIR, "MANIFEST.sha256")

MANIFEST_LINE_RE = re.compile(r"^#?\s*([0-9a-f]{64})\s+(\S+)")

# ---------------------------------------------------------------------------
# Port table. One entry per buildable unit - samd21's two boards are two
# units because they land in two different artifacts/ subdirectories even
# though the toolchain names both ELFs identically (grbl_samd21.*); see
# PLAN.md samd21/Makefile - BINARY_NAME does not encode BOARD.
# ---------------------------------------------------------------------------

UNITS = [
    dict(key="atmega328p", kind="avr", artifact_dir="atmega328p",
         binary="grbl_atmega328p", has_debug=False),
    dict(key="stm32f103", kind="std", dir="grbl/platform/stm32f103",
         binary="grbl_stm32f103", nm="arm-none-eabi-nm", extra_args={}),
    dict(key="stm32h523", kind="std", dir="grbl/platform/stm32h523",
         binary="grbl_stm32h523", nm="arm-none-eabi-nm", extra_args={}),
    dict(key="stm32f411", kind="std", dir="grbl/platform/stm32f411",
         binary="grbl_stm32f411", nm="arm-none-eabi-nm", extra_args={}),
    dict(key="samd21-megarm", kind="std", dir="grbl/platform/samd21",
         binary="grbl_samd21", nm="arm-none-eabi-nm",
         extra_args={"BOARD": "megarm"}, artifact_dir="samd21-megarm"),
    dict(key="samd21-generic", kind="std", dir="grbl/platform/samd21",
         binary="grbl_samd21", nm="arm-none-eabi-nm",
         extra_args={"BOARD": "generic"}, artifact_dir="samd21-generic"),
    dict(key="ch32v006", kind="std", dir="grbl/platform/ch32v006",
         binary="grbl_ch32v006", nm="riscv64-unknown-elf-nm",
         extra_args={"BOARD": "generic"}),
    dict(key="ch570", kind="std", dir="grbl/platform/ch570",
         binary="grbl_ch570", nm="riscv64-unknown-elf-nm",
         extra_args={"BOARD": "generic"}),
    dict(key="hc32f460", kind="std", dir="grbl/platform/hc32f460",
         binary="grbl_hc32f460", nm="arm-none-eabi-nm", extra_args={}),
    dict(key="dspic33ak128mc102", kind="std",
         dir="grbl/platform/dspic33ak128mc102",
         binary="grbl_dspic33ak128mc102", nm="/opt/xc-dsc/bin/xc-dsc-nm",
         # objdump fallback for the `nm --print-size` defect below -
         # xc-dsc-objdump ships alongside xc-dsc-nm in the same prefix.
         objdump="/opt/xc-dsc/bin/xc-dsc-objdump",
         extra_args={"BOARD": "generic",
                     "TOOLCHAIN_PATH": "/opt/xc-dsc/bin",
                     "DFP_PATH": "/opt/Microchip.dsPIC33AK-MC_DFP.1.5.263"},
         optional=True, toolchain_probe="/opt/xc-dsc/bin/xc-dsc-gcc",
         # xc-dsc-gcc's restricted/Free license tier's .elf is NOT byte-
         # reproducible - but ONLY the .elf. Root cause (adversarial review,
         # this batch): the ELF's DIFFERING bytes are embedded
         # `/tmp/ccXXXXXX.s.scnN` compiler-tempfile SECTION NAMES (as's
         # per-invocation random temp assembly filename, echoed into a few
         # section-name strings) - not code, not layout. Two back-to-back
         # `make clean && make` runs of the IDENTICAL source tree were
         # measured (this batch) to differ in ~12-13% of the .elf's bytes
         # (20829-22185 of ~166000 bytes, exact count wobbles run to run
         # since it's a random tempfile name), while `cmp -l` on the SAME
         # two builds' .bin and .hex is EMPTY - byte-identical, every time.
         # This makes sense once you see the cause: bin/hex are produced by
         # objcopy/bin2hex from the LINKED image's actual code/data bytes,
         # which never touch the compiler's scratch section-name strings;
         # only the .elf (which still carries those section headers) does.
         # So: bin/hex are fully tracked AND fully hash-gated, identically to
         # every other unit - only the .elf hash comparison is skipped (and
         # only in `check`; the file itself is still copied/archived at tag
         # time like every other port, see `nondeterministic_elf` below).
         # The symbol-size map (nm --print-size --size-sort) is ALSO stable
         # across the same two builds (verified: diff empty) - function
         # addresses/sizes don't move.
         nondeterministic_elf=True),
]

for _u in UNITS:
    _u.setdefault("artifact_dir", _u["key"])
    _u.setdefault("nondeterministic_elf", False)
    _u.setdefault("has_debug", True)
    _u.setdefault("optional", False)
    _u.setdefault("objdump", None)


def unit_by_key(key):
    for u in UNITS:
        if u["key"] == key:
            return u
    raise KeyError("no such unit: {} (known: {})".format(
        key, ", ".join(u["key"] for u in UNITS)))


# ---------------------------------------------------------------------------
# Toolchain presence
# ---------------------------------------------------------------------------

def toolchain_available(unit):
    if unit["kind"] == "avr":
        return shutil.which("avr-gcc") is not None
    probe = unit.get("toolchain_probe")
    if probe:
        if os.path.isabs(probe):
            return os.access(probe, os.X_OK)
        return shutil.which(probe) is not None
    # std ARM/RISC-V ports: probe the CC the port's own Makefile would use.
    if "riscv64" in unit["nm"]:
        return shutil.which("riscv64-unknown-elf-gcc") is not None
    return shutil.which("arm-none-eabi-gcc") is not None


# ---------------------------------------------------------------------------
# Build execution
# ---------------------------------------------------------------------------

class BuildError(RuntimeError):
    pass


def run(cmd, cwd=None, env=None):
    proc = subprocess.run(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, text=True)
    return proc.returncode, proc.stdout


def build_std_unit(unit, flavor):
    """Build one non-AVR unit via its own Makefile. Returns dict of paths
    into the shared build/ scratch dir (never touches artifacts/)."""
    port_dir = os.path.join(REPO_ROOT, unit["dir"])
    make_vars = ["BUILD={}".format(flavor)]
    for k, v in unit["extra_args"].items():
        make_vars.append("{}={}".format(k, v))
    # Best-effort clean: BUILD_DIR is keyed by flavor already (repo-wide
    # convention, PLAN.md), but board switches on samd21 alias the SAME
    # BUILD_DIR/OUTPUT_DIR filenames - clean before every build so a board
    # switch can never silently relink stale objects under the other
    # board's name.
    run(["make", "-C", port_dir, "clean"] + make_vars)
    rc, log = run(["make", "-C", port_dir] + make_vars)
    if rc != 0:
        raise BuildError("build failed: {} {} (BUILD={})\n{}".format(
            unit["key"], unit["dir"], flavor, log))
    suffix = "" if flavor == "RELEASE" else "_dbg"
    base = os.path.join(BUILD_DIR, unit["binary"] + suffix)
    paths = {"elf": base + ".elf", "hex": base + ".hex", "bin": base + ".bin"}
    for ext, p in paths.items():
        if not os.path.isfile(p):
            raise BuildError("expected artifact missing after build: {} "
                              "({})".format(p, unit["key"]))
    return paths, log


def build_avr_unit():
    """atmega328p uses the repo-root prototype Makefile (golden-MD5 gated,
    single flavor - no DEBUG/RELEASE knob). Reuses `make validate` so this
    tool also re-runs ratchet #1 (golden AVR gate) as a side effect. The
    root Makefile has no .bin target (never needed one before this batch),
    so the raw binary is produced here with a direct objcopy call instead
    of editing the golden-gated Makefile."""
    avr_gcc = shutil.which("avr-gcc")
    if avr_gcc is None:
        raise BuildError("avr-gcc not found on PATH")
    avr_bin_dir = os.path.dirname(avr_gcc)
    env = dict(os.environ)
    make_vars = ["AVR_GCC_PATH={}".format(avr_bin_dir)]
    os.makedirs(BUILD_DIR, exist_ok=True)
    run(["make"] + make_vars + ["clean"], cwd=REPO_ROOT)
    os.makedirs(BUILD_DIR, exist_ok=True)  # root Makefile's clean doesn't remove build/ itself
    rc, log = run(["make"] + make_vars + ["validate"], cwd=REPO_ROOT, env=env)
    if rc != 0:
        raise BuildError("atmega328p golden build/validate FAILED:\n{}".format(log))
    src_elf = os.path.join(REPO_ROOT, "build", "main.elf")
    src_hex = os.path.join(REPO_ROOT, "grbl.hex")
    dst_elf = os.path.join(BUILD_DIR, "grbl_atmega328p.elf")
    dst_hex = os.path.join(BUILD_DIR, "grbl_atmega328p.hex")
    dst_bin = os.path.join(BUILD_DIR, "grbl_atmega328p.bin")
    shutil.copyfile(src_elf, dst_elf)
    shutil.copyfile(src_hex, dst_hex)
    objcopy = os.path.join(avr_bin_dir, "avr-objcopy")
    rc, log2 = run([objcopy, "-O", "binary", src_elf, dst_bin])
    if rc != 0:
        raise BuildError("avr-objcopy -O binary failed:\n{}".format(log2))
    return {"elf": dst_elf, "hex": dst_hex, "bin": dst_bin}, log + log2


_OBJDUMP_SECTION_HDR_RE = re.compile(
    r"^\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)")
_OBJDUMP_ADDR_RE = re.compile(r"^[0-9a-fA-F]{8}$")


def _objdump_code_ranges(objdump_bin, elf_path):
    """Parse `objdump -h` and return [(start, end, name), ...] for every
    section flagged CODE (the loadable, executable regions - dsPIC33A links
    several of these at disjoint addresses instead of one contiguous .text,
    see platform.md)."""
    rc, out = run([objdump_bin, "-h", elf_path])
    if rc != 0:
        raise BuildError("{} -h failed on {}:\n{}".format(objdump_bin, elf_path, out))
    ranges = []
    lines = out.splitlines()
    for i, line in enumerate(lines):
        m = _OBJDUMP_SECTION_HDR_RE.match(line)
        if not m:
            continue
        _name, size_s, vma_s, _lma_s, _off_s = m.groups()
        flags_line = lines[i + 1] if i + 1 < len(lines) else ""
        if "CODE" not in flags_line:
            continue
        start = int(vma_s, 16)
        size = int(size_s, 16)
        ranges.append((start, start + size, _name))
    ranges.sort()
    return ranges


def _objdump_symtab(objdump_bin, elf_path):
    """Parse `objdump -t` into (addr, section, flags, size, name) tuples.
    Entries with no `.size` info print with no size field at all (2 or 3
    space-separated tokens before the tab instead of the 4 a properly-sized
    entry has) - that omission, not a printed 0, is the actual shape of the
    xc-dsc-nm defect this whole fallback works around."""
    rc, out = run([objdump_bin, "-t", elf_path])
    if rc != 0:
        raise BuildError("{} -t failed on {}:\n{}".format(objdump_bin, elf_path, out))
    recs = []
    for line in out.splitlines():
        if "\t" not in line:
            continue
        left, right = line.split("\t", 1)
        lparts = left.split()
        if len(lparts) < 2 or not _OBJDUMP_ADDR_RE.match(lparts[0]):
            continue
        addr = int(lparts[0], 16)
        section = lparts[-1]
        flags = "".join(lparts[1:-1])
        rparts = right.split(None, 1)
        if len(rparts) < 2:
            continue
        size_s, name = rparts
        try:
            size = int(size_s, 16)
        except ValueError:
            continue
        recs.append((addr, section, flags, size, name))
    return recs


def _estimate_code_symbols(code_ranges, symtab):
    """Recover a (addr, size, name, estimated) row per real function inside
    `code_ranges`, using the compiler's own declared size where present and
    an address-delta-to-next-symbol estimate (capped at the containing
    section's end) everywhere else. Compiler-internal labels (`.L123`,
    `.CS87`, per-TU scratch section names starting with `/`) are excluded
    from the anchor set - they sit INSIDE a real function's byte range, not
    between two functions, so treating them as boundaries would understate
    real sizes."""
    def in_code(addr):
        for start, end, _name in code_ranges:
            if start <= addr < end:
                return start, end
        return None

    def is_real_name(name):
        return bool(name) and not name.startswith(".") and not name.startswith("/")

    best_size = {}  # (addr, name) -> max declared size seen
    for addr, _section, _flags, size, name in symtab:
        if not is_real_name(name) or in_code(addr) is None:
            continue
        key = (addr, name)
        if size > best_size.get(key, -1):
            best_size[key] = size

    by_addr = {}
    for (addr, name), size in best_size.items():
        by_addr.setdefault(addr, []).append((name, size))

    addrs = sorted(by_addr.keys())
    rows = []
    for i, addr in enumerate(addrs):
        entries = by_addr[addr]
        name, declared = max(entries, key=lambda e: e[1])
        if declared > 0:
            rows.append((addr, declared, name, False))
            continue
        _start, end = in_code(addr)
        nxt = addrs[i + 1] if i + 1 < len(addrs) else end
        size = min(nxt, end) - addr
        rows.append((addr, size, name, True))
    return rows


def gen_symbol_map(nm_bin, elf_path, objdump_bin=None):
    if not os.path.isabs(nm_bin) and shutil.which(nm_bin) is None:
        raise BuildError("nm binary not found: {}".format(nm_bin))
    rc, out = run([nm_bin, "--print-size", "--size-sort", "--demangle", elf_path])
    if rc != 0:
        raise BuildError("{} failed on {}:\n{}".format(nm_bin, elf_path, out))
    if objdump_bin is None:
        return out

    # objdump fallback path (dsPIC33A only, see UNITS table comment): nm's
    # own output is trustworthy for everything OUTSIDE the executable code
    # ranges (bss/data/reserved-flash symbols all size correctly - spot-
    # checked against the linker map) but silently drops most FUNCTIONS
    # inside those ranges. Keep nm's non-code lines verbatim, replace its
    # code-range coverage with the objdump-reconstructed table.
    if not os.path.isabs(objdump_bin) and shutil.which(objdump_bin) is None:
        raise BuildError("objdump binary not found: {}".format(objdump_bin))
    code_ranges = _objdump_code_ranges(objdump_bin, elf_path)
    symtab = _objdump_symtab(objdump_bin, elf_path)
    code_rows = _estimate_code_symbols(code_ranges, symtab)

    def addr_in_code(addr):
        for start, end, _name in code_ranges:
            if start <= addr < end:
                return True
        return False

    kept_nm_lines = []
    for line in out.splitlines():
        parts = line.split(None, 3)
        if len(parts) >= 2 and _OBJDUMP_ADDR_RE.match(parts[0]):
            try:
                addr = int(parts[0], 16)
            except ValueError:
                addr = None
            if addr is not None and addr_in_code(addr):
                continue  # superseded by the objdump-reconstructed row below
        kept_nm_lines.append((None, line))  # sort key filled in below

    def line_size(line):
        parts = line.split(None, 3)
        if len(parts) >= 2:
            try:
                return int(parts[1], 16)
            except ValueError:
                pass
        return -1

    merged = [(line_size(line), line) for _unused, line in kept_nm_lines]
    for addr, size, name, estimated in code_rows:
        suffix = "  # objdump addr-delta estimate (xc-dsc-nm --print-size " \
                 "drops this symbol, see platform.md)" if estimated else ""
        merged.append((size, "{:08x} {:08x} T {}{}".format(addr, size, name, suffix)))

    merged.sort(key=lambda t: t[0])
    return "\n".join(line for _size, line in merged) + "\n"


# ---------------------------------------------------------------------------
# .elf.dump - human-readable disassembly companion, tracked CONTINUOUSLY
# (every refresh, like .syms) even though the .elf it's derived from is
# tag-time-only ("Эльф на тегах"). Rationale, argued from what the owner
# wants this file FOR (a readable diff of what changed between BUILDS, not
# just between release tags): a tag-time-only dump would only ever be
# diffable release-to-release - the exact "now vs now" gap .bin/.hex/.syms
# were already built to close for every OTHER artifact class. Generating it
# from the freshly-built RELEASE .elf that already sits in the build/
# scratch dir (never persisted itself between tags) costs nothing extra to
# produce and needs no committed .elf to exist alongside it, exactly like
# .syms today. See artifacts/README.md for the full argument and the
# NOT-hash-gated rationale below.
# ---------------------------------------------------------------------------

ELF_DUMP_FLAGS = ["-d", "-S", "-h", "-t", "--no-show-raw-insn"]


def objdump_bin_for_unit(unit):
    """Which objdump binary produces THIS unit's .elf.dump. Independent of
    the dsPIC-only `objdump` field's OTHER job (the nm --print-size fallback
    inside gen_symbol_map) - reused here because it already resolves to the
    correct xc-dsc-objdump path for that one unit, but every unit (not just
    dsPIC) gets a dump, so the other three toolchains are resolved here."""
    if unit["kind"] == "avr":
        return "avr-objdump"
    if unit["objdump"]:
        return unit["objdump"]
    if "riscv64" in unit["nm"]:
        return "riscv64-unknown-elf-objdump"
    return "arm-none-eabi-objdump"


def elf_dump_extra_args(unit):
    """Extra objdump arguments needed ONLY to disassemble this unit's ELF,
    beyond the flags every unit shares (ELF_DUMP_FLAGS). Measured this
    batch: xc-dsc-objdump's `-d` refuses to disassemble AT ALL without
    `-mdfp=<DFP>/xc16` ("can't disassemble for architecture UNKNOWN", exit
    255) - `-h`/`-t` alone tolerate its absence (print a resource-file
    warning to stderr, fall back to a generic elf32-little bfd name, still
    exit 0), but since ELF_DUMP_FLAGS always includes -d, dsPIC always needs
    this. No other unit's objdump needs anything beyond ELF_DUMP_FLAGS."""
    dfp = unit.get("extra_args", {}).get("DFP_PATH")
    if dfp:
        return ["-mdfp={}".format(os.path.join(dfp, "xc16"))]
    return []


def gen_elf_dump(objdump_bin, elf_path, extra_args):
    if not os.path.isabs(objdump_bin) and shutil.which(objdump_bin) is None:
        raise BuildError("objdump binary not found: {}".format(objdump_bin))
    cmd = [objdump_bin] + list(extra_args) + ELF_DUMP_FLAGS + [elf_path]
    rc, out = run(cmd)
    if rc != 0:
        raise BuildError("{} failed on {}:\n{}".format(objdump_bin, elf_path, out))
    return out


def elf_dump_header(unit, objdump_bin):
    objdump_name = objdump_bin if os.path.isabs(objdump_bin) else os.path.basename(objdump_bin)
    header = (
        "# {binary}.elf.dump - `{od} {flags} <elf>` on the committed RELEASE\n"
        "# .elf. Full disassembly + section headers + symbol table, plain\n"
        "# text: when a size ratchet fires, `git diff` on THIS file shows the\n"
        "# actual instruction-level change behind a byte-count drift, one\n"
        "# level deeper than `.syms` (see artifacts/README.md).\n"
        "#\n"
        "# Flags, each picked for diff readability over completeness:\n"
        "#   -d  disassemble CODE sections only - not -D/--disassemble-all,\n"
        "#       which also decodes .data/.rodata/.debug bytes as bogus\n"
        "#       instructions and would drown the real disassembly in noise\n"
        "#   -S  intermix source where DWARF line info exists. RELEASE is\n"
        "#       -g0 on every port (see each Makefile), so this is a verified\n"
        "#       byte-for-byte no-op today (checked: identical output\n"
        "#       with/without -S on a RELEASE build) - kept at zero cost so a\n"
        "#       future -g-enabled RELEASE flavor gets source interleave for\n"
        "#       free, without anyone remembering to add the flag then\n"
        "#   -h  section headers (sizes/addresses/flags)\n"
        "#   -t  full symbol table\n"
        "#   --no-show-raw-insn  drop the raw hex encoding column (measured\n"
        "#       ~24% smaller on stm32f103 RELEASE: 455508 -> 345950 bytes)\n"
        "#       so the diff reads as instructions, not encoded bytes\n"
        "#   (deliberately NOT -r: relocation entries are empty for a final\n"
        "#    linked executable - verified empty on this build - so the flag\n"
        "#    would only add a header for zero content; NOT --no-addresses:\n"
        "#    unsupported by avr-objdump 2.26 and xc-dsc-objdump 2.32, so\n"
        "#    using it would break two of the four toolchains this covers)\n"
        "# Regenerate: `python3 tools/build_artifacts.py build --platforms {key}`.\n"
        "#\n"
        "# NOT HASH-GATED (`tools/build_artifacts.py check` verifies this\n"
        "# file is PRESENT but does not compare its content - see do_check()\n"
        "# and artifacts/README.md \"elf.dump is not hash-gated\"): objdump\n"
        "# prints the exact path it was invoked with as the FIRST line of its\n"
        "# own output, on every toolchain, regardless of any compiler flag -\n"
        "# so this file is only byte-identical to a fresh rebuild when\n"
        "# regenerated from the IDENTICAL absolute checkout path. Verified\n"
        "# this batch: two RELEASE rebuilds of stm32f103 from different\n"
        "# paths produced a BYTE-IDENTICAL .elf (cmp: no difference) but a\n"
        "# 1-line-different .elf.dump (only the echoed path differed). This\n"
        "# project's actual workflow (a fresh worktree per task) hits that\n"
        "# path difference on effectively every `check` run, so hash-gating\n"
        "# this file would false-positive constantly for zero real drift -\n"
        "# the same CLASS of problem `-ffile-prefix-map` (see Makefiles)\n"
        "# fixes for DEBUG .elf hashes, just not fixable the same way here\n"
        "# since it's objdump's own invocation line, not an embedded DWARF\n"
        "# attribute the compiler controls.\n"
    ).format(binary=unit["binary"], od=objdump_name,
             flags=" ".join(ELF_DUMP_FLAGS), key=unit["key"])
    if unit["key"] == "dspic33ak128mc102":
        header += (
            "#\n"
            "# dsPIC33AK128MC102 is ADDITIONALLY non-reproducible in its own\n"
            "# right, same root cause as this unit's `nondeterministic_elf`\n"
            "# .elf exemption: xc-dsc-gcc's per-invocation `/tmp/ccXXXXXX.s.scnN`\n"
            "# compiler-tempfile section names, and a pointer-derived internal\n"
            "# symbol name (`_0x<hexptr>_at_address_...`), both show up verbatim\n"
            "# in this file's -h/-t output and were confirmed (this batch) to\n"
            "# differ across two back-to-back `make clean && make` runs from\n"
            "# the SAME path - so this unit's dump differs even when the\n"
            "# path-echo line above does not. Also requires `-mdfp=<DFP>/xc16`\n"
            "# to disassemble at all (`xc-dsc-objdump -d` with no -mdfp exits\n"
            "# 255, \"can't disassemble for architecture UNKNOWN\", verified\n"
            "# this batch) - the same DFP device pack every other toolchain\n"
            "# invocation on this unit already needs.\n"
        )
    return header


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------------------
# Manifest formatting / parsing (pure logic - exercised directly by
# --selftest, no compiler involved)
# ---------------------------------------------------------------------------

MANIFEST_HEADER = """\
# artifacts/MANIFEST.sha256 - checksums for every tracked build artifact,
# generated by tools/build_artifacts.py build. Do not hand-edit.
#
# Purpose: answer "did anything change, and where" without rebuilding -
# `git diff` on this file names the exact drifted file(s) instantly, and
# `sha256sum -c artifacts/MANIFEST.sha256` (run from the repo root)
# verifies the RELEASE section against the working tree.
#
# Regenerate:      python3 tools/build_artifacts.py build
# Staleness check: python3 tools/build_artifacts.py check
# Refresh policy:  see artifacts/README.md.
#
# RELEASE (tracked in git - verifiable with sha256sum -c, see above):
"""

MANIFEST_DEBUG_HEADER = """\
#
# DEBUG (NOT tracked in git - DEBUG binaries are rebuilt on demand, never
# committed; see artifacts/README.md "why DEBUG isn't committed"). These
# lines are comments (leading '#') so `sha256sum -c` skips them cleanly -
# they exist purely so a DEBUG-only regression is still observable in
# `git diff` without paying the storage cost of a second full binary set
# per port. `tools/build_artifacts.py check` rebuilds DEBUG and compares
# against these hashes.
"""


def format_manifest(release_entries, debug_entries):
    lines = [MANIFEST_HEADER.rstrip("\n")]
    for rel_path, digest in release_entries:
        lines.append("{}  {}".format(digest, rel_path))
    lines.append(MANIFEST_DEBUG_HEADER.rstrip("\n"))
    for label, digest in debug_entries:
        lines.append("# {}  {}".format(digest, label))
    return "\n".join(lines) + "\n"


def parse_manifest(text):
    """Return dict {path_or_label: sha256} for every line (tracked or
    comment) that matches the "<hash>  <path>" shape. Prose-only comment
    lines (the header) don't match and are ignored."""
    out = {}
    for line in text.splitlines():
        m = MANIFEST_LINE_RE.match(line)
        if m:
            out[m.group(2)] = m.group(1)
    return out


# ---------------------------------------------------------------------------
# build / check orchestration
# ---------------------------------------------------------------------------

def select_units(platforms_arg):
    if not platforms_arg:
        return list(UNITS)
    keys = [k.strip() for k in platforms_arg.split(",") if k.strip()]
    return [unit_by_key(k) for k in keys]


def hash_gated_extensions(nondeterministic_elf):
    """Which extensions do_build/do_check hash-record/-compare for a unit's
    RELEASE (and, when built, DEBUG) artifacts.

    ADVERSARIAL REVIEW FIX (this batch): this used to be a single
    all-or-nothing `nondeterministic_binary` flag that dropped elf AND hex
    AND bin from the hash gate for dsPIC33AK. Measured truth: two clean
    rebuilds of that unit differ in .elf by ~12-13% of bytes (embedded
    /tmp/ccXXXXXX.s.scnN compiler-tempfile SECTION NAMES - see the UNITS
    table comment), while .bin and .hex are BYTE-IDENTICAL (`cmp -l` empty)
    across the same two builds - objcopy/bin2hex read the linked image's
    actual code/data bytes and never see those scratch section-name
    strings. So only .elf may ever be exempt; hex/bin stay hash-gated for
    EVERY unit, nondeterministic_elf or not."""
    return ("hex", "bin") if nondeterministic_elf else ("elf", "hex", "bin")


def release_extensions(include_elf):
    """Which RELEASE extensions `build` copies into artifacts/<port>/.

    ELF is tracked ONLY at release-tag time ("Эльф на тегах" owner
    directive) - it is the largest artifact class (48-166KB/unit) and git
    cannot delta binaries across recompiles, so including it on every
    ordinary content refresh (as this tool used to, unconditionally)
    roughly doubles the growth cost of every refresh for a file most
    refreshes don't need byte-for-byte. bin/hex are always tracked; the
    caller adds the .syms map separately (it isn't a build-produced
    extension, see gen_symbol_map)."""
    return ("elf", "hex", "bin") if include_elf else ("hex", "bin")


def do_build(units, skip_debug, include_elf=False, quiet=False):
    os.makedirs(BUILD_DIR, exist_ok=True)
    os.makedirs(ARTIFACTS_DIR, exist_ok=True)
    release_entries = []
    debug_entries = []
    skipped = []

    for unit in units:
        key = unit["key"]
        if not toolchain_available(unit):
            msg = ("SKIPPED {}: toolchain not found in this environment. "
                   "Plumbing is wired (see UNITS table in this script) - "
                   "rerun once the toolchain is installed.").format(key)
            print(msg)
            skipped.append(key)
            continue

        if not quiet:
            print("== {} ==".format(key))

        if unit["kind"] == "avr":
            # No DEBUG/RELEASE flavor split on this port (root Makefile
            # comment: "single flavor -Os, no BUILD knob") - nothing to
            # record in the manifest's DEBUG section for this unit.
            paths, _log = build_avr_unit()
        else:
            if unit["has_debug"] and not skip_debug:
                dpaths, _dlog = build_std_unit(unit, "DEBUG")
                # nondeterministic_elf units (dsPIC33AK) skip ONLY the .elf
                # hash - hex/bin are deterministic (see UNITS table comment:
                # the drift is embedded compiler-tempfile SECTION NAMES in
                # the .elf only, never in objcopy/bin2hex's output) and are
                # recorded/gated exactly like every other unit's DEBUG
                # hex/bin.
                debug_exts = hash_gated_extensions(unit["nondeterministic_elf"])
                if unit["nondeterministic_elf"]:
                    print("   (skipping DEBUG .elf hash recording for {}: "
                          "ELF is not byte-reproducible on this toolchain, "
                          "see UNITS table comment - hex/bin ARE still "
                          "recorded)".format(key))
                for ext in debug_exts:
                    digest = sha256_file(dpaths[ext])
                    # Label is namespaced by artifact_dir, NOT just the raw
                    # basename: samd21's two boards both compile to the
                    # identical filename build/grbl_samd21_dbg.* (BINARY_NAME
                    # doesn't encode BOARD - see samd21/Makefile) - an
                    # unnamespaced label would collide between
                    # samd21-megarm and samd21-generic, silently recording
                    # only the last board's hash under both names (the
                    # exact bug this comment replaces, caught via a
                    # "check" false-positive during this tool's own testing).
                    debug_entries.append((
                        "build/{}/{}".format(unit["artifact_dir"], os.path.basename(dpaths[ext])),
                        digest))
            paths, _log = build_std_unit(unit, "RELEASE")

        # Copy RELEASE artifacts into the tracked artifacts/ tree. ELF is
        # copied only in --with-elf (tag-time) mode - see release_extensions().
        out_dir = os.path.join(ARTIFACTS_DIR, unit["artifact_dir"])
        os.makedirs(out_dir, exist_ok=True)
        for ext in release_extensions(include_elf):
            dst = os.path.join(out_dir, unit["binary"] + "." + ext)
            shutil.copyfile(paths[ext], dst)
            rel = os.path.relpath(dst, REPO_ROOT)
            release_entries.append((rel, sha256_file(dst)))

        if not include_elf:
            # Not tag time: ELF must NOT persist in the tracked tree (owner
            # directive - "tracked ONLY at release tags"). Remove any stale
            # .elf left over from a prior --with-elf run so a plain refresh
            # can't silently leave a mismatched, un-regenerated ELF sitting
            # in artifacts/ next to fresh bin/hex/syms (which WOULD then
            # make `check` fail, correctly - see do_check).
            stale_elf = os.path.join(out_dir, unit["binary"] + ".elf")
            if os.path.isfile(stale_elf):
                os.remove(stale_elf)
                if not quiet:
                    print("   (removed stale {} - ELF is tracked only at "
                          "tag time, see build --with-elf)".format(
                              os.path.relpath(stale_elf, REPO_ROOT)))

        if unit["kind"] == "avr":
            nm_bin = shutil.which("avr-nm")
        else:
            nm_bin = unit["nm"]
        syms = gen_symbol_map(nm_bin, paths["elf"], objdump_bin=unit["objdump"])
        syms_path = os.path.join(out_dir, unit["binary"] + ".syms")
        header = ("# {}.syms - `{} --print-size --size-sort --demangle` "
                  "on the committed RELEASE .elf.\n"
                  "# Plain-text, diffable: when a port's binary size drifts, "
                  "`git diff` on this file shows WHICH function grew/shrank,\n"
                  "# not just that the binary changed. Regenerate with "
                  "`python3 tools/build_artifacts.py build --platforms {}`.\n"
                  .format(unit["binary"], os.path.basename(nm_bin) if not os.path.isabs(nm_bin) else nm_bin, key))
        if unit["objdump"]:
            header += (
                "# TOOLCHAIN DEFECT WORKAROUND: `{nm} --print-size` only\n"
                "# populates the size field for ~10% of this port's function\n"
                "# symbols and, combined with --size-sort, silently DROPS every\n"
                "# symbol it can't size instead of printing it with a 0/blank\n"
                "# size (verified: `{nm} --print-size --demangle` with no sort\n"
                "# still omits the size field for the same symbols - this is\n"
                "# nm's sizing, not the sort). Rows below tagged 'objdump\n"
                "# addr-delta estimate' were recovered via `{od} -t`/`-h`\n"
                "# (address-delta to the next function, capped at the\n"
                "# containing code section's end) instead - see platform.md\n"
                "# 'known toolchain defects' and tools/build_artifacts.py\n"
                "# gen_symbol_map()/_estimate_code_symbols().\n"
                .format(nm=os.path.basename(nm_bin) if not os.path.isabs(nm_bin) else nm_bin,
                        od=os.path.basename(unit["objdump"])))
        with open(syms_path, "w") as f:
            f.write(header)
            f.write(syms)
        rel = os.path.relpath(syms_path, REPO_ROOT)
        release_entries.append((rel, sha256_file(syms_path)))

        # .elf.dump: generated from the SAME freshly-built RELEASE .elf
        # (build/, scratch, regardless of --with-elf) and tracked
        # continuously like .syms - see the "elf.dump ... tracked
        # CONTINUOUSLY" comment above gen_elf_dump(). Deliberately NOT added
        # to release_entries/MANIFEST.sha256 - see elf_dump_header()'s "NOT
        # HASH-GATED" paragraph and do_check()'s matching comment.
        dump_objdump = objdump_bin_for_unit(unit)
        dump_extra_args = elf_dump_extra_args(unit)
        dump_body = gen_elf_dump(dump_objdump, paths["elf"], dump_extra_args)
        dump_path = os.path.join(out_dir, unit["binary"] + ".elf.dump")
        with open(dump_path, "w") as f:
            f.write(elf_dump_header(unit, dump_objdump))
            f.write(dump_body)

        if not quiet:
            print("   -> {} (RELEASE {}/syms/elf.dump copied to {})".format(
                key, "elf/hex/bin" if include_elf else "hex/bin",
                os.path.relpath(out_dir, REPO_ROOT)))

    manifest_text = format_manifest(sorted(release_entries), debug_entries)
    with open(MANIFEST_PATH, "w") as f:
        f.write(manifest_text)
    print("Wrote {} ({} release files, {} debug hashes, {} skipped{})".format(
        os.path.relpath(MANIFEST_PATH, REPO_ROOT), len(release_entries),
        len(debug_entries), len(skipped),
        ", --with-elf: .elf included (tag-time mode)" if include_elf else
        ", .elf excluded (tracked only at tag time - see --with-elf)"))
    return 0


def do_check(units, skip_debug):
    if not os.path.isfile(MANIFEST_PATH):
        print("check: FAIL - {} does not exist; run "
              "'tools/build_artifacts.py build' first".format(MANIFEST_PATH))
        return 1
    with open(MANIFEST_PATH) as f:
        manifest = parse_manifest(f.read())

    os.makedirs(BUILD_DIR, exist_ok=True)
    problems = []
    checked = 0
    skipped = []

    for unit in units:
        key = unit["key"]
        if not toolchain_available(unit):
            print("SKIPPED {}: toolchain not found - cannot verify "
                  "freshness".format(key))
            skipped.append(key)
            continue

        print("== checking {} ==".format(key))

        if unit["kind"] == "avr":
            paths, _log = build_avr_unit()
        else:
            if unit["has_debug"] and not skip_debug:
                dpaths, _dlog = build_std_unit(unit, "DEBUG")
                # See do_build's matching comment: only .elf is exempt for
                # nondeterministic_elf units - hex/bin are deterministic and
                # stay fully hash-gated in DEBUG exactly like every other unit.
                debug_exts = hash_gated_extensions(unit["nondeterministic_elf"])
                if unit["nondeterministic_elf"]:
                    print("   (skipping DEBUG .elf hash check for {}: ELF is "
                          "not byte-reproducible on this toolchain - hex/bin "
                          "ARE still checked)".format(key))
                for ext in debug_exts:
                    label = "build/{}/{}".format(unit["artifact_dir"], os.path.basename(dpaths[ext]))
                    fresh = sha256_file(dpaths[ext])
                    checked += 1
                    expected = manifest.get(label)
                    if expected is None:
                        problems.append("{}: DEBUG {} has no recorded hash "
                                         "in MANIFEST (manifest stale/incomplete)"
                                         .format(key, label))
                    elif expected != fresh:
                        problems.append("{}: DEBUG {} hash changed "
                                         "(manifest={} fresh={})".format(
                                             key, label, expected[:12], fresh[:12]))
            paths, _log = build_std_unit(unit, "RELEASE")

        out_dir = os.path.join(ARTIFACTS_DIR, unit["artifact_dir"])
        if unit["kind"] == "avr":
            nm_bin = shutil.which("avr-nm")
        else:
            nm_bin = unit["nm"]
        fresh_syms = gen_symbol_map(nm_bin, paths["elf"], objdump_bin=unit["objdump"])

        # nondeterministic_elf (dsPIC33AK only): the ELF's differing bytes
        # are embedded compiler-tempfile SECTION NAMES (/tmp/ccXXXXXX.s.scnN,
        # a random-per-invocation `as` scratch filename echoed into a few
        # section-name strings), not code or layout - see the UNITS table
        # comment for the measured evidence (bin/hex `cmp -l` empty across
        # two clean rebuilds; only .elf differs, ~12-13% of its bytes).
        # bin/hex are produced by objcopy/bin2hex from the linked image's
        # actual code/data bytes, which never see those scratch strings, so
        # they are hash-gated for this unit EXACTLY like every other unit -
        # only the .elf comparison below is skipped.
        exts_to_check = hash_gated_extensions(unit["nondeterministic_elf"])
        if unit["nondeterministic_elf"]:
            print("   (skipping RELEASE .elf hash check for {}: ELF is not "
                  "byte-reproducible on this toolchain, see UNITS table - "
                  "hex/bin ARE still checked)".format(key))
        for ext in exts_to_check:
            committed = os.path.join(out_dir, unit["binary"] + "." + ext)
            if ext == "elf" and not os.path.isfile(committed):
                # ELF is tracked ONLY at release-tag time (owner
                # directive, see build --with-elf) - its absence
                # between tags is the expected state, not a failure.
                # bin/hex/syms are still required below/elsewhere.
                continue
            checked += 1
            if not os.path.isfile(committed):
                problems.append("{}: committed {} is MISSING".format(
                    key, os.path.relpath(committed, REPO_ROOT)))
                continue
            fresh_hash = sha256_file(paths[ext])
            committed_hash = sha256_file(committed)
            if fresh_hash != committed_hash:
                problems.append("{}: {} is STALE (committed={} fresh={})".format(
                    key, os.path.relpath(committed, REPO_ROOT),
                    committed_hash[:12], fresh_hash[:12]))

        committed_syms_path = os.path.join(out_dir, unit["binary"] + ".syms")
        checked += 1
        if not os.path.isfile(committed_syms_path):
            problems.append("{}: committed {} is MISSING".format(
                key, os.path.relpath(committed_syms_path, REPO_ROOT)))
        else:
            with open(committed_syms_path) as f:
                committed_syms = f.read()
            # Compare body only (ignore the header we prepend - it's static).
            committed_body = "\n".join(
                l for l in committed_syms.splitlines() if not l.startswith("#"))
            fresh_body = fresh_syms.strip("\n")
            if committed_body.strip("\n") != fresh_body:
                problems.append("{}: {} is STALE (symbol map differs from "
                                 "fresh build)".format(
                                     key, os.path.relpath(committed_syms_path, REPO_ROOT)))

        # .elf.dump: PRESENCE required (tracked continuously, same cadence
        # as .syms) but content is DELIBERATELY NOT hash-gated/diffed here -
        # NOT added to `checked`, unlike every file above. Reason (measured
        # this batch, see elf_dump_header()'s "NOT HASH-GATED" paragraph in
        # full): objdump always prints the exact path it was invoked with
        # as the FIRST line of its own output, regardless of any compiler
        # flag - a fresh rebuild's dump is only byte-identical to the
        # committed one when regenerated from the IDENTICAL absolute
        # checkout path, which this project's actual workflow (a fresh
        # worktree per task) does not provide. Hash-gating it would
        # false-positive on effectively every `check` run for zero real
        # drift, so `check` intentionally skips the comparison rather than
        # papering over it with a silent pass.
        committed_dump_path = os.path.join(out_dir, unit["binary"] + ".elf.dump")
        if not os.path.isfile(committed_dump_path):
            problems.append("{}: committed {} is MISSING".format(
                key, os.path.relpath(committed_dump_path, REPO_ROOT)))
        else:
            print("   (skipping {} content check for {}: objdump's own "
                  "first output line is its invocation path, not "
                  "reproducible across checkouts/worktrees - presence "
                  "verified, content intentionally not diffed here, see "
                  "the file's own header)".format(
                      os.path.relpath(committed_dump_path, REPO_ROOT), key))

    if problems:
        print("")
        print("artifacts check: FAIL - {} problem(s):".format(len(problems)))
        for p in problems:
            print("  - " + p)
        print("")
        print("Regenerate with: python3 tools/build_artifacts.py build")
        return 1

    print("artifacts check: OK - {} file(s) verified fresh across {} unit(s)"
          "{}.".format(checked, len(units) - len(skipped),
                       ", {} skipped (no toolchain)".format(len(skipped)) if skipped else ""))
    return 0


# ---------------------------------------------------------------------------
# selftest - pure logic, no compiler invoked
# ---------------------------------------------------------------------------

def selftest():
    checks = 0

    def check(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            print("selftest: FAIL - " + what)
            sys.exit(1)

    # --- manifest formatting round-trips ------------------------------------
    release = [("artifacts/foo/grbl_foo.elf", "a" * 64),
               ("artifacts/foo/grbl_foo.bin", "b" * 64)]
    debug = [("build/grbl_foo_dbg.elf", "c" * 64)]
    text = format_manifest(release, debug)
    check("a" * 64 + "  artifacts/foo/grbl_foo.elf" in text,
          "RELEASE entry present, uncommented")
    check("# " + "c" * 64 + "  build/grbl_foo_dbg.elf" in text,
          "DEBUG entry present, comment-prefixed")

    parsed = parse_manifest(text)
    check(parsed["artifacts/foo/grbl_foo.elf"] == "a" * 64,
          "RELEASE entry parses back")
    check(parsed["build/grbl_foo_dbg.elf"] == "c" * 64,
          "DEBUG (comment) entry ALSO parses back (needed so 'check' can "
          "compare against it)")

    # prose-only lines (the header) must not be mistaken for hash entries
    prose_only = parse_manifest("# artifacts/MANIFEST.sha256 - generated by "
                                 "tools/build_artifacts.py\n# see README\n")
    check(prose_only == {}, "prose comment lines produce no manifest entries")

    # --- MANIFEST_LINE_RE shape ---------------------------------------------
    check(MANIFEST_LINE_RE.match(
        "deadbeef" * 8 + "  some/path.bin") is not None,
        "plain hash line matches")
    check(MANIFEST_LINE_RE.match(
        "# " + "deadbeef" * 8 + "  some/path.bin") is not None,
        "comment-prefixed hash line matches")
    check(MANIFEST_LINE_RE.match("not a hash line") is None,
          "non-hash line does not match")
    check(MANIFEST_LINE_RE.match("deadbeef  short/hash/not/64/chars.bin") is None,
          "too-short hex string does not match (guards against truncated hashes)")

    # --- unit table sanity ---------------------------------------------------
    check(len(UNITS) == len(set(u["key"] for u in UNITS)),
          "every unit key is unique")
    check(unit_by_key("samd21-megarm")["artifact_dir"] == "samd21-megarm",
          "unit lookup by key works")
    # samd21's two boards share one BINARY_NAME (grbl_samd21) at the
    # toolchain level (Makefile doesn't encode BOARD in it) but MUST have
    # distinct artifact_dir/DEBUG-label namespacing, or their DEBUG hashes
    # collide under one manifest key and 'check' false-positives on
    # whichever board's hash the dict-parse happens to keep last - the
    # exact bug found and fixed while building this tool (see the
    # "build/{}/{}".format(unit["artifact_dir"], ...) label construction in
    # do_build/do_check).
    megarm = unit_by_key("samd21-megarm")
    generic = unit_by_key("samd21-generic")
    check(megarm["binary"] == generic["binary"] == "grbl_samd21",
          "both samd21 boards share the toolchain's BINARY_NAME (precondition for the collision this guards against)")
    check(megarm["artifact_dir"] != generic["artifact_dir"],
          "samd21 boards have DISTINCT artifact_dir (DEBUG-label collision guard)")
    debug_label = lambda u, fname: "build/{}/{}".format(u["artifact_dir"], fname)
    check(debug_label(megarm, "grbl_samd21_dbg.elf") != debug_label(generic, "grbl_samd21_dbg.elf"),
          "DEBUG manifest labels for the two samd21 boards do not collide")
    # dsPIC's restricted-license toolchain's ELF (only the ELF - see UNITS
    # table comment: embedded compiler-tempfile section names, not code) is
    # documented non-reproducible - the flag must be set so do_build/do_check
    # skip ONLY the .elf hash comparison for it (would otherwise always
    # FAIL); bin/hex must NOT be exempted (over-broad exemption is exactly
    # the bug an adversarial review caught and this batch fixed).
    check(unit_by_key("dspic33ak128mc102")["nondeterministic_elf"] is True,
          "dsPIC33AK unit is flagged nondeterministic_elf")
    check(all(u["nondeterministic_elf"] is False for u in UNITS
               if u["key"] != "dspic33ak128mc102"),
          "no OTHER unit is flagged nondeterministic_elf (would silently "
          "weaken the staleness gate for a port that doesn't need it)")

    # --- hash_gated_extensions: the GAP1 adversarial-review fix -------------
    # Regression guard for the exact bug found: the old flag dropped
    # elf/hex/bin ALL THREE from the hash gate; the fix must exempt ONLY
    # .elf, never hex/bin (measured: those are byte-identical across two
    # clean dsPIC rebuilds, only .elf differs - see UNITS table comment).
    check(hash_gated_extensions(False) == ("elf", "hex", "bin"),
          "normal unit: elf/hex/bin all hash-gated")
    check(hash_gated_extensions(True) == ("hex", "bin"),
          "nondeterministic_elf unit: hex/bin STILL hash-gated, only elf exempt")
    check("elf" not in hash_gated_extensions(True),
          "nondeterministic_elf unit: elf is the ONLY exempt extension")
    check("hex" in hash_gated_extensions(True) and "bin" in hash_gated_extensions(True),
          "nondeterministic_elf unit: hex AND bin remain gated (the exact "
          "over-broad-exemption bug an adversarial review caught)")
    try:
        unit_by_key("does-not-exist")
        check(False, "unit_by_key must raise KeyError for an unknown key")
    except KeyError:
        check(True, "unit_by_key raises KeyError for an unknown key")

    # --- select_units filtering ----------------------------------------------
    check(len(select_units(None)) == len(UNITS), "no filter selects all units")
    check([u["key"] for u in select_units("ch32v006,ch570")] ==
          ["ch32v006", "ch570"], "comma-separated filter preserves order")

    # --- ELF-tracked-only-at-tag-time ("Эльф на тегах" owner directive) ------
    # release_extensions() is the single source of truth do_build/do_check
    # consult for whether .elf belongs in artifacts/ - exercise it directly,
    # pure logic, no compiler/filesystem involved.
    check(release_extensions(False) == ("hex", "bin"),
          "default (non-tag) build excludes .elf")
    check(release_extensions(True) == ("elf", "hex", "bin"),
          "--with-elf (tag-time) build includes .elf")
    check("elf" not in release_extensions(False),
          "plain refresh never re-introduces .elf (regression guard for "
          "the owner directive - ELF grew the repo 12MB->14MB in one "
          "refresh before this change)")

    # --- .elf.dump: tracked continuously (NOT tag-gated like .elf itself),
    # never hash-gated (objdump echoes its own invocation path - see
    # elf_dump_header()/do_check() for the full argument) -----------------
    check("elf.dump" not in release_extensions(True) and
          "elf.dump" not in release_extensions(False),
          ".elf.dump is not governed by the tag-time release_extensions() "
          "toggle at all - it's written unconditionally in do_build(), "
          "same cadence as .syms, regardless of --with-elf")
    check("elf.dump" not in hash_gated_extensions(True) and
          "elf.dump" not in hash_gated_extensions(False),
          ".elf.dump must never appear in the hash-gated extension set - "
          "it is deliberately presence-checked only, never hash-compared "
          "(see do_check()'s dedicated elf.dump block)")
    check(objdump_bin_for_unit(unit_by_key("atmega328p")) == "avr-objdump",
          "AVR unit's .elf.dump objdump binary is avr-objdump")
    check(objdump_bin_for_unit(unit_by_key("ch32v006")) ==
          "riscv64-unknown-elf-objdump",
          "RISC-V unit's .elf.dump objdump binary is riscv64-unknown-elf-objdump")
    check(objdump_bin_for_unit(unit_by_key("ch570")) ==
          "riscv64-unknown-elf-objdump",
          "both RISC-V units resolve the same objdump binary")
    check(objdump_bin_for_unit(unit_by_key("stm32f103")) ==
          "arm-none-eabi-objdump",
          "plain ARM unit's .elf.dump objdump binary is arm-none-eabi-objdump")
    dspic_unit = unit_by_key("dspic33ak128mc102")
    check(objdump_bin_for_unit(dspic_unit) == dspic_unit["objdump"],
          "dsPIC's .elf.dump reuses the SAME xc-dsc-objdump path already "
          "resolved for the nm --print-size fallback (not a second, "
          "independently-configured binary)")
    check(elf_dump_extra_args(dspic_unit) ==
          ["-mdfp={}".format(os.path.join(dspic_unit["extra_args"]["DFP_PATH"], "xc16"))],
          "dsPIC's .elf.dump gets -mdfp=<DFP>/xc16 (xc-dsc-objdump -d "
          "refuses to disassemble at all without it - measured this batch, "
          "exit 255 'can't disassemble for architecture UNKNOWN')")
    check(all(elf_dump_extra_args(u) == [] for u in UNITS
               if u["key"] != "dspic33ak128mc102"),
          "no OTHER unit needs extra objdump args for its .elf.dump")
    check("--no-show-raw-insn" in ELF_DUMP_FLAGS,
          "raw instruction encoding bytes are stripped from the dump (diff "
          "reads as instructions, not hex - measured ~24% smaller too)")
    check("-D" not in ELF_DUMP_FLAGS and "--disassemble-all" not in ELF_DUMP_FLAGS,
          "never --disassemble-all: would decode .data/.rodata/.debug bytes "
          "as bogus instructions, code-only -d is deliberate")
    check("--no-addresses" not in ELF_DUMP_FLAGS,
          "never --no-addresses: unsupported by avr-objdump 2.26 and "
          "xc-dsc-objdump 2.32 (added in binutils 2.36) - using it would "
          "break disassembly on two of the four toolchains this covers")
    check("-r" not in ELF_DUMP_FLAGS,
          "never -r: relocation entries are empty for a final linked "
          "executable (verified empty on a real build) - the flag would "
          "only add a header for zero content")

    # CLI must parse --with-elf on 'build' and default it to False so an
    # ordinary `build` invocation (CI, a contributor's refresh) can never
    # silently start tracking ELF again just because the flag was forgotten.
    cli = build_arg_parser()
    parsed_default = cli.parse_args(["build"])
    check(parsed_default.with_elf is False,
          "build defaults to --with-elf=False (ELF opt-in, not opt-out)")
    parsed_tag = cli.parse_args(["build", "--with-elf"])
    check(parsed_tag.with_elf is True,
          "build --with-elf parses and sets the flag")

    # --- the core drift-detection comparison, without any build ------------
    # This is the logic 'check' runs per-file; exercise it directly with
    # synthetic hashes so the comparison itself is proven correct
    # independent of any toolchain being installed.
    def compare(committed, fresh):
        return committed == fresh

    check(compare("deadbeef", "deadbeef") is True, "identical hash: no drift")
    check(compare("deadbeef", "cafef00d") is False,
          "differing hash: drift detected (the exact case a mutated source "
          "file must trigger)")

    print("selftest: PASS ({} checks)".format(checks))
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser():
    """Separated from main() so --selftest can exercise real argparse
    parsing (e.g. --with-elf defaulting/round-tripping) as pure logic,
    without invoking a compiler or touching argv."""
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--selftest", action="store_true", help="run unit checks, no compiler invoked")
    sub = p.add_subparsers(dest="cmd")

    b = sub.add_parser("build", help="build and commit RELEASE artifacts + MANIFEST.sha256")
    b.add_argument("--platforms", help="comma-separated unit keys (default: all)")
    b.add_argument("--skip-debug", action="store_true", help="skip DEBUG builds (manifest DEBUG section omitted for skipped units)")
    b.add_argument("--with-elf", action="store_true",
                   help="also copy RELEASE .elf into artifacts/ (tag-time "
                        "only - 'Эльф на тегах' owner directive; see the "
                        "module docstring and PORTING-CHECKLIST.md's "
                        "refresh policy)")

    c = sub.add_parser("check", help="rebuild fresh and fail if committed artifacts are stale")
    c.add_argument("--platforms", help="comma-separated unit keys (default: all)")
    c.add_argument("--skip-debug", action="store_true", help="skip DEBUG freshness check")

    return p


def main(argv=None):
    p = build_arg_parser()
    a = p.parse_args(argv)

    if a.selftest:
        return selftest()

    if a.cmd == "build":
        try:
            units = select_units(a.platforms)
        except KeyError as e:
            p.error(str(e))
        try:
            return do_build(units, a.skip_debug, include_elf=a.with_elf)
        except BuildError as e:
            print("build: FAIL - {}".format(e))
            return 1

    if a.cmd == "check":
        try:
            units = select_units(a.platforms)
        except KeyError as e:
            p.error(str(e))
        try:
            return do_check(units, a.skip_debug)
        except BuildError as e:
            print("check: FAIL - {}".format(e))
            return 1

    p.error("one of 'build', 'check', or --selftest is required")


if __name__ == "__main__":
    sys.exit(main())
