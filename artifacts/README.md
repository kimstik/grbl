# Tracked build artifacts

**This directory is not an end-of-project report.** It exists so the
*current* byte-level state of every GRBL port is inspectable and diffable
over time — `git log -p artifacts/<port>/` or `git diff <rev>..<rev> --
artifacts/` — the same way the AVR golden MD5
(`grbl/platform/Makefile:validate`) has always let one port's output be
checked byte-for-byte. Before this directory existed, that was the *only*
port with any build history; the other eight/nine could only be compared
"now vs now" inside a single session, by rebuilding twice — a 40-byte size
drift between two sessions had nothing to diff against. Now every port does.

Full detail and rationale: [CONTRACTS.md §25](../grbl/platform/CONTRACTS.md#build-artifacts-tracked).
Regeneration/verification tooling: `tools/build_artifacts.py` (see its
module docstring, or run `python3 tools/build_artifacts.py --help`).

## What's committed, per port

```
artifacts/<port>/
  grbl_<port>.bin    RELEASE raw binary image               (every refresh)
  grbl_<port>.hex    RELEASE Intel HEX image                (every refresh)
  grbl_<port>.syms   `nm --print-size --size-sort --demangle`
                     on the RELEASE .elf                     (every refresh)
  grbl_<port>.elf    RELEASE ELF (debug symbols stripped
                     only by -g0)                       (TAG TIME ONLY - see below)
```

**"Эльф на тегах" (owner directive): `.elf` is tracked ONLY at release-tag
time, not on every refresh** — `bin`/`hex`/`syms` stay tracked continuously
exactly as before. Reason, measured plainly: one full snapshot of this tree
was **2.6MB** (42 tracked files, all ten units × elf/bin/hex/syms); a single
ordinary content refresh grew the *repo's* `.git` from **12MB to 14MB**,
because git does not delta binaries across recompiles — a source edit that
moves one function by 40 bytes typically re-links every address after it,
so the whole blob differs and git stores a full new zlib-compressed copy
every time. `.elf` is the largest artifact class (48-166KB/unit) vs. `.bin`
(25-95KB), `.hex` (72-116KB), and `.syms` (a few KB) — see the "Growth
cost" table below. Excluding it from routine refreshes removed **10 files /
1,221,872 bytes (~1.19MB)** from the tracked tree in the change that
introduced this policy (42 → 32 tracked files, 2,612,919 → 1,389,988 bytes,
~47% smaller), and caps every subsequent full-tree refresh at roughly
**1.37MB worst case** (all ten units touched) instead of ~2.6-2.7MB — a
partial refresh (the common case: one or two ports touched) is
proportionally cheaper still, since `.elf` was 46-58% of any given unit's
tracked bytes.

`tools/build_artifacts.py build` (the default, run for ordinary refreshes)
does NOT copy `.elf` and actively removes any stale one left in
`artifacts/<port>/` from a prior tag build, so a plain refresh can never
leave a mismatched ELF sitting next to fresh bin/hex/syms.
`tools/build_artifacts.py build --with-elf` is the explicit, tag-time-only
mode that DOES copy `.elf` and record its hash — see "Tagging a release"
below for the full command, including why it does not use `git add -A`.

samd21 gets two directories, `samd21-megarm/` and `samd21-generic/`, one per
board — the toolchain names both boards' ELF identically
(`grbl_samd21.elf`, see `grbl/platform/samd21/Makefile`'s `BINARY_NAME`,
which does not encode `BOARD`), so the directory is what disambiguates them.

`MANIFEST.sha256` (repo-root-relative paths) covers every artifact of every
port **and both build flavors** — including DEBUG, whose binaries are never
committed (see "Why DEBUG isn't committed" below). RELEASE lines are plain
`sha256sum -c`-compatible entries; DEBUG lines are `#`-prefixed (so
`sha256sum -c` skips them cleanly) but still parse as hash+label, so
`tools/build_artifacts.py check` can compare a fresh DEBUG rebuild against
them without a second committed binary set.

```sh
# Verify the RELEASE files in your working tree haven't been hand-edited:
sha256sum -c artifacts/MANIFEST.sha256

# Verify the committed artifacts are still what a FRESH build produces
# (the actual staleness gate — rebuilds everything, touches nothing in
# artifacts/, fails loudly naming every drifted file). bin/hex/syms are
# always required; .elf is verified ONLY if present in the tree — its
# absence between tags is the expected state, not a check failure:
python3 tools/build_artifacts.py check
```

## Why the symbol map is the piece that actually explains size drift

A `.bin`/`.hex`/`.elf` diff between two commits tells you a port's binary
changed and by how many bytes — it cannot tell you *which function* moved.
`grbl_<port>.syms` is plain, sorted, diffable text (`nm --print-size
--size-sort --demangle`); when a size ratchet fires or a reviewer notices a
+40-byte drift, `git diff` on the `.syms` file names the exact symbol that
grew or shrank, in seconds, with no rebuild. It costs a few KB per port
because it's text, not another binary copy.

## Why DEBUG isn't committed

DEBUG builds are 3-10x larger than RELEASE (no `-Os`/no LTO, full `-g3`
debug info — dsPIC33AK's DEBUG `.elf` alone is ~14 MB uncompressed) and
exist to make single-stepping possible, not to ship. Committing them would
roughly double this directory's growth cost for a flavor nobody diffs in
practice. Instead, `MANIFEST.sha256` records DEBUG's hash so a DEBUG-only
regression (a change that only shows up at `-O0`, e.g. a warning becoming
real UB) is still *observable* via `git diff` on the manifest, without
paying the storage cost of a second full binary set per port.

## Growth cost — stated plainly, not hidden in a commit message

Measured on this tree (RELEASE, all ten port/board units):

| class | measured range | tracked |
|---|---|---|
| `.bin` | 25 KB (hc32f460) - 41 KB (ch32v006); 95 KB on dsPIC33AK (word-per-instruction padding — see below) | every refresh |
| `.hex` | 72 KB - 116 KB | every refresh |
| `.elf` | 48 KB (atmega328p, no debug info at `-g0`) - 166 KB | **release tags only** (`build --with-elf`) |
| `.syms` | a few KB - ~10 KB (plain text) | every refresh |

**Before the "Эльф на тегах" policy** (elf tracked continuously, every
refresh): one full snapshot (all ten units) was **2,612,919 bytes (~2.6MB,
42 tracked files)**. A single ordinary content refresh was observed to grow
the repo's `.git` from **12MB to 14MB** — **git does not delta binaries
usefully across recompiles.** Even a source edit that only moves one
function by 40 bytes typically re-links every address after it, so the
whole `.elf`/`.bin`/`.hex` blob differs and git stores a new, separately
zlib-compressed copy; nothing tracks "this blob is 99% the same as the last
commit's blob" the way it does for text. Every subsequent refresh cost
roughly that much again, for whichever ports changed.

**After** (elf excluded from routine refreshes, this policy): the tracked
tree dropped to **1,389,988 bytes (~1.39MB, 32 tracked files)** — 10 files /
1,221,872 bytes (~1.19MB) removed, ~47% smaller. `.elf` was the largest
artifact class (48-166KB/unit, 46-58% of any given unit's tracked bytes),
so a routine refresh now costs **at most ~1.37MB** (all ten units touched
in one refresh — the worst case) instead of ~2.6-2.7MB, and proportionally
less for the common case of one or two ports changing. This is still the
deliberate, accepted cost of byte-level observability for bin/hex/syms the
owner asked for — state it plainly instead of discovering it later as a
repo-size surprise — but `.elf`'s share of that cost is now paid only when
a release is actually tagged, not on every push that touches a port.

dsPIC33AK's `.bin` is disproportionately large (95 KB vs. a 42 KB `.elf`
`.text`) because `xc-dsc-objcopy -I elf32-pic30 -O binary` expands this
core's packed instruction words into the raw addressable-byte layout the
Microchip toolchain uses — a real characteristic of the PIC30-family binary
format, not a mistake in this tooling.

## Tagging a release: including `.elf`

```sh
# Tag-time only - rebuilds everything and ALSO copies + hashes .elf:
python3 tools/build_artifacts.py build --with-elf

# .elf is deliberately left covered by .gitignore's blanket `*.elf` rule
# (no negation exception, unlike bin/hex/syms/README) - "ignorable by
# default" is the point between tags. `git add -A`/`git add .` SILENTLY
# skip ignored paths with zero output - the exact failure mode that has
# bitten this repo THREE times before (tools/README.md, ch570/vendor/
# ISP572.o, and this same artifacts/*.elf|hex under the OLD always-tracked
# policy) - so tag time force-adds the ELFs BY EXPLICIT PATH instead of
# relying on -A:
git add -f artifacts/*/*.elf

git commit -m "artifacts: tag vX.Y.Z ELF snapshot"
git tag vX.Y.Z
```

`git add -f` on an already-ignored path either adds it (success) or errors
loudly if the glob matches nothing — there is no silent-skip code path here,
unlike `-A`. Verify the policy holds with `git check-ignore -v
artifacts/<port>/grbl_<port>.elf` in both states: it should print
`.gitignore:3:*.elf ...` (matched, ignored) whether or not the file is
currently committed — negation exceptions don't apply to it, by design.

## dsPIC33AK128MC102: one port's binaries are tracked but NOT hash-gated

`xc-dsc-gcc`'s restricted/Free license tier does not produce byte-reproducible
output — two consecutive `make clean && make BUILD=RELEASE` runs of the
*identical, unmodified* source tree were measured (while building this
tooling) to differ in ~15% of the resulting ELF's bytes (`cmp -l`: 25361 of
166096 bytes), almost certainly a deliberate anti-tamper/watermarking
behavior of the restricted tier rather than anything under this project's
control. The **symbol map is stable** across those same two builds (`diff`
empty — function addresses and sizes don't move, only some padding/layout
bytes do), so `tools/build_artifacts.py check` still hash-gates
`grbl_dspic33ak128mc102.syms` for real drift, but skips the elf/hex/bin hash
comparison for this one unit (an unconditional compare would always
false-positive). bin/hex are still committed every refresh like every other
port; `.elf` follows the same tag-time-only policy as every other port (see
"Эльф на тегах" above) — when it IS present (post-tag), it's still useful
for archival/manual inspection, just not part of the automated freshness
gate for this one unit specifically.
If Microchip's paid tier (or a future toolchain) becomes reproducible, drop
`nondeterministic_binary=True` from this unit's entry in
`tools/build_artifacts.py`'s `UNITS` table and re-run `build` once to prove
it, then remove this section.

## Refresh policy

See ["Refresh policy" in `grbl/platform/PORTING-CHECKLIST.md`](../grbl/platform/PORTING-CHECKLIST.md#refresh-policy-when-to-re-run-toolsbuild_artifactspy-build)
for the full rule contributors are expected to follow. Short version:
refresh and commit `bin`/`hex`/`syms` whenever a port's *content* changes
(part of finishing that change, not a separate chore); do not refresh on
every push (most pushes are docs and don't move a single byte);
`tools/build_artifacts.py check` is the enforcement mechanism, not an honor
system. `.elf` is NOT part of this cadence — it's tag-time only, see
"Tagging a release" above.

## Regenerating

```sh
# Everything (~10 units, several minutes: real cross-compiles, not cached).
# Ordinary refresh - does NOT copy .elf (see "Эльф на тегах" above):
python3 tools/build_artifacts.py build

# Just the port(s) you touched:
python3 tools/build_artifacts.py build --platforms ch32v006
python3 tools/build_artifacts.py build --platforms samd21-megarm,samd21-generic

# Tag-time only - ALSO copies + hashes .elf (see "Tagging a release" above
# for the full command including the git add -f step):
python3 tools/build_artifacts.py build --with-elf

# Fast, no compiler invoked - pure logic self-test of the manifest
# format/hash-compare machinery (same style as ci/warn_ratchet.py,
# tools/assert_no_double.sh, tools/check_contracts_numbering.py):
python3 tools/build_artifacts.py --selftest
```

`make artifacts` / `make artifacts-check` at `grbl/platform/Makefile` are
thin wrappers around the two commands above — see that Makefile's `help`
target.

## Toolchain coverage in this environment

Nine ports (ten units, samd21 counted per board) built and were committed
here: `atmega328p`, `stm32f103`, `stm32h523`, `stm32f411`, `samd21`
(megarm + generic), `ch32v006`, `ch570`, `hc32f460`, `dspic33ak128mc102`.
`sg2002` is intentionally absent — PLAN.md Phase 6 records it as
design-complete/implementation-deferred (owner scope ruling), so there is no
buildable binary to track yet. `tools/build_artifacts.py`'s `UNITS` table
probes each toolchain before building and prints `SKIPPED <port>: toolchain
not found ...` rather than failing the whole run if one is ever missing in a
future environment — the plumbing (Makefile flags, DFP/TOOLCHAIN_PATH
variables, nm binary selection) stays wired even when a given machine can't
exercise it.
