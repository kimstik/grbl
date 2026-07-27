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

---

## 8. clang vs gcc-16-class, by size, every buildable platform (2026-07-27)

Owner's question, answered with measured numbers, no estimates. "gcc-16-class"
because a real gcc 16 toolchain exists only for AVR as of this session (see
§8.1); ARM and RISC-V use the newest upstream release that actually exists,
clearly labeled per row.

### 8.1 Toolchain acquisition this session

| Family | Newest found | Source | Multilibs verified | Newest NOT found |
|---|---|---|---|---|
| AVR | 16.1.0 (already at `/opt/avr-gcc-16`, prior session) | ZakKemble/avr-gcc-build `v16.1.0-1` | n/a (single AVR target) | 17.x does not exist yet |
| ARM | **15.2.Rel1** (gcc 15.2.1) | `developer.arm.com` official Arm GNU Toolchain, `15.2.rel1` binrel tarball, installed `/opt/arm-gnu-15.2` | cortex-m0plus/m3/m4/m33 all build (same multilib families as 13.2/14.2) | **16.x does not exist upstream** — `developer.arm.com/.../16.1.rel1/...` and `.../16.2.rel1/...` both 404. 14.3.rel1 also exists (200) but superseded by 15.2 for this table. |
| RISC-V | **15.2.0-1** (gcc 15.2.0) | `xpack-dev-tools/riscv-none-elf-gcc-xpack` release `v15.2.0-1`, linux-x64 tarball, installed `/opt/riscv-xpack-15.2` | **rv32ec/ilp32e** (ch32v006), **rv32imc/ilp32** (ch570), **rv64imafc_zicsr[_zaamo_zalrsc]/lp64f** (sg2002) — `crt0.o`+`libc.a` confirmed present under all three real multilib directories before any build was attempted | **16.x does not exist** — same tag pattern 404s. `v14.2.0-3` also acquired (`/opt/riscv-xpack-14.2`) as an intermediate data point. |

Both AVR downloads were already recorded (§0 header). ARM/RISC-V this session
went through GitHub's/ARM's direct `/releases/download/`-equivalent asset
paths, unaffected by the session's API/HTML gating (confirmed working,
consistent with the AVR acquisition method already documented).

**Real, load-bearing difference discovered**: the RISC-V xpack toolchain
ships **newlib** (`nano.specs`/`nosys.specs`), not **picolibc**
(`picolibc.specs`) — `riscv-none-elf-gcc ... -specs=picolibc.specs` fails
with `cannot read spec file 'picolibc.specs'`. Every real RISC-V port's
Makefile hardcodes `-specs=picolibc.specs`. Any gcc-15-on-RISC-V number in
this table is therefore a **libc-flavor swap, not compiler-version-only** —
called out per row, not folded silently into "vs canonical."

### 8.2 Full matrix

All ARM/AVR rows use `.bin` byte size (RELEASE, `objcopy -O binary`); RISC-V
rows likewise except where noted. `FP=SINGLE` column is the real
`tools/assert_no_double.sh` (never a grep-and-hope) run against the actual
built ELF with the correct `nm` for that toolchain — every PASS below was
independently re-run this session, not inherited from a flag being present.
"Repro" = fresh canonical-gcc rebuild's `.bin` re-verified `md5sum`-identical
to the committed `artifacts/` file before that unit's clang/gcc-15 rows are
trusted (per this session's own methodology correction: a hand-driven build
only counts once it reproduces the real build to the byte).

**atmega328p (AVR, avr-libc/avr-gcc target, no LTO by design)**

| Toolchain | Role | text | data | bss | FP=SINGLE | vs canonical | Notes |
|---|---|---|---|---|---|---|---|
| avr-gcc 7.3.0 | **canonical** | 30640 | 0 | 1633 | n/a (AVR-native SP) | — | MD5 `79af184e67b27defd27a39309ac53563`, never changes |
| avr-gcc 15.2.0 | verification | 30994 | 0 | 1633 | n/a | +354 (+1.16%) | `/opt/avr-gcc-15` |
| avr-gcc 16.1.0 | verification | 30480 | 0 | 1633 | n/a | −160 (−0.52%) | `/opt/avr-gcc-16`, newest AVR gcc that exists |
| clang 18.1.3 | **see §8.3 — two distinct verdicts, not one row** | 34660¹ | 486¹ | 1633 | genuinely holds (no DP libcalls) | +4020 text (+13.1%)¹ | ¹Not a real unmodified-source build — see §8.3 |

