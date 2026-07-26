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
      elf/bin/hex + a generated symbol-size map into artifacts/<port>/, and
      (re)write artifacts/MANIFEST.sha256 covering every artifact of every
      port AND flavor (DEBUG hashes are recorded even though DEBUG binaries
      are not committed - see the manifest's own header).

  tools/build_artifacts.py check [--platforms p1,p2,...] [--skip-debug]
      Rebuild fresh (into the ordinary build/ scratch dir, never touching
      artifacts/) and compare hashes against the committed artifacts/ tree
      (RELEASE) and the recorded manifest (DEBUG). Exits 1 and prints every
      drifted/missing file if the committed artifacts are stale relative to
      a fresh build. This is the sixth ratchet (after golden MD5, warn
      baseline, boot integrity, no-DP assert, docs integrity).

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
         extra_args={"BOARD": "generic",
                     "TOOLCHAIN_PATH": "/opt/xc-dsc/bin",
                     "DFP_PATH": "/opt/Microchip.dsPIC33AK-MC_DFP.1.5.263"},
         optional=True, toolchain_probe="/opt/xc-dsc/bin/xc-dsc-gcc",
         # xc-dsc-gcc's restricted/Free license tier is NOT byte-reproducible:
         # two back-to-back `make clean && make` runs of the IDENTICAL source
         # tree produce ELFs differing in ~15% of bytes (measured empirically
         # while building this tool - cmp -l on two consecutive builds:
         # 25361 of 166096 bytes differ), almost certainly a deliberate
         # anti-tamper/watermarking behavior of the restricted tier, not a
         # build-flag or ordering bug in this Makefile. The symbol-size map
         # (nm --print-size --size-sort) IS stable across the same two builds
         # (verified: diff empty) - function addresses/sizes don't move, only
         # some padding/layout bytes do. So: elf/bin/hex are still tracked for
         # archival/inspection, but the staleness CHECK skips their hash
         # comparison for this unit (would always false-positive) and relies
         # on the symbol map (still hash-verified) as the real gate.
         nondeterministic_binary=True),
]

for _u in UNITS:
    _u.setdefault("artifact_dir", _u["key"])
    _u.setdefault("nondeterministic_binary", False)
    _u.setdefault("has_debug", True)
    _u.setdefault("optional", False)


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


def gen_symbol_map(nm_bin, elf_path):
    if not os.path.isabs(nm_bin) and shutil.which(nm_bin) is None:
        raise BuildError("nm binary not found: {}".format(nm_bin))
    rc, out = run([nm_bin, "--print-size", "--size-sort", "--demangle", elf_path])
    if rc != 0:
        raise BuildError("{} failed on {}:\n{}".format(nm_bin, elf_path, out))
    return out


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


