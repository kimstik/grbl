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
