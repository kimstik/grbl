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