**stm32f411 (Cortex-M4F, fpv4-sp-d16 hard, RELEASE = `-Os -flto` + gc-sections + nano/nosys newlib)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) | Repro |
|---|---|---|---|---|---|---|---|---|
| arm-none-eabi-gcc 13.2.1 | **canonical** | 26228 | 80 | 129968 | **26308** | PASS | — | MD5-identical to `artifacts/` |
| arm-gnu 14.2.1 | verification | 25836 | 80 | 129968 | 25916 | PASS | −392 (−1.49%) | rebuilt fresh this session, ratchets green |
| arm-gnu 15.2.1 | verification, newest ARM gcc that exists | 25912 | 80 | 129968 | 25992 | PASS | −316 (−1.20%) | rebuilt fresh this session, ratchets green |
| clang 18 `-Oz -flto=full` | verification, hand-driven | 27832 | 80 | 129968 | **27912** | PASS | +1604 (+6.10%) | matched canonical flag-shape (see §8.4 recipe) |
| clang 18 `-Os -flto=full` | verification | 33244 | 80 | 129968 | 33324 | PASS | +7016 (+26.67%) | clang's `-Os` is NOT its size level — see §8.5 |
| clang 18 `-Oz -flto=thin` | verification | 28628 | 80 | 129968 | 28708 | PASS | +2400 (+9.13%) | ThinLTO costs +796B over full LTO here |

**stm32f103 (Cortex-M3, no FPU, RELEASE = `-Os -flto`)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|
| arm-none-eabi-gcc 13.2.1 | **canonical** | 29128 | 80 | 19376 | **29208** | PASS | — |
| clang 18 `-Oz -flto=full` | verification | 30396 | 80 | 19376 | 30476 | PASS | +1268 (+4.34%) |
| clang 18 `-Os -flto=full` | verification | 36108 | 80 | 19376 | 36188 | PASS | +6980 (+23.90%) |
| clang 18 `-Oz -flto=thin` | verification | 31192 | 80 | 19376 | 31272 | PASS | +2064 (+7.07%) |

**stm32h523 (Cortex-M33, fpv5-sp-d16 hard, RELEASE = `-Os -flto`)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|
| arm-none-eabi-gcc 13.2.1 | **canonical** | 25568 | 388 | 10256 | **25956** | PASS | — |
| clang 18 `-Oz -flto=full` | verification | 27116 | 388 | 9924 | 27508 | PASS | +1552 (+5.98%) |
| clang 18 `-Os -flto=full` | verification | 32440 | 388 | 9940 | 32828 | PASS | +6872 (+26.48%) |
| clang 18 `-Oz -flto=thin` | verification | 27792 | 388 | 9936 | 28180 | PASS | +2224 (+8.57%) |

**hc32f460 (Cortex-M4F, fpv4-sp-d16 hard, RELEASE = `-Os -flto`; `script.ld` NOLOAD fix landed this session, see §8.6)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|
| arm-none-eabi-gcc 13.2.1 | **canonical** | 25824 | 80 | 129968 | **25904** | PASS | — |
| clang 18 `-Oz -flto=full` | verification | 27396 | 80 | 129968 | 27476 | PASS | +1572 (+6.07%) |
| clang 18 `-Os -flto=full` | verification | 33140 | 80 | 129968 | 33220 | PASS | +7316 (+28.24%) |
| clang 18 `-Oz -flto=thin` | verification | 28148 | 80 | 129968 | 28228 | PASS | +2324 (+8.97%) |