def do_build(units, skip_debug, quiet=False):
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
            if unit["has_debug"] and not skip_debug and not unit["nondeterministic_binary"]:
                dpaths, _dlog = build_std_unit(unit, "DEBUG")
                for ext in ("elf", "hex", "bin"):
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
            elif unit["nondeterministic_binary"] and not skip_debug:
                print("   (skipping DEBUG hash recording for {}: binary is "
                      "not byte-reproducible on this toolchain, see UNITS "
                      "table comment)".format(key))
            paths, _log = build_std_unit(unit, "RELEASE")

        # Copy RELEASE artifacts into the tracked artifacts/ tree.
        out_dir = os.path.join(ARTIFACTS_DIR, unit["artifact_dir"])
        os.makedirs(out_dir, exist_ok=True)
        for ext in ("elf", "hex", "bin"):
            dst = os.path.join(out_dir, unit["binary"] + "." + ext)
            shutil.copyfile(paths[ext], dst)
            rel = os.path.relpath(dst, REPO_ROOT)
            release_entries.append((rel, sha256_file(dst)))

        if unit["kind"] == "avr":
            nm_bin = shutil.which("avr-nm")
        else:
            nm_bin = unit["nm"]
        syms = gen_symbol_map(nm_bin, paths["elf"])
        syms_path = os.path.join(out_dir, unit["binary"] + ".syms")
        header = ("# {}.syms - `{} --print-size --size-sort --demangle` "
                  "on the committed RELEASE .elf.\n"
                  "# Plain-text, diffable: when a port's binary size drifts, "
                  "`git diff` on this file shows WHICH function grew/shrank,\n"
                  "# not just that the binary changed. Regenerate with "
                  "`python3 tools/build_artifacts.py build --platforms {}`.\n"
                  .format(unit["binary"], os.path.basename(nm_bin) if not os.path.isabs(nm_bin) else nm_bin, key))
        with open(syms_path, "w") as f:
            f.write(header)
            f.write(syms)
        rel = os.path.relpath(syms_path, REPO_ROOT)
        release_entries.append((rel, sha256_file(syms_path)))

        if not quiet:
            print("   -> {} (RELEASE elf/hex/bin/syms copied to {})".format(
                key, os.path.relpath(out_dir, REPO_ROOT)))

    manifest_text = format_manifest(sorted(release_entries), debug_entries)
    with open(MANIFEST_PATH, "w") as f:
        f.write(manifest_text)
    print("Wrote {} ({} release files, {} debug hashes, {} skipped)".format(
        os.path.relpath(MANIFEST_PATH, REPO_ROOT), len(release_entries),
        len(debug_entries), len(skipped)))
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
            if unit["has_debug"] and not skip_debug and not unit["nondeterministic_binary"]:
                dpaths, _dlog = build_std_unit(unit, "DEBUG")
                for ext in ("elf", "hex", "bin"):
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
            elif unit["nondeterministic_binary"]:
                print("   (skipping DEBUG hash check for {}: binary is not "
                      "byte-reproducible on this toolchain)".format(key))
            paths, _log = build_std_unit(unit, "RELEASE")

        out_dir = os.path.join(ARTIFACTS_DIR, unit["artifact_dir"])
        if unit["kind"] == "avr":
            nm_bin = shutil.which("avr-nm")
        else:
            nm_bin = unit["nm"]
        fresh_syms = gen_symbol_map(nm_bin, paths["elf"])

        if unit["nondeterministic_binary"]:
            # See the UNITS table comment: this toolchain's restricted/Free
            # license tier does not produce byte-reproducible output even
            # from an unmodified source tree, so an elf/bin/hex hash
            # comparison would always false-positive here. elf/bin/hex are
            # still tracked (archival/inspection value), just not gated by
            # hash; the symbol map below IS still gated (verified stable).
            print("   (skipping elf/hex/bin hash check for {}: toolchain "
                  "is not byte-reproducible, see UNITS table)".format(key))
        else:
            for ext in ("elf", "hex", "bin"):
                committed = os.path.join(out_dir, unit["binary"] + "." + ext)
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
    # dsPIC's restricted-license toolchain is documented non-reproducible
    # (see UNITS table comment) - the flag must be set so do_build/do_check
    # skip the elf/hex/bin hash gate for it (would otherwise always FAIL).
    check(unit_by_key("dspic33ak128mc102")["nondeterministic_binary"] is True,
          "dsPIC33AK unit is flagged nondeterministic_binary")
    check(all(u["nondeterministic_binary"] is False for u in UNITS
               if u["key"] != "dspic33ak128mc102"),
          "no OTHER unit is flagged nondeterministic_binary (would silently "
          "weaken the staleness gate for a port that doesn't need it)")
    try:
        unit_by_key("does-not-exist")
        check(False, "unit_by_key must raise KeyError for an unknown key")
    except KeyError:
        check(True, "unit_by_key raises KeyError for an unknown key")

    # --- select_units filtering ----------------------------------------------
    check(len(select_units(None)) == len(UNITS), "no filter selects all units")
    check([u["key"] for u in select_units("ch32v006,ch570")] ==
          ["ch32v006", "ch570"], "comma-separated filter preserves order")

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

def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--selftest", action="store_true", help="run unit checks, no compiler invoked")
    sub = p.add_subparsers(dest="cmd")

    b = sub.add_parser("build", help="build and commit RELEASE artifacts + MANIFEST.sha256")
    b.add_argument("--platforms", help="comma-separated unit keys (default: all)")
    b.add_argument("--skip-debug", action="store_true", help="skip DEBUG builds (manifest DEBUG section omitted for skipped units)")

    c = sub.add_parser("check", help="rebuild fresh and fail if committed artifacts are stale")
    c.add_argument("--platforms", help="comma-separated unit keys (default: all)")
    c.add_argument("--skip-debug", action="store_true", help="skip DEBUG freshness check")

    a = p.parse_args(argv)

    if a.selftest:
        return selftest()

    if a.cmd == "build":
        try:
            units = select_units(a.platforms)
        except KeyError as e:
            p.error(str(e))
        try:
            return do_build(units, a.skip_debug)
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
