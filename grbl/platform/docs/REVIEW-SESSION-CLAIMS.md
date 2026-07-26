# Adversarial Review — Session Claims A-F (2026-07-26)

Reviewer: adversarial audit agent, worktree `worktree-agent-a04012c9b772985f9` @ f681454
(fast-forwarded from a stale eefe2bb via `git merge --ff-only claude/samd21-port-01MYdHT6QaxWVxdRvWQFHuPi`,
no other tree changes). Working directory throughout:
`/home/user/grbl/.claude/worktrees/agent-a04012c9b772985f9`.

Status key: REFUTED / SURVIVES / UNVERIFIED. Findings ranked most-severe first inside each claim.

(This file is being built incrementally; committed after each claim closes so a session
limit does not lose work.)

---

## Claim A — "Zero `-fanalyzer` findings anywhere in `grbl/*.c`" (avr-gcc 16.1.0, arm-none-eabi-gcc 14.2.1)

**Verdict: SURVIVES (substance), REFUTED (literal headline wording) — no missed live bug, but the
source doc's own topic sentence contradicts its own evidence table.**

Source claim: `grbl/platform/docs/TOOLCHAIN-VERSIONS.md` §2(a): "Zero `-fanalyzer` findings (zero
CWE-tagged diagnostics) anywhere in the core under avr-gcc 16.1.0 or arm-none-eabi-gcc 14.2.1... "
— but the table two lines below the same sentence lists `settings.c:208`
`-Wanalyzer-out-of-bounds [CWE-787]` as "present under avr-gcc 15.2.0 **and arm-none-eabi-gcc
14.2.1**, ABSENT under avr-gcc 16.1.0." That is a diagnostic actually produced under one of the
two exact compilers the topic sentence says is clean. Self-contradiction inside one document,
undetected before this review.

### Calibration (required before trusting any zero)

Planted a use-after-free + out-of-bounds write in a throwaway file (never touched anything under
`grbl/`): `/tmp/.../scratchpad/uaf_test.c`.

```
gcc -fanalyzer -c uaf_test.c -o uaf_test.o
```
→ flags both (`-Wanalyzer-use-after-free [CWE-416]`, `-Wanalyzer-out-of-bounds [CWE-121]`).

```
gcc -fanalyzer -fsyntax-only uaf_test.c   → EXIT 0, zero output
```
Repeated on the actual toolchains named in the claim:
```
/opt/avr-gcc-16/bin/avr-gcc  -mmcu=atmega328p       -fanalyzer -c            uaf_test.c  → flags both
/opt/avr-gcc-16/bin/avr-gcc  -mmcu=atmega328p       -fanalyzer -fsyntax-only uaf_test.c  → EXIT 0, silent
/opt/arm-gnu-14.2/bin/arm-none-eabi-gcc-14.2.1 -mcpu=cortex-m0plus -mthumb -fanalyzer -c            uaf_test.c → flags both
/opt/arm-gnu-14.2/bin/arm-none-eabi-gcc-14.2.1 -mcpu=cortex-m0plus -mthumb -fanalyzer -fsyntax-only uaf_test.c → EXIT 0, silent
```
Confirms: (1) my invocation can detect a real defect when using real codegen (`-c`); (2) the
report's claim that `-fanalyzer` is silently inert under `-fsyntax-only` is TRUE on every
compiler tested, including host gcc 13.3.0 — this is a genuinely calibrated, correct finding by
the original agent, not a self-serving one. Checked whether any CI script or `ci/*.py`/`*.sh`/
`.github/workflows/*.yml` actually pairs `-fanalyzer` with `-fsyntax-only`:
`grep -rn fanalyzer .github/workflows ci` → **zero matches anywhere in CI** — `-fanalyzer` is not
a persistent CI gate at all, only a one-off manual audit recorded in
`docs/TOOLCHAIN-VERSIONS.md`. So the inert-`-fsyntax-only` finding, while true, describes a trap
that was avoided, not a live blind guard.

### Independent re-sweep, real codegen, over every `grbl/*.c`