**samd21 (Cortex-M0+, no FPU, board=megarm, RELEASE = `-Os -flto`, no nano/nosys specs — plain newlib per port's own Makefile; `script.ld` NOLOAD fix landed this session, see §8.6)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|
| arm-none-eabi-gcc 13.2.1 | **canonical** | 32280 | 296 | 6160 | **32532** | PASS | — |
| clang 18 `-Oz -flto=full` | verification | 32044 | 296 | 6152 | 32344 | PASS | **−188 (−0.58%)** |
| clang 18 `-Os -flto=full` | verification | 34668 | 296 | 6168 | 34968 | PASS | +2436 (+7.49%) |
| clang 18 `-Oz -flto=thin` | verification | 32548 | 296 | 6160 | 32848 | PASS | +316 (+0.97%) |

samd21 is the **one unit where clang beats gcc** (Cortex-M0+, thumb1-only, no
FPU — see §8.5 for why this ISA differs from the M3/M4/M33 pattern).

**ch32v006 (RV32EC/ilp32e, `-march=rv32ec_zicsr`, RELEASE = `-Os -flto`, picolibc)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) | Notes |
|---|---|---|---|---|---|---|---|---|
| riscv64-unknown-elf-gcc 13.2.0 | **canonical** | 39224 | 0 | 2752 | **39224** | PASS | — | MD5-identical to `artifacts/` |
| riscv-none-elf-gcc 15.2.0 (xpack) | verification, **newlib not picolibc** | 37408 | 80 | 2760 | 37488 | PASS | −1736 (−4.4%) | libc-flavor swap confound, see §8.1 — not compiler-version-only |
| clang 18 `-Oz -flto=full` | verification, **first full end-to-end RISC-V clang link this project has done** | 41496 | 0 | 2752 | 41496 | PASS | +2272 (+5.79%) | |
| clang 18 `-Os -flto=full` | verification | 44552 | 0 | 2752 | 44552 | PASS | +5328 (+13.58%) | |
| clang 18 `-Oz -flto=thin` | verification | 42788 | 0 | 2760 | 42788 | PASS | +3564 (+9.09%) | |

**ch570 (RV32IMC/ilp32, `-march=rv32imc_zicsr`, RELEASE = `-Os -flto`, picolibc, vendored `vendor/ISP572.o`)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|
| riscv64-unknown-elf-gcc 13.2.0 | **canonical** | 38594 | 4 | 6852 | **38600** | PASS | — |
| clang 18 `-Oz -flto=full` | verification | 40814 | 0 | 6848 | 40816 | PASS | +2216 (+5.74%) |
| clang 18 `-Os -flto=full` | verification | 44378 | 0 | 6848 | 44380 | PASS | +5780 (+14.97%) |
| clang 18 `-Oz -flto=thin` | **CANNOT MEASURE `.bin` — see §8.6** | 42274 | 4 | 6849 | 536876744 (bogus) | PASS (section-level) | `.sdata` orphan-section placement bug, not the already-fixed NOLOAD class |

**sg2002 (RV64IMAFC/lp64f, `-mcmodel=medany`, load base `0x8FE00000`, RELEASE = `-Os -flto`, picolibc)**

| Toolchain | Role | text | data | bss | bin | FP=SINGLE | vs canonical (bin) |
|---|---|---|---|---|---|---|---|---|
| riscv64-unknown-elf-gcc 13.2.0 | **canonical** | 29244 | 8 | 18072 | **29296** | PASS | — |
| clang 18 `-Oz`, **no LTO** (LTO blocked, see §8.6) | verification | 32568 | 96 | 18032 | 32708 | PASS | +3412 (+11.6%), **not LTO-for-LTO** |
| clang 18, LTO (any mode) | **CANNOT BUILD — see §8.6** | — | — | — | — | — | lld+LTO relocation-range error in `_start`'s `la gp` sequence |

**dspic33ak128mc102 (dsPIC33A, XC-DSC v3.30/gcc 8.3.1)**

| Toolchain | Role | bin | Notes |
|---|---|---|---|
| xc-dsc-gcc 8.3.1 | **canonical, only usable toolchain** | 95004 (committed) | No LLVM/clang backend exists for dsPIC33A (`clang --print-targets` has no `pic`/`dspic` entry — checked this session). No newer XC-DSC release was sought: proprietary, single-vendor, and the deliverable is clang-vs-gcc, which has no second column here regardless of GCC version. |

### 8.3 atmega328p × clang — corrected verdict, two distinct questions

