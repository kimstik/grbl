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
  grbl_<port>.bin       RELEASE raw binary image               (every refresh)
  grbl_<port>.hex       RELEASE Intel HEX image                (every refresh)
  grbl_<port>.syms      `nm --print-size --size-sort --demangle`
                        on the RELEASE .elf                     (every refresh)
  grbl_<port>.elf.dump  `objdump -d -S -h -t --no-show-raw-insn`
                        on the RELEASE .elf - full disassembly +
                        section headers + symbol table          (every refresh)
  grbl_<port>.elf       RELEASE ELF (debug symbols stripped
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

## `grbl_<port>.elf.dump` — a readable diff one level deeper than `.syms`

`.syms` answers "which function grew or shrank." It cannot answer "what
*inside* that function changed" — that needs a disassembly, and a raw
`.elf` diff is useless for that (binary, not delta-compressible, and git
can't show you two overlapping instruction streams as a text diff anyway).
`grbl_<port>.elf.dump` is that disassembly, generated fresh every refresh
from the same RELEASE `.elf` `.syms` already reads, and it's plain text —
`git diff` on it reads as an actual instruction-level change list.

**Flags chosen, and why** (`tools/build_artifacts.py`'s `ELF_DUMP_FLAGS`,
each toolchain's own `objdump` — `arm-none-eabi-objdump` /
`riscv64-unknown-elf-objdump` / `avr-objdump` / `xc-dsc-objdump`):

| flag | why |
|---|---|
| `-d` | disassemble CODE sections only. Deliberately not `-D`/`--disassemble-all`, which also decodes `.data`/`.rodata`/`.debug_*` bytes as if they were instructions — pure noise, and it would drown the real disassembly in garbage. |
| `-S` | intermix source where DWARF line info exists. RELEASE is `-g0` on every port today (see each `Makefile`), so this is a **verified no-op**: `arm-none-eabi-objdump -d` and `-d -S` produce byte-identical output on a RELEASE `.elf` (checked this batch, stm32f103). Kept anyway — free today, and a future `-g`-enabled RELEASE flavor gets source interleave automatically instead of someone having to remember to add the flag later. |
| `-h` | section headers (sizes/addresses/flags) — the same table `.syms` generation already parses internally for the dsPIC nm-fallback, exposed here for humans too. |
| `-t` | full symbol table. |
| `--no-show-raw-insn` | drop the raw hex encoding column. Measured effect on stm32f103 RELEASE: 455,508 → 345,950 bytes (**−24%**) for the exact same instructions — the diff reads as mnemonics/operands, not an opcode-byte dump next to them. |

Two flags considered and rejected, stated rather than silently omitted:
- **`--no-addresses`** (drop the leading address column too, which would
  additionally suppress the "every line after an edited function shifts"
  noise a relink causes) — **not used**: unsupported by `avr-objdump` 2.26
  and `xc-dsc-objdump` 2.32 (added in binutils 2.36); using it would break
  disassembly outright on two of the four toolchains this covers. Uniform
  behavior across all four toolchains was judged more valuable than a
  quieter diff on only two of them.
- **`-r`** (relocation entries) — **not used**: verified empty (`cmp`-empty
  output beyond the file-format banner) on a real linked executable here;
  relocations only exist in relocatable `.o` files, not a final linked
  image, so the flag would add a section header for zero content.

**Tracking policy: continuous, NOT tag-time-only, despite the name**
`.elf` itself is tracked only at release tags ("Эльф на тегах", see below).
`.elf.dump` is tracked on **every** refresh, same cadence as `.syms`, even
though no `.elf` sits next to it between tags — it's generated straight
from the scratch-built RELEASE `.elf` in `build/`, the same way `.syms`
already is, and never needs the binary itself to persist. This is argued
from what the owner wants the file **for**: a readable diff of what
changed *between builds*. A tag-gated dump would only ever be diffable
release-to-release — the exact sparse, "now vs now" gap `.bin`/`.hex`/
`.syms` already exist to close for every other artifact class. Gating
`.elf.dump` to tag time would reintroduce that same gap one layer deeper,
for the one artifact whose entire purpose is closing it. (The directory
placement still satisfies "put it next to the elf" literally: at tag time
both files sit in the same `artifacts/<port>/` directory; between tags,
only `.elf.dump` does — exactly how `.syms` already behaves today.)

**Size cost of continuous tracking** (measured this batch, RELEASE,
`--no-show-raw-insn` applied): see the "Growth cost" table below for the
per-port numbers and the total added to a full-tree refresh.

**NOT hash-gated — `check` verifies presence, not content** (see
`tools/build_artifacts.py`'s `elf_dump_header()`/`do_check()`): `objdump`
prints the exact path it was invoked with as the **first line** of its own
output, on every toolchain, regardless of any compiler flag. Two RELEASE
rebuilds of stm32f103 from different absolute paths produced a
byte-identical `.elf` (`cmp`: no difference) but a `.elf.dump` differing in
exactly that one echoed-path line — proven this batch, not assumed. This
project's actual workflow (a fresh git worktree per task) hits that path
difference on effectively every `check` run, so hash-gating this file
would false-positive constantly for zero real drift. `dsPIC33ak128mc102`'s
dump is additionally non-reproducible **even from the same path**, for the
same root cause as its `.elf`'s existing `nondeterministic_elf` exemption:
`xc-dsc-gcc`'s per-invocation `/tmp/ccXXXXXX.s.scnN` compiler-tempfile
section names, plus a pointer-derived internal symbol name
(`_0x<hexptr>_at_address_...`), both show up verbatim in `-h`/`-t` output
and were confirmed (this batch) to differ across two back-to-back
`make clean && make` runs from the identical path. `check` therefore
verifies `grbl_<port>.elf.dump` **exists** (a silently-deleted dump is
still a real regression, caught the same as a missing `.syms`) but does
not diff its content against a fresh rebuild — doing so unconditionally
would either mask the deliberate exemption in a comment nobody reads or
make the ratchet fail constantly for a property nobody asked it to hold.
This does not weaken the existing gate: `.elf.dump` was never part of the
56-file hash-gated set and still isn't; it is checked in its own,
presence-only branch, printed explicitly (not silently skipped) each run.

`dsPIC33ak128mc102`'s `.elf.dump` also needs `-mdfp=<DFP>/xc16` to
disassemble at all — verified this batch: `xc-dsc-objdump -d` with no
`-mdfp` exits 255, `"can't disassemble for architecture UNKNOWN"` (`-h`/
`-t` alone tolerate its absence, just print a resource-file warning and
fall back to a generic `elf32-little` bfd name). This is the same DFP
device pack every other toolchain invocation on this unit already needs,
supplied via `tools/build_artifacts.py`'s existing `DFP_PATH` unit field.

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
| `.elf.dump` | **293 KB (hc32f460) - 649 KB (dsPIC33AK)** (plain text, `--no-show-raw-insn` applied) | every refresh |

**`.elf.dump`'s size cost, measured per port, this batch** (bytes, the flags
above applied):

| port/board | `.elf` | `.elf.dump` | ratio |
|---|---:|---:|---:|
| atmega328p | 48,080 | 463,668 | 9.6x |
| stm32f103 | 113,164 | 348,801 | 3.1x |
| stm32h523 | 93,576 | 297,259 | 3.2x |
| stm32f411 | 98,404 | 302,474 | 3.1x |
| samd21-megarm | 151,164 | 443,079 | 2.9x |
| samd21-generic | 151,164 | 442,937 | 2.9x |
| ch32v006 | 138,600 | 350,302 | 2.5x |
| ch570 | 140,312 | 351,860 | 2.5x |
| hc32f460 | 98,612 | 292,969 | 3.0x |
| dspic33ak128mc102 | 166,096 | 648,771 | 3.9x |
| **total (10 units)** | 1,199,172 | **3,942,120** | **3.3x avg** |

`.elf.dump` is text (plain disassembly, not another binary copy) but it is
**substantially bigger than `.elf` itself** — a full symbol table plus
per-instruction disassembly lines simply takes more bytes than the packed
binary encoding it's derived from. atmega328p's outlier 9.6x ratio is
AVR's own disassembly density (16-bit instruction words, comparatively
verbose `avr-objdump` symbol/section output relative to its small 48 KB
`.elf`), not a bug in the flag choice — the other nine units cluster at
2.5-3.9x.

**Tracked continuously** (every refresh, not tag-time-only — see the
policy argument above), this adds **3,942,120 bytes (~3.76 MiB) across all
ten units to EVERY refresh that touches every port**, and a proportional
share for the common case of one or two ports changing. Measured against
the tree as it stood immediately before this batch (32 tracked files,
1,403,154 bytes): adding `.elf.dump` continuously brings the full-refresh
tracked tree to **42 files, 5,345,274 bytes (~5.10 MiB)** — a **~281%**
increase over the pre-`.elf.dump` size, and larger than a full tag-time
`--with-elf` snapshot would have added on its own. This is a real,
substantial, `git`-non-delta-compressible cost every refresh going
forward, stated plainly rather than discovered later — the same posture
this document already takes for `.bin`/`.hex`/`.elf`/`.syms` above. It is
accepted as the price of a human-readable instruction-level diff existing
at all for every port, on every refresh, not just at tags.

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

## `.gitignore` does NOT swallow `.elf.dump` — proven, not assumed

This repo's blanket ignore rules have silently dropped an intentionally-
tracked file from `git add -A` **three times before** this batch
(`tools/README.md`, `ch570/vendor/ISP572.o`, and this same
`artifacts/*.elf|hex` pair under the old always-track-`.elf` policy) — a
fourth silent surprise, this time for `.elf.dump`, is not acceptable. Two
facts make it a non-issue by construction, both verified this batch rather
than assumed:

1. **No existing rule matches the new suffix.** `.gitignore`'s blanket
   `*.elf` rule (line 3) matches a path ending in exactly `.elf` — `foo.elf`
   — not `foo.elf.dump`, which ends in `.dump`. There is no `*.dump` rule
   anywhere in `.gitignore` either. `git check-ignore -v` on every
   committed `.elf.dump` path prints nothing and exits 1 (no matching
   rule) — confirmed for all ten units this batch.
2. **`git status --porcelain`** lists every freshly-generated `.elf.dump`
   as `??` (untracked, not ignored) — `git status` omits ignored paths
   entirely unless `--ignored` is passed, so their appearance here is
   itself part of the proof.

**Full-loop proof, run this batch**: after committing the new
`.elf.dump` files, `git archive HEAD | tar -tf -` (equivalently, extracting
a `git archive` output into a clean directory) was checked to include all
ten `artifacts/<port>/grbl_<port>.elf.dump` paths — the same "does a fresh
checkout actually contain the file" proof `tools/README.md`'s original fix
was validated with, applied here before this becomes the fourth surprise
instead of a documented non-issue.

## dsPIC33AK128MC102: the `.elf` (only the `.elf`) is tracked but NOT hash-gated

`xc-dsc-gcc` does not produce a byte-reproducible **`.elf`** — two
consecutive `make clean && make BUILD=RELEASE` runs of the *identical,
unmodified* source tree were measured to differ in ~12-13% of the
resulting `.elf`'s bytes (re-measured, adversarial review: 20829-22185 of
~166000 bytes; the exact count wobbles run to run). Root cause (identified
by that review, not previously explained here): the differing bytes are
embedded `/tmp/ccXXXXXX.s.scnN` compiler-tempfile **section names** — `as`'s
per-invocation randomly-named scratch assembly file, echoed into a handful
of the ELF's section-name strings — not code, not a watermark, nothing
this project's Makefile controls. Critically, **`.bin` and `.hex` are
BYTE-IDENTICAL** across the same two builds (`cmp -l`: empty) — they are
produced by `xc-dsc-objcopy`/`xc-dsc-bin2hex` from the *linked image's
actual code/data bytes*, which never see those compiler-scratch strings.
The **symbol map is also stable** (`diff` empty — function addresses/sizes
don't move).

**GAP FIX (adversarial review)**: this section used to say "one port's
*binaries* are tracked but NOT hash-gated" and the tool used one
all-or-nothing `nondeterministic_binary` flag that skipped `.elf` **and**
`.hex` **and** `.bin`'s hash comparison — silently weakening the gate for
two files that were never actually nondeterministic (proof above: their
sha256 is IDENTICAL across two clean rebuilds). Fixed: the flag is now
`nondeterministic_elf`, scoped to `.elf` only
(`tools/build_artifacts.py`'s `hash_gated_extensions()` helper, covered by
`--selftest`). `tools/build_artifacts.py check` hash-gates
`grbl_dspic33ak128mc102.bin`/`.hex`/`.syms` for **both RELEASE and DEBUG**
exactly like every other unit (DEBUG previously wasn't even built for this
unit — the old flag skipped the whole DEBUG stage, not just its `.elf`
hash) and skips ONLY the `.elf` comparison, because that one file is
genuinely, provenly not byte-reproducible. `.elf` follows the same
tag-time-only policy as every other port (see "Эльф на тегах" above) — when
it IS present (post-tag), it's still useful for archival/manual inspection,
just not part of the automated freshness gate for this one unit
specifically.
If Microchip's paid tier (or a future toolchain) becomes reproducible for
`.elf` too, drop `nondeterministic_elf=True` from this unit's entry in
`tools/build_artifacts.py`'s `UNITS` table and re-run `build` once to prove
it, then remove this section.

## DEBUG `.elf` manifest hashes are build-path dependent; RELEASE is not

Adversarial-review finding: `-g3` (every port's DEBUG flavor) embeds the
compiler's absolute working directory (DWARF `DW_AT_comp_dir`) — and, on at
least the dsPIC33AK toolchain, some translation units' absolute source path
too — so a DEBUG `.elf` built from the *identical* source tree checked out
at a *different absolute path* is a *different file*, purely from path
length, unrelated to any real drift. Measured (stm32f103, two checkouts at
deliberately different-length paths): DEBUG `.elf` differed by exactly 20
bytes — the two paths' length delta — everywhere else identical. **RELEASE
(`-g0`, no debug info) is path-INDEPENDENT: 0-byte diff** between the same
two checkouts, so the gate that matters for the actually-committed tree
(RELEASE bin/hex/syms, `.elf` at tag time) is unaffected; only DEBUG's
manifest-recorded hashes are at risk, and only across a `build`/`check` run
from two different absolute paths (e.g. a contributor's machine vs. a CI
runner using a different checkout directory).

**Fix applied this batch**: every port's `Makefile` gained
`CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src`, remapping the embedded
path to a fixed, checkout-independent string. Verified cheap: RELEASE
`.bin`/`.hex` sha256 is UNCHANGED with the flag added (checked against
stm32f103, ch32v006, and dsPIC33AK's already-committed hashes) — RELEASE
has no debug info to remap, so there is nothing for the flag to change.
Verified effective: stm32f103's DEBUG `.elf` becomes fully byte-identical
(0-byte diff, was 20) across the two differently-pathed checkouts once the
flag is applied. **One caveat, stated rather than hidden**: on
`xc-dsc-gcc`, four locally-invoked translation units
(`platform.c`/`handlers.c`/`serial.c`/`nvmem.c`) still embed an absolute
path untouched by the flag (a toolchain quirk — the other ~16 translation
units in the same build ARE fully remapped), so dsPIC33AK's DEBUG `.elf` is
*improved* but not *fully* path-independent. This doesn't affect the actual
gate — dsPIC33AK's `.elf` is already exempt from hash comparison for the
unrelated tempfile-section-name reason above, so its DEBUG `.elf` hash was
never compared either way.

**Is `-ffile-prefix-map` still worth keeping, now that the owner has ruled
per-compile `.elf` variation a non-issue (storage, not a diffing target)?
KEEP — recommended, not removed.** The owner's ruling is about NOT chasing
byte-stability in the *committed* `.elf` for the sake of a clean `git diff`
on the binary itself — correct, and this is exactly why `.elf.dump` exists
now instead (a human-readable diff of the *disassembly*, not the raw
bytes). `-ffile-prefix-map` was never solving that problem. It solves a
different one: `tools/build_artifacts.py check` recomputes and compares a
DEBUG **hash** against `MANIFEST.sha256`, and without the flag that
comparison is path-dependent for a reason that has nothing to do with real
drift (`DW_AT_comp_dir`/absolute source paths embedded by `-g3`). This
project's actual workflow — a fresh git worktree per task, confirmed
repeatedly this batch (e.g. `.elf.dump`'s own line-1 path-echo, and the
dsPIC/stm32f103 rebuild-from-different-paths experiments above) — hits a
different absolute checkout path on nearly every `build`/`check` pair, so
without the flag the DEBUG-hash half of the ratchet would spuriously
report drift almost every time it runs, for zero actual content change.
That is a live correctness bug in an automated gate, not a "should this be
diffable" question, and the flag already costs nothing (verified zero-byte
change to RELEASE `bin`/`hex` when it was added). Dropping it would
reintroduce that spurious-failure risk for no storage saved — a compiler
flag has no repo-size cost either way. Recommendation: leave it in every
port's `Makefile` exactly as-is.

## Refresh policy

See ["Refresh policy" in `grbl/platform/PORTING-CHECKLIST.md`](../grbl/platform/PORTING-CHECKLIST.md#refresh-policy-when-to-re-run-toolsbuild_artifactspy-build)
for the full rule contributors are expected to follow. Short version:
refresh and commit `bin`/`hex`/`syms`/`elf.dump` whenever a port's *content*
changes (part of finishing that change, not a separate chore); do not
refresh on every push (most pushes are docs and don't move a single byte);
`tools/build_artifacts.py check` is the enforcement mechanism, not an honor
system. `.elf` is NOT part of this cadence — it's tag-time only, see
"Tagging a release" above; `.elf.dump` IS part of this cadence (continuous,
same as `bin`/`hex`/`syms`) despite sharing a name with the tag-gated file.

## Regenerating

```sh
# Everything (~10 units, several minutes: real cross-compiles, not cached).
# Ordinary refresh - copies bin/hex/syms/elf.dump, NOT .elf itself
# (see "Эльф на тегах" above):
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

Ten ports (eleven units, samd21 counted per board) built and are committed
here: `atmega328p`, `stm32f103`, `stm32h523`, `stm32f411`, `samd21`
(megarm + generic), `ch32v006`, `ch570`, `hc32f460`, `dspic33ak128mc102`,
`sg2002`. **Corrected — `sg2002` is present, not absent**: this section
previously said `sg2002` was "intentionally absent" because, at the time
it was written, PLAN.md Phase 6 still recorded it as design-complete/
implementation-deferred. That milestone has since landed —
`artifacts/sg2002/` is built, manifested in `artifacts/MANIFEST.sha256`,
and kept fresh by `tools/build_artifacts.py check` like every other unit
here (verified this pass: `sg2002` is one of the 11 units the check
covers, all fresh). The stale sentence was never updated when the port
shipped; do not resurrect it. `tools/build_artifacts.py`'s `UNITS` table
still probes each toolchain before building and prints `SKIPPED <port>:
toolchain not found ...` rather than failing the whole run if one is ever
missing in a future environment — the plumbing (Makefile flags,
DFP/TOOLCHAIN_PATH variables, nm binary selection) stays wired even when a
given machine can't exercise it; that mechanism is unrelated to sg2002
specifically and remains accurate as written.
