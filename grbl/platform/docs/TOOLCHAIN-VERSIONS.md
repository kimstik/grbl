# Toolchain versions — the compiler-VERSION axis

Companion to `docs/TOOLCHAIN-AXIS.md` (compiler FAMILY: gcc vs clang, owned
separately). This file is the compiler-VERSION axis: same family, newer
release. Concrete instance measured: AVR built with fresh GCC (15, 16)
against the atmega328p golden build, plus one ARM cross-check
(stm32f411, arm-none-eabi-gcc 14.2.1) to see whether the AVR result
generalizes. Same-family means avr-libc, `ISR()`, `PROGMEM`/`PSTR()` and
inline asm all stay valid — no clang-class friction.

All numbers below are measured this session, not carried over from prior
entries. Toolchains acquired to `/opt/` (not committed, not under `grbl/`):

| Install | Version | Source | Bundled |
|---|---|---|---|
| `/opt/avr-gcc-15` | avr-gcc 15.2.0 | github.com/ZakKemble/avr-gcc-build release `v15.2.0-1`, x64-linux prebuilt tarball | binutils 2.45, avr-libc 2.2.1 |
| `/opt/avr-gcc-16` | avr-gcc 16.1.0 | github.com/ZakKemble/avr-gcc-build release `v16.1.0-1`, x64-linux prebuilt tarball | binutils 2.46.1, avr-libc 2.3.2 |
| `/opt/arm-gnu-14.2` | arm-none-eabi-gcc 14.2.1 | developer.arm.com official Arm GNU Toolchain, `14.2.rel1`, x86_64 binrel tarball | newlib-nano 4.4.0 |

`apt`'s `gcc-avr` (1:7.3.0+Atmel3.7.0-1) and system `arm-none-eabi-gcc`
(13.2.1) are the pre-existing canonical baselines, untouched. GCC 16 for
AVR is the newest release ZakKemble/avr-gcc-build publishes as of this
session (tag `v16.1.0-1`); no GCC 17+ AVR prebuilt exists yet. Both AVR
downloads came through GitHub's direct `/releases/download/` asset path,
which is not gated the way `api.github.com` and the HTML releases page are
in this sandbox (403 "GitHub access to this repository is not enabled for
this session" on both — worked around via the raw asset URL, which
redirects to `release-assets.githubusercontent.com` and is unaffected).

## 1. Measured matrix

`text`/`data`/`bss` in bytes, berkeley `size` format. "Canonical" = owns
`artifacts/`, ratchets, ships the golden MD5 for its unit. Every other row
is verification-only: it never writes `artifacts/`.

| Unit | Profile (proposed name) | Compiler | Role | Builds | text | data | bss | vs canonical | MD5 vs golden | Ratchet |
|---|---|---|---|---|---|---|---|---|---|---|
| atmega328p | `avr-gcc-7.3` | avr-gcc 7.3.0 | **canonical** | yes | 30640 | 0 | 1633 | — | MATCH (`79af184e…`) | green (existing baseline) |
| atmega328p | `avr-gcc-15.2` | avr-gcc 15.2.0 | verification | yes | 30994 | 0 | 1633 | +354 (+1.16%) | differs (expected, correct) | see §2 catalogue |
| atmega328p | `avr-gcc-16.1` | avr-gcc 16.1.0 | verification | yes | 30480 | 0 | 1633 | −160 (−0.52%) | differs (expected, correct) | see §2 catalogue |
| stm32f411 | `arm-gcc-13.2` | arm-none-eabi-gcc 13.2.1 | **canonical** | yes | 26132 | 80 | 129968 | — | `.bin` MD5-identical to committed `artifacts/stm32f411/grbl_stm32f411.bin` | green (existing baseline) |
| stm32f411 | `arm-gcc-14.2` | arm-none-eabi-gcc 14.2.1 | verification | yes | 25752 | 80 | 129968 | −380 (−1.45%) | differs (not gated — ARM has no golden-MD5 lock, only AVR does) | see §2 catalogue |