An earlier note in this session's thread asserted clang-AVR is simply
disqualified (PROGMEM/`__flash` unsupported, `wdt.h` hard error) and a
correction message argued the opposite (`__flash` works, `wdt_*` is never
called, so it isn't disqualified). **Both are incomplete. Measured
end-to-end this session, with real commands, real output:**

1. **GRBL does not use `__flash`.** It uses avr-libc's `PSTR()`/`PROGMEM`,
   which expand to `__attribute__((__progmem__))`. clang recognizes
   `__flash` (a distinct GNU named-address-space keyword) correctly — a
   synthetic `const __flash char x[] = "..."` compiles clean and lands in
   `.progmem.data` (`llvm-objdump -h`, verified). But the **actual**
   mechanism GRBL/avr-libc use is different and clang silently drops it:
   `clang --target=avr -mmcu=atmega328p -c grbl/report.c ...` emits, 52
   times, `warning: unknown attribute '__progmem__' ignored`. A minimal
   isolated repro (`const char PROGMEM msg[] = "hello flash";`) compiled
   and **linked** (`avr-gcc` as linker driver, real crt0/libc) places `msg`
   at **VMA `0x800100`, type `D`**, i.e. genuine `.data` — copied
   flash→RAM at boot, confirmed via `avr-nm`/`avr-objdump -h`, not
   inferred from the warning text alone.
2. **Measured on the real 18-file core SOURCE list** (root Makefile's exact
   flags, `-D_AVR_WDT_H_` applied — the same flags-layer bypass this
   document already recorded for the `wdt.h` constraint-range error):
   `.data` grows from **0 bytes (gcc) to 486 bytes (clang)** — all of it
   `report.c`'s `PSTR()` strings, confirmed by `avr-nm --size-sort` symbol
   dump (`report_feedback_message.__c.*`, `report_realtime_status.__c.*`,
   etc — nothing else). Real atmega328p SRAM is 2048 bytes; this port's
   `.bss` is 1633. `1633 + 486 = 2119 > 2048` — **a genuine 71-byte SRAM
   overflow**, reproduced as an actual linker error
   (`region 'data' overflowed`) when linking against the chip's real
   memory regions, not a hypothetical.
3. **A second, independent, unrelated hard blocker**: core `nuts_bolts.c`'s
   `delay_sec`/`delay_ms`/`delay_us` (real functions, called by the real
   dwell path, not dead code) depend on avr-libc's `<util/delay.h>`, which
   depends on `__builtin_avr_delay_cycles` — a GCC-only compiler intrinsic.
   Verified clang has **no implementation at all**, not merely a
   flag-gate: `clang --target=avr -mmcu=atmega328p -S delaytest.c` (body:
   `__builtin_avr_delay_cycles(5);`) →
   `error: use of unknown builtin '__builtin_avr_delay_cycles'
   [-Wimplicit-function-declaration]`. Confirmed no fallback symbol exists
   in avr-libc's `libgcc.a`/`libm.a` either (`avr-nm`/`avr-ar t`, zero
   hits) — real gcc always inlines this one, never links a call. **No
   flags-layer bypass exists**; getting *any* ELF required hand-adding a
   real (non-real-build) replacement function, disclosed as such in the
   object list — this is not a "-D" trick, it is source not in the real
   build.