AVR (root `Makefile`'s exact flags + the audit's analyzer flag set, `-c`):
```
/opt/avr-gcc-16/bin/avr-gcc -Wall -Os -DF_CPU=16000000UL -mmcu=atmega328p -I. -Igrbl -Igrbl/platform \
  -ffunction-sections -include grbl/platform/common/gpio.h \
  -fanalyzer -Wextra -Wuse-after-free -Wdangling-pointer -Wnull-dereference -Warray-bounds=2 \
  -Wstringop-overflow -Wshadow -c grbl/<file>.c -o /tmp/.../<file>.o
```
Run over all 19 `grbl/*.c` (18 built + dead `eeprom.c`). Result: 0 compile errors, 0
`CWE`-tagged diagnostics, only the ordinary warnings the doc's table already lists (6
`-Wimplicit-fallthrough=` sites in gcode.c/report.c/system.c, 4 `-Wint-in-bool-context` in
nvmem.c/eeprom.c). Confirmed byte-for-byte matching diagnostic set.

Repeated against avr-gcc-15.2.0 (same flags): **one** CWE hit —
`grbl/settings.c:208:46: warning: buffer overflow [CWE-787] [-Wanalyzer-out-of-bounds]` — matches
the doc's claim exactly.

ARM (arm-none-eabi-gcc-14.2.1, stm32f411's real `common.mk` RELEASE flag set: `-mcpu=cortex-m4
-mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -DF_CPU=96000000ULL -Os -fsingle-precision-constant
-DGRBL_FP_SINGLE` + the same analyzer flags, `-c`, run from `grbl/platform/stm32f411/`):
`grep -n "CWE-" arm142_full.log` → **exactly one hit**, same line:
`../../settings.c:208:46: warning: buffer overflow [CWE-787] [-Wanalyzer-out-of-bounds]`.

This means the topic sentence's "zero ... under ... arm-none-eabi-gcc 14.2.1" is factually wrong
by the doc's own later table — 1 finding exists, not 0. (`eeprom.c` also errors under this ARM
invocation — undeclared `EECR`/`EEWE`/etc — but that is expected: it is AVR-register code never
built for any ARM port, consistent with CONTRACTS.md's "dead code, do not port it," not a
contradiction of anything claimed.)

### Verifying the false-positive judgment (not just re-quoting it)

Read `grbl/settings.c:190-215` directly. The flagged write is:
```c
uint8_t settings_store_global_setting(uint8_t parameter, float value) {
  ...
  parameter -= AXIS_SETTINGS_START_VAL;
  uint8_t set_idx = 0;
  while (set_idx < AXIS_N_SETTINGS) {
    if (parameter < N_AXIS) {
      switch (set_idx) {
        case 0:
          ...
          settings.steps_per_mm[parameter] = value;   // line 208, the flagged write
```
The write is reached only inside `if (parameter < N_AXIS)` — the bound the original report
claimed. Confirmed correct by direct reading, not re-trusted. The GCC-analyzer false positive is
a real, known imprecision class (value-range widening across `while`-loop back-edges losing an
established bound) and reproducing at the identical line across two different architectures
(AVR-15, ARM-14.2) while a third compiler (AVR-16) doesn't trip it is exactly the signature of an
analyzer heuristic difference, not a moved goalpost in the source.

### Conclusion

Substance: no live bug was missed; the one real analyzer hit is a genuine, independently-verified
false positive. Documentation defect: `TOOLCHAIN-VERSIONS.md`'s own headline sentence says "zero
... under ... arm-none-eabi-gcc 14.2.1" while its own table three lines later lists a finding
under that exact compiler — an avoidable, uncaught internal contradiction. Low severity (doesn't
excuse any unfinished work, doesn't hide a defect), but exactly the kind of unchecked narrative
inconsistency this review exists to catch.

---

## Claim F — "clang has no equivalent to `-fsingle-precision-constant`, so every clang build of an
## FP=SINGLE port is silently FP=DOUBLE" (this killed the entire clang axis)

**Verdict: REFUTED. Clang has a working equivalent; the whole clang-axis rejection in
`grbl/platform/docs/TOOLCHAIN-AXIS.md` §2/§8 rests on a false premise.**

Source claim (`docs/TOOLCHAIN-AXIS.md` §2 finding 1, marked "BLOCKING"): checked `clang --help`/
`clang -cc1 --help` for flags containing "single-precision"/"excess-precision"/"fp-eval";
found `-cl-single-precision-constant` and dismissed it as "OpenCL-only (rejected for plain C)".
Concluded there is no way to stop clang promoting unsuffixed floating literals to `double`, so
`assert_no_double.sh` necessarily fails for any FP=SINGLE port under `TC=clang`, and decided (§8)
not to pursue the clang axis for FP=SINGLE ports.

### What I actually ran

Reproduced the driver-help search myself — same result, `-cl-single-precision-constant` is the
only candidate flag (`clang -cc1 --help 2>&1 | grep -i precision`). But instead of accepting the
help text's "OpenCL only" framing, I tried the flag on ordinary C:

```
clang -cl-single-precision-constant -c fp_test.c -o fp_test.o    → EXIT 0, no error, no warning
clang -cl-single-precision-constant -Wall -Wunused-command-line-argument -c fp_test.c -o fp_test.o → EXIT 0, still silent
clang -cl-single-precision-constant -### -c fp_test.c            → -cc1 line shows the flag passed straight through unmodified, no rewriting/dropping
```

It is **not rejected** for plain C at all — the driver forwards it to `-cc1` unconditionally
regardless of `-x c`/`-x cl`, and `-cc1` applies it as a plain LangOpts flag, not gated to OpenCL
mode.

Direct IR-level proof it changes literal typing (`fp_test.c`: `float f(float x){return x+1.0;}`):
```
without flag: %4 = fpext float %3 to double ; %5 = fadd double %4, 1.0 ; %6 = fptrunc double %5 to float
with flag:    %4 = fadd float %3, 1.000000e+00        (no promotion at all)
```

Stronger test mimicking real GRBL-style code (mixed unsuffixed literals, `sqrtf`, comparison,
subtraction), cross-compiled for the actual ARM target used by this project
(`-target arm-none-eabi -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
--sysroot=/usr/lib/arm-none-eabi -Os`, then `-flto=thin` too):

```
without -cl-single-precision-constant, llvm-nm:
  U __aeabi_d2f
  U __aeabi_dadd
  U __aeabi_dcmpgt
  U __aeabi_dmul
  U __aeabi_f2d
  U sqrtf
  T compute

with -cl-single-precision-constant, llvm-nm:
  U sqrtf
  T compute
```

Every one of the exact `__aeabi_d*` double-precision soft-float symbol classes
`assert_no_double.sh` greps for (`grep -qE '__aeabi_d|__.*df2|__.*df3'`-style patterns per
CONTRACTS.md #17) disappears with the flag. Cross-checked against real gcc for parity: same test
file, `arm-none-eabi-gcc-14.2.1 -fsingle-precision-constant` (the flag the whole doc treats as
the only correct answer) produces the **identical** symbol table (`compute` + `sqrtf`, zero
`__aeabi_d*`). Also confirmed under `-flto=thin` (the actual RELEASE build's LTO mode) — same
zero-double-symbol result, `EXIT 0`, no unused-argument diagnostic even with
`-Wunused-command-line-argument` explicitly enabled.

### Consequence

The "BLOCKING" verdict, the "silently FP=DOUBLE" claim, the whole recommendation in §8 to not
pursue `TC=clang` for FP=SINGLE ports, and the row in §7's compatibility table
("`stm32f103`/`stm32f411`/`stm32h523`/`hc32f460` (ARM Cortex-M, FP=SINGLE) — gcc only, until §2
finding 1 has an answer") are **all built on a search that stopped one step too early**: it found
the candidate flag, read its `--help` text ("OpenCL only"), and never tried it. `assert_no_double.sh`
almost certainly PASSES today under clang for every FP=SINGLE port if `-cl-single-precision-constant`
is added to the clang family's flag set (not verified end-to-end against a full port build in this
review — see UNVERIFIED note below — but verified at the exact mechanism level `assert_no_double.sh`
checks: the double-precision libcalls the assert greps for are the direct, reproducible, IR-confirmed
effect being eliminated).

**Scope of what I did NOT verify**: I did not rebuild a complete `stm32f411` (or any) port end-to-end
under clang with this flag added and run the project's actual `assert_no_double.sh` script against
the resulting real ELF — that would additionally need the project's full clang CFLAGS set,
`prelude.h` chain, and linking. What I verified is the underlying mechanism the whole "BLOCKING"
claim rests on, at the same level of rigor the original doc used (isolated compilation +
`nm`/IR inspection), and it directly contradicts the doc's "rejected for plain C" characterization.
Recommend: add `-cl-single-precision-constant` to `docs/TOOLCHAIN-AXIS.md`'s proposed clang family
flags and re-run `assert_no_double.sh` against a real port build before reopening the clang axis
decision — but the specific factual claim that killed it ("no equivalent exists") is false.

---

## Claim E — Guard efficacy: do the 8 ratchets actually fail when they should?

**Verdict: SURVIVES for all 8.** Every guard was broken with a real, planted defect against real
repo files (not only its own `--selftest`, which the brief correctly notes can test the wrong
thing), confirmed to fail loudly, then restored. `git status --porcelain` was empty after every
restoration; final tree state below confirms nothing left dirty.

| # | Guard | `--selftest` | Live break performed | Result |
|---|---|---|---|---|
| 1 | golden MD5 (`Makefile:validate`) | n/a (trivial shell string-compare) | Inspected the 5-line comparison logic directly; independently re-ran `md5sum grbl.hex` against the literal `79af184e67b27defd27a39309ac53563` — logic is a plain `[ "$A" = "$B" ]`, nothing to hide | Confirmed correct by inspection + live value match |
| 2 | `tools/assert_no_double.sh` | `--selftest` → PASS (8 checks) | Added `__attribute__((used)) double __review_poison_double(volatile double a, volatile double b){return a*b+a/b;}` to `grbl/platform/hc32f460/platform.c`, `make BUILD=RELEASE` | Real link FAILED: `__aeabi_dadd/__aeabi_ddiv/__aeabi_dmul/__aeabi_drsub/__aeabi_dsub/__divdf3/__floatdidf/__muldf3/__subdf3` reported, `make` exit 1, `.elf` deleted. Reverted; rebuild PASSED, byte-identical `.bin` (MD5 matches `artifacts/hc32f460/grbl_hc32f460.bin`) |
| 3 | `grbl/platform/common/init_check.sh` | `--selftest` → PASS (10 checks) | Removed the `hal_gpio_clock_init();` call from `ch32v006/startup.c`'s `SystemInit()`, `make BUILD=RELEASE` | Real link FAILED with the script's own BUG #23 message (symbol unreachable after LTO), `make` exit 1. Reverted; rebuild clean, `text=39224` unchanged |
| 4 | `grbl/platform/common/boot_check.sh` | none (no selftest mode) | Hand-crafted a garbage 16-byte `.bin` (`SP=0xDEADBEEF`, `PC=0x00000000`) | `BOOT INTEGRITY: FAIL`, exit 1. Cross-checked positive case against the real committed `artifacts/stm32f411/grbl_stm32f411.bin` → `BOOT INTEGRITY: OK`. No repo file touched for this one (synthetic input file only) |
| 5 | `ci/warn_ratchet.py` | `--selftest` → PASS (12 checks) | Built ch32v006 RELEASE clean (ratchet OK, 4/4 baseline), then added an unused local `int __review_unused_var = 0;` to `hal_gpio_config_pin()` in `ch32v006/platform.c`, rebuilt | Real ratchet run FAILED: `1 new warning(s) not in ci/warn_baseline_ch32v006.txt: + platform.c: warning: unused variable ...`, exit 1. Reverted; rebuild clean, ratchet OK again |
| 6 | `tools/check_contracts_numbering.py` | `--selftest` → PASS (11 checks) | Real `CONTRACTS.md` starts clean (`38 sections, 38 slugs, 36 cross-file links, OK`). Changed `## 2. GPIO interrupts` to `## 1. GPIO interrupts` (line 193, duplicating section 1) | Real run FAILED: `duplicate section number 1: line 125 and line 193` + sequential-numbering error, confirmed `$? == 1` on a clean, non-piped re-run. Reverted; re-run OK (exit 0), 38/38/36 again |
| 7 | `tools/build_artifacts.py check` | `--selftest` → PASS (62 checks) | Real `check --platforms ch32v006` PASSED clean first. Flipped one byte (`data[100] ^= 0xFF`) in the committed `artifacts/ch32v006/grbl_ch32v006.bin` | Real run FAILED: `ch32v006: artifacts/ch32v006/grbl_ch32v006.bin is STALE (committed=... fresh=...)`. Restored the exact original bytes from a saved copy (`md5sum` matched pre/post); re-run OK, 6/6 fresh |
| 8 | `grbl/platform/common/clock_width.h` `_Static_assert` | none (header, no selftest) | Reverted `ch32v006/Makefile`'s `-DF_CPU=$(CLOCK)ULL` to `...UL`, `make BUILD=RELEASE clean && make BUILD=RELEASE` | Real compile FAILED at the very first TU: `error: static assertion failed: "F_CPU must be suffixed ULL ..."`, exit 1 (reproduces the PLAN.md entry's own claimed transcript, independently). Reverted; rebuild clean, `text=39224` unchanged |

**Tree state after all 8 experiments**: `git status --porcelain` → empty. `make -C
grbl/platform/atmega328p validate` → PASSED, MD5 `79af184e67b27defd27a39309ac53563`, re-confirmed
after this claim's work (see final verification at the end of this document).

---