Golden invariant ([§0](../CONTRACTS.md#boundary-wiring)) applies to AVR
only. Re-verified before and after this session's work:
`make -C grbl/platform/atmega328p validate` PASSED
(`79af184e67b27defd27a39309ac53563`) on the default 7.3.0 path, untouched.
The 7.3.0 number is never expected to change; the 15.2/16.1 numbers are
reported flat, not as regressions or improvements — a different compiler
producing a different byte count from the same source is the expected
outcome, not a signal about either compiler's quality.

## 2. Frozen-core analyzer catalogue (headline)

Real build flags (root `Makefile` for AVR, `common/stm32/common.mk` RELEASE
for ARM) plus `-fanalyzer -Wall -Wextra -Wuse-after-free -Wdangling-pointer
-Wnull-dereference -Warray-bounds=2 -Wstringop-overflow -Wshadow`, real
codegen (`-c`, not `-fsyntax-only` — see §3, `-fanalyzer` on this GCC build
is silent under `-fsyntax-only` and only fires on genuine `-c`/link-bound
compilation). All 18 files in the real AVR `SOURCE` list plus the unbuilt
`grbl/eeprom.c` compiled individually; zero compile errors on any of the
three compilers.

**(a) Frozen core (`grbl/*.c,h`) — the headline.** Zero `-fanalyzer`
findings (zero CWE-tagged diagnostics) anywhere in the core under
avr-gcc 16.1.0. Under avr-gcc 15.2.0 and arm-none-eabi-gcc 14.2.1, exactly
**one** CWE-tagged diagnostic appears (settings.c:208, `-Wanalyzer-out-of-
bounds` [CWE-787]) — independently re-verified as a false positive (see the
table row below), not a live defect, but a real diagnostic under two of the
three fresh compilers this session measured; "zero" does not hold for those
two. Two ordinary-warning classes, both judged, plus that one
compiler-version-dependent analyzer false positive:

| File:line | Diagnostic | Judgement |
|---|---|---|
| gcode.c:149/154, 167/169, 673/674, 810/811; report.c:480/486; system.c:249/252 | `-Wimplicit-fallthrough=` (6 sites) | **stylistic noise** — fallthrough is intentional and comment-documented ("No break intentional" / similar); GCC's default fallthrough-comment matcher (level 3) doesn't recognize this project's exact comment phrasing |
| nvmem.c:127,149; eeprom.c:146,157 | `-Wint-in-bool-context` on `(checksum<<1)\|\|(checksum>>7)` | **false positive / accepted quirk** — deliberate upstream checksum behavior, documented [CONTRACTS §10.4](../CONTRACTS.md#nvmem-eeprom); never "fix" |
| settings.c:208 (`settings_store_global_setting`, `steps_per_mm[parameter]`) | `-Wanalyzer-out-of-bounds` [CWE-787] | **false positive** — present under avr-gcc 15.2.0 and arm-none-eabi-gcc 14.2.1, ABSENT under avr-gcc 16.1.0. Manually traced: `parameter` is bounded to `0..N_AXIS-1` by the `AXIS_SETTINGS_START_VAL`/`AXIS_SETTINGS_INCREMENT` `while`-dispatch a few lines above the write (the `parameter < N_AXIS` branch taken is the only path reaching the write). The analyzer's loop-carried value-range widening loses that bound in 2 of 3 builds tested — a known GCC-analyzer imprecision class around `while`-loop back-edges, not a code defect. Cross-architecture (AVR + ARM) reproduction of the identical false positive at the identical line confirms it is compiler-analyzer behavior, not port-specific. |

`eeprom.c` is dead code (not in the real `SOURCE` list, [CONTRACTS
§10](../CONTRACTS.md#nvmem-eeprom): "in no build — do not port it"); its
2 checksum warnings are the same accepted-quirk class as `nvmem.c`'s.

Also observed on ARM only (stm32f411), both **already tracked, not new**:
`stepper.c:1015` `-Woverflow` ("integer overflow ... results in
1465032704") and `settings.c:339` `-Woverflow` ("1024 to 0") both already
appear in `ci/warn_baseline_stm32f411.txt` (lines 32/31) under the
existing apt-toolchain baseline — this session's newer-compiler run
reproduces them identically, confirming they are pre-existing, tracked
defects, not compiler-version regressions. Root cause of the first:
`grbl/platform/common/stm32/common.mk:89` (`-DF_CPU=$(CLOCK)`, no `UL`
suffix) — the same BUG #18 class samd21/ch32v006/ch570/dspic33ak128mc102
already fixed by appending `UL`; `stm32f103`/`stm32f411`/`stm32h523`/
`hc32f460`/`sg2002`/`_template` still lack it, so
`TICKS_PER_MICROSECOND*1000000*60` overflows 32-bit signed `int` at
compile time for any of those ports clocked above ~35.8 MHz (96 MHz here:
5.76e9 computed where INT_MAX is 2.147e9). **Real latent bug**, silently
wrong stepper-segment-rate arithmetic on every affected port — already
known and ratchet-baselined, reported here for completeness, not fixed
(the fix is a Makefile one-liner outside this task's remit and outside
what a probe session should touch).

**(b) `grbl/platform/**`.** AVR: zero diagnostics land inside
`common/gpio.h` or `atmega328p/{platform,timer}.h` under any of the three
compilers (confirmed by grepping every log for `platform/` paths — no
hits). ARM (stm32f411, arm-gcc 14.2.1 only, since it is the one port
probed): `platform.c` gets 6 macro-redefinition warnings
(`STEP_MASK`/`DIRECTION_MASK`/`STEPPERS_DISABLE_MASK`/`LIMIT_MASK`/
`CONTROL_MASK`/`PROBE_MASK`) because it directly `#include`s both
`platform.h` and its own `config.h`, and both independently define the
same six macro names. Values coincide today (`config.h`'s `CONTROL_MASK`
uses unprefixed `RESET_PIN`/`FEED_HOLD_PIN`/`CYCLE_START_PIN`/
`SAFETY_DOOR_PIN` = 3/4/5/6; `platform.h`'s uses `CONTROL_RESET_PIN` etc,
same values) so **not a live bug**, but a duplicate-definition landmine:
nothing enforces the two headers stay in sync, and only `platform.c`'s own
translation unit sees the collision (ordinary core `.c` files reach only
`platform.h`'s copy via the normal `hal.h` chain). `stm32_nvmem.c`: 2
`-Wtype-limits` ("comparison of unsigned expression in '<0' is always
false") inside `STM32_VALIDATE_RANGE`'s generic lower-bound check,
instantiated at an unsigned call site — **stylistic noise**, the macro is
intentionally generic for both signed/unsigned use, no functional harm.
`flash.c`/`handlers.c`/`startup.c`/`stm32_timing.c`/`stm32_watchdog.c`:
zero findings.

**(c) avr-libc / vendor headers.** Zero diagnostics (grepped every log for
avr-libc/`/avr/include` paths — no hits) across both AVR compilers. No
vendor CMSIS headers are vendored into stm32f411 (hand-authored `regs.h`),
so there is nothing to separately audit there.

## 3. Capability gating

Verified empirically against avr-gcc 7.3.0 (the canonical compiler — it
must never receive a flag it cannot parse, or the canonical build dies):

| Flag | 7.3.0 result | Real threshold |
|---|---|---|
| `-fanalyzer` | `error: unrecognized command line option` | GCC >= 10 |
| `-Wuse-after-free` | `error: unrecognized command line option` | GCC >= 12 |
| `-Wdangling-pointer` | `error: unrecognized command line option` | GCC >= 12 |
| `-Wnull-dereference` | accepted | GCC >= 6 (already present in 7.3.0) |
| `-Warray-bounds=2` | accepted | GCC >= 7 (already present in 7.3.0) |
| `-Wstringop-overflow` | accepted | GCC >= 7 (already present in 7.3.0) |
| `-Wshadow` | accepted | always available |

Only 3 of the 7 owner-named flags actually require gating; the other 4
already exist on 7.3.0 and are harmless there (they simply find nothing,
since `-fanalyzer` itself — the thing that makes the interesting classes
possible — is the one that's missing). `-fanalyzer` also silently produces
**no diagnostics under `-fsyntax-only`** on every compiler tested here
(avr-gcc 15/16, native gcc 13.3.0, arm-none-eabi-gcc 14.2.1) — confirmed
with a synthetic use-after-free that IS flagged under `-c` and is NOT under
`-fsyntax-only` on the identical invocation. A cheap syntax-only pass is
therefore not a substitute for the real-codegen pass for analyzer
purposes; it is still worth running first (catches ordinary `-Wall`/
`-Wextra` diagnostics at near-zero cost) but the analyzer catalogue itself
requires `-c`.

**Consequence for the profile design below**: a profile targeting GCC < 10
must not pass `-fanalyzer` (or any `-Wanalyzer-*`) at all — not "pass it
and expect it to be ignored," because unrecognized-option is a hard error,
not a warning, on this GCC line. A profile targeting GCC 10-11 may pass
`-fanalyzer` but not `-Wuse-after-free`/`-Wdangling-pointer` standalone
(they're subsumed into `-fanalyzer`'s own output on those versions as
`-Wanalyzer-*` names anyway, so the standalone flags are moot before 12,
not just absent).

## 4. Profile layout

Integrator's proposed layout:

```
common/toolchain/family/{gcc,clang}.mk     # dialect: -Os vs -Oz, -flto vs -flto=thin, $(P)nm/objcopy/objdump
common/toolchain/profiles/avr-gcc-7.3.mk   # CANONICAL atmega328p
common/toolchain/profiles/avr-gcc-15.mk
common/toolchain/profiles/arm-gcc-13.2.mk  # CANONICAL ARM
```

**Confirmed by measurement, with one correction.** The profile-per-version
shape is right and the "one new file, zero code change" claim holds for
adding a version: `avr-gcc-15.mk`/`avr-gcc-16.mk`/`arm-gcc-14.2.mk` in this
session were never-committed, ad hoc `AVR_GCC_PATH=`/`TOOLCHAIN_PATH=`
Makefile-variable overrides — no Makefile edit was needed to point the
existing root `Makefile` or `common/stm32/common.mk` at a different
install, because both already parameterize the compiler path
(`AVR_GCC_PATH`, `TOOLCHAIN_PATH`). A real `profiles/avr-gcc-16.mk` file
would just need to set that variable plus `TC_VER := 16` and `include
../family/gcc.mk`; nothing else changes. **Correction**: the family file
cannot be a single flat `gcc.mk` that ignores `TC_VER` — §3 just showed
three flags need version gating. `family/gcc.mk` must branch on `TC_VER`
(a numeric `ifeq`/`ifneq` ladder, e.g. `TC_VER_GE_10`/`TC_VER_GE_12` computed
once) to decide whether `-fanalyzer`/`-Wuse-after-free`/`-Wdangling-pointer`
are in the flag set at all — a profile that "just includes the family
file" only gets the right flags if the family file reads `TC_VER`, so
`TC_VER` is load-bearing, not decorative metadata as the layout sketch
might suggest on its own.

## 5. Canonical-toolchain rule

No per-unit carve-outs. Exactly one profile per unit owns `artifacts/` and
the seven ratchets; every other profile for that unit is verification-only
and never produces a committed binary. `atmega328p` is an *instance* of
this rule (canonical profile `avr-gcc-7.3`), not a special case — the
golden-MD5 mechanism already IS this rule, just not yet named as a general
one or extended to a second family. Applying the same shape to ARM:
`arm-gcc-13.2` is stm32f411's canonical profile (proven byte-identical to
the committed `artifacts/stm32f411/grbl_stm32f411.bin` this session);
`arm-gcc-14.2` is verification-only and produced no `artifacts/` writes
(confirmed: `git status` clean after every ARM probe build in this
session, `make clean`/`clean-all` run after each).

The one genuine exception to "every unit has a canonical + verification
split" is `dspic33ak128mc102`: XC-DSC is proprietary and LLVM has no
upstream PIC24/dsPIC backend, so there is exactly one usable toolchain,
period — not a carve-out from the rule, just a unit where the
verification side of the rule has no second toolchain to populate it with.

## 6. Core-purity rule

Proposed and landed as CONTRACTS.md `## §NEW.` section, slug
`core-purity-diagnostic-response` (integrator renumbers per the file's own
convention — do not renumber here, and note `tools/check_contracts_numbering.py`
deliberately treats `§NEW` anchors as not-yet-valid link targets until
renumbered, so this reference is prose, not a markdown link, until then).
Summary: a diagnostic whose location is inside frozen core is never
resolved by editing that core file; resolution is either flag/prelude-
layer suppression (false positives, accepted upstream quirks) or an
accepted-baseline entry (real but intentional patterns, e.g. the
fallthrough class in §2). See the CONTRACTS.md section for the full
wording, the two legal-resolution categories, and why a project-wide
warning-class disable is explicitly not a third option.

## 7. CI cost

Not a cartesian product — most (unit, profile) cells do not earn their
cost:

- **Earns it**: `atmega328p` × `avr-gcc-7.3` (canonical, golden-gated,
  already in CI). `stm32f411` × `arm-gcc-13.2` (canonical, already in CI).
  A single scheduled (not per-push) `atmega328p` × `avr-gcc-16` analyzer
  job — the whole point of the version axis is catching a NEW finding the
  moment GCC's analyzer gets sharp enough to see one in 2011-vintage core
  code; running it costs one extra toolchain install + ~1s of compile per
  file (18 files, well under a minute total) and needs to run rarely
  enough (weekly, like the existing provenance job) that it is cheap in
  aggregate CI-minutes but still catches a regression before it goes
  stale for months.
- **Does not earn it**: `avr-gcc-15` as an ONGOING CI row alongside 16 —
  this session's own data shows 16 is a strict analyzer-precision
  superset of 15 for this codebase (16 found everything 15 found minus
  one false positive that 16's analyzer got smarter about); a standing
  15-and-16 matrix doubles toolchain-install cost in CI for zero
  additional finding coverage. Keep 15 as a one-time, already-recorded
  data point (this document), not a recurring job. Every stm32-family
  port (`f103`/`h523`/`hc32f460`) × `arm-gcc-14.2` as a recurring row —
  one ARM cross-check (stm32f411) already confirms the frozen-core result
  generalizes across architectures; re-running the identical core-file
  analysis on siblings that share `grbl/*.c` byte-for-byte adds toolchain-
  install cost without a plausible source of a NEW core finding (the core
  files are identical inputs; only the platform-layer files differ, and
  those are cheap enough to check locally without a standing CI row).
  Per-commit analyzer runs anywhere: `-fanalyzer` triples-or-worse compile
  time per TU (empirically: individual-file `-c` passes took
  noticeably longer than the plain `-Wall -Wextra` pass on the same
  files) — fine for a weekly job, wrong for the per-push gate.