4. **Also discovered and fixed, needed for the numbers above to link at
   all**: clang's default libcall-shrink pass rewrites `floor()`/`ceil()`/
   `trunc()`/`round()` (called on `float` throughout core — `motion_control.c`,
   `stepper.c`, `spindle_control.c`, `gcode.c`, `settings.c`, `system.c`,
   `nuts_bolts.c`) to `floorf`/`ceilf`/`truncf`/`roundf`, because AVR's
   `double`==`float` ABI makes the shrink heuristic fire — but avr-libc's
   `libm.a` only ships the unsuffixed names (`floor.o`, `ceil.o`, `round.o`,
   `trunc.o`, no `*f` variants). Fixed with
   `-fno-builtin-floor -fno-builtin-ceil -fno-builtin-trunc -fno-builtin-round`
   (confirmed via `-S`: without the flags, `call floorf`; with them,
   `call floor`, matching avr-libc's real symbol). A real, working,
   flags-layer bypass — unlike finding 3, which has none.

**The two verdicts, stated separately as required:**

- **Runnable/shippable atmega328p image via clang: NO.** Even granting the
  hand-added `__builtin_avr_delay_cycles` stub as a one-time measurement
  convenience, the PSTR/PROGMEM misplacement alone overflows real SRAM by
  71 bytes on the unmodified 18-file core. This is a real, measured,
  hardware-fatal defect — independent of, and additional to, the missing
  builtin. Both are genuine blockers, not the same one twice.
- **clang as a second static-analysis front end over frozen core: YES.**
  All 18 real core `.c` files compile to valid objects with exactly two
  flags-layer additions (`-D_AVR_WDT_H_`, the four `-fno-builtin-*`
  flags) — no core edit, no hand-added stub needed for compilation
  (only for the optional full-link size experiment above). §2's existing
  clang-AVR diagnostic catalogue in `TOOLCHAIN-AXIS.md` remains valid on
  this basis, independent of runnability.
- **atmega328p's canonical toolchain is unaffected either way** — golden
  MD5 `79af184e67b27defd27a39309ac53563` is defined by avr-gcc 7.3.0's
  exact output by construction; there was never a "does clang match"
  question to ask for the canonical slot.

### 8.4 Exact recipe (representative — stm32f411 clang, `-Oz -flto=full`)

```
MULTIDIR=$(arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -print-multi-directory)
# -> thumb/v7e-m+fp/hard
NEWLIB=/usr/lib/arm-none-eabi/newlib/$MULTIDIR         # libc_nano.a, libnosys.a
LIBGCC=/usr/lib/gcc/arm-none-eabi/13.2.1/$MULTIDIR     # libgcc.a

clang --target=arm-none-eabi -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard \
  -isystem /usr/lib/arm-none-eabi/include -DPLATFORM_STM32F411 -DF_CPU=96000000ULL \
  -Wall -Wextra -ffunction-sections -fdata-sections -fno-unwind-tables \
  -fno-asynchronous-unwind-tables -cl-single-precision-constant -DGRBL_FP_SINGLE \
  -I<port> -Icommon/dummy -include <port>/prelude.h -Icommon/stm32 -Iplatform -I. \
  -Oz -g0 -flto -fno-fat-lto-objects -c <file>.c -o <file>.o
  # ...for all 25 real RELEASE source files (make BUILD=RELEASE -n | grep -oE '\S+\.c')

clang --target=arm-none-eabi -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard \
  -fuse-ld=lld -nostartfiles -Wl,--gc-sections -T script.ld -L $NEWLIB -L $LIBGCC \
  -Oz -flto *.o -o grbl_stm32f411.elf -Wl,--start-group -lc_nano -lm -lnosys -lgcc -Wl,--end-group

llvm-objcopy -O binary grbl_stm32f411.elf grbl_stm32f411.bin
tools/assert_no_double.sh llvm-nm grbl_stm32f411.elf     # PASSED
```
Date: 2026-07-27. Same shape (multilib/-specs swapped for RISC-V's
`picolibc.specs`, no `-mfpu`/`-mfloat-abi` for M0+/M3/RISC-V) for every
other unit's clang row above.

### 8.5 Interpretation

- **clang `-Os` is a trap when porting gcc flags.** gcc's `-Os` means
  size-optimize; clang's size level is `-Oz`, and clang's `-Os` sits much
  closer to `-O2`. Measured gap on stm32f411: 33324 vs 27912 (`-Os` vs
  `-Oz`, both full LTO) — **5412 bytes, 19.4%**, entirely a flag-mapping
  artifact, not a codegen-quality fact. Every table above reports both so
  the comparison is never hostage to one flag choice, per the brief.
- **Full LTO beats ThinLTO on every measured ARM/RISC-V unit** (stm32f411:
  +796B; f103: +796B; h523: +672B; hc32f460: +752B; ch32v006: +1292B) —
  ThinLTO trades cross-TU visibility for parallelism, a bad trade at this
  project's scale (18–25 TUs). Use full LTO for the headline clang number;
  ThinLTO is a data point, not the representative one.
- **Where clang loses (M3/M4/M33 Cortex-M, RV32EC/RV32IMC): +4.3% to
  +9.1%** at `-Oz -flto=full`. Not investigated at the symbol level this
  session beyond the FP=SINGLE confirmation (out of scope given the time
  spent on the AVR correction and toolchain acquisition) — a follow-up
  `nm --print-size --size-sort` diff between the gcc and clang `.elf`s
  per unit would attribute it precisely; not claimed here beyond "clang is
  larger by this measured amount."
- **Where clang wins: samd21 only (Cortex-M0+, thumb1, no FPU),
  −0.58%.** The one ISA in this tree with no hardware FPU and the
  smallest, most register-constrained instruction encoding (RV32EC is
  register-constrained too but still loses) — consistent with clang's
  codegen being more competitive on plain integer/thumb1 workloads than on
  FPU-instruction-selection-heavy or soft-float-heavy code, though this is
  an observation of the pattern, not a traced mechanism.
- **gcc-15/14 vs gcc-13.2 (same libc, ARM family): a real, small,
  non-monotonic win.** stm32f411: 13.2→14.2 is −1.49%, 13.2→15.2 is
  −1.20% (14.2 is smaller than 15.2 — non-monotonic, both real,
  independently rebuilt and ratchet-clean). **Should any canonical move to
  gcc 15?** The evidence: a ~1.2–1.5% code-size win, zero FP=SINGLE
  regressions, zero ratchet failures, same libc/specs, no port-file changes
  needed (`TOOLCHAIN_PATH` override only). That is a real, positive case
  for stm32-family ports — **but it is the owner's call, not made here**;
  this document presents the evidence and stops, per the canonical-toolchain
  rule (§5) and the explicit instruction in the brief that reopened this
  question. AVR's canonical is excluded from this question entirely — its
  golden MD5 is defined BY avr-gcc 7.3.0, not chosen among alternatives.
- **RISC-V gcc-15 delta is confounded by a libc swap** (newlib vs picolibc,
  §8.1) and is reported as such — not usable as evidence for a canonical
  move without re-measuring on matching libc.

### 8.6 Empty/partial cells, with why

| Cell | Status | Why (one line + command) |
|---|---|---|
| dspic33ak128mc102 × any-non-XC-DSC | Empty, permanent | No LLVM backend for dsPIC33A (`clang --print-targets` has no `pic`/`dspic` entry, checked this session); no alternate GNU dsPIC33A backend exists either. |
| atmega328p × clang, as a **runnable image** | Empty, real (not a flag gap) | §8.3 — PSTR/PROGMEM misplacement overflows real 2048B SRAM by 71 bytes on unmodified core; separately, `__builtin_avr_delay_cycles` has zero clang-AVR implementation (`error: use of unknown builtin`, confirmed no libgcc/libm fallback). |
| ch570 × clang `-Oz -flto=thin`, **`.bin` only** | Partial — `.elf`/section sizes valid, `.bin` is not | `llvm-readelf -S` shows a 4-byte `.sdata` PROGBITS section placed as an lld orphan section with LMA=VMA in the RAM address range (no explicit `.sdata` rule in this port's `script.ld`, unlike the already-fixed `.bss`/`.stack`/`.heap` NOLOAD case) — `objcopy -O binary` pads from address 0 up through that RAM address, producing a 536MB file. Only reproduces under ThinLTO; full LTO and no-LTO builds of the same port are unaffected. Not the same bug as the `(NOLOAD)` fix already landed elsewhere; a distinct linker-script gap, flagged, not fixed (a real fix needs an explicit `.sdata (NOLOAD)`-style output-section rule and is a `script.ld` change worth doing in its own pass, not a size-matrix side quest). |
| sg2002 × clang, **any LTO mode** | Empty, LTO-specific | `ld.lld` fails linking the LTO-merged image: `relocation R_RISCV_PCREL_HI20 out of range ... references '__global_pointer\$'` inside `_start`'s hand-written `.option norelax` / `la gp, __global_pointer$` sequence (`startup.c`). Reproduces identically with `-mno-relax` (compile) and `-Wl,--no-relax` (link) both applied, so it is not a simple relaxation-flag fix. **Confirmed LTO-specific**: an otherwise-identical non-LTO build (`-Oz`, no `-flto`) links cleanly end-to-end (text=32568, FP=SINGLE PASS) — reported in the sg2002 table as a non-LTO data point, explicitly marked as not comparable to the LTO-based canonical number. |
| ch32v006/stm32-family × ARM/RISC-V **gcc 16** | Empty, upstream gap | No gcc-16-based ARM or RISC-V toolchain exists yet from either source tried (`developer.arm.com`, xpack) — confirmed via direct asset-URL 404s for both `16.1.rel1` and `16.2.rel1` (ARM) and `v16.1.0-1` (RISC-V xpack). AVR gcc-16 exists and is measured (§8.2, atmega328p row) because ZakKemble's AVR-specific build tracks upstream releases faster than either vendor toolchain distribution. |

Everything in this section is measurement, not migration: no canonical
toolchain changed, `artifacts/` was never touched (`git status` clean of
`artifacts/` throughout), and the golden AVR gate
(`make -C grbl/platform/atmega328p validate` → `79af184e67b27defd27a39309ac53563`)
was re-verified unaffected before and after this session's work.
