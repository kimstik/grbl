# Adversarial Review — Session Claims A-F (2026-07-26)

Reviewer: adversarial audit agent, worktree `worktree-agent-a04012c9b772985f9` @ f681454
(fast-forwarded from a stale eefe2bb via `git merge --ff-only claude/samd21-port-01MYdHT6QaxWVxdRvWQFHuPi`,
no other tree changes). Working directory throughout:
`/home/user/grbl/.claude/worktrees/agent-a04012c9b772985f9`.

Status key: REFUTED / SURVIVES / UNVERIFIED. Findings ranked most-severe first inside each claim.

(This file is being built incrementally; committed after each claim closes so a session
limit does not lose work.)

## Summary, ranked most-severe first

1. **Claim F — REFUTED.** "clang has no equivalent to `-fsingle-precision-constant`" is false.
   `-cl-single-precision-constant` works identically in plain C (driver forwards it to `-cc1`
   unconditionally; verified with IR dumps and `nm` on a real ARM cross-build — zero `__aeabi_d*`
   symbols, matching real gcc byte-for-byte). This was the sole factual basis for killing the
   entire clang toolchain axis for every FP=SINGLE port; the decision should be revisited.
2. **Claim C1 — REFUTED (undercount, not live).** samd21 has 4 overlapping `config.h`/`platform.h`
   macro names, not the claimed 2, and one (`LIMIT_MASK`) is a genuinely unguarded silent
   duplicate — the exact BUG #25 shadow-mechanism CONTRACTS.md §33 says exists nowhere outside the
   three STM32 ports. Currently harmless (values agree textually), but the "always `#undef`
   announced" invariant is false as stated.
3. **Claim C2 — SURVIVES for what's claimed; real unaudited gap flagged.** BUG #24's specific
   claims (ch32v006 fixed, ch570 structurally immune) both hold up. But hc32f460's `hal_gpio_init()`
   never gates any GPIO port clock, and the port's own cross-check source documents an FCG-class
   gate register existing on this chip family — a plausible, real, currently undocumented candidate
   for the same bug class, not covered by any existing claim (silence, not a false statement).
4. **Claim A — SURVIVES (substance), minor doc self-contradiction.** The core `-fanalyzer` sweep
   is real, calibrated (a planted UAF+OOB defect is caught with real codegen, confirmed inert only
   under `-fsyntax-only` which no CI script uses), and reproduces exactly. But
   `TOOLCHAIN-VERSIONS.md`'s own headline sentence ("zero... under... arm-none-eabi-gcc 14.2.1")
   is contradicted by its own table three lines later (one real CWE-787 hit, correctly judged a
   false positive on independent re-verification).
5. **Claims B, C3, D, E — SURVIVE.** Full baseline audit, pin-width class scope, byte-identity
   across all 10 built units (independently rebuilt, not trusted from the self-modified generator),
   and all 8 guards (each broken with a real planted defect against real files, not only
   `--selftest`, then restored) all hold up under direct re-verification.

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
| 1 | golden MD5 (`Makefile:validate`) | n/a (trivial shell string-compare) | Inspected the 5-line comparison logic directly; independently re-ran `md5sum grbl.hex` against the literal `79af184e67b27defd27a39309ac53563` — logic is a plain `[ "$A" = "$B" ]`, nothing to hide | Confirmed correct by inspection + live value match. **SUPERSEDED (2026-07-27)**: `validate` no longer contains this inline compare — it now calls `python3 grbl/platform/common/chk.py --require-canonical grbl.hex`, which owns a tiered known-hash table (canonical/known/unreproducible; CONTRACTS.md [§chk-py-tiers](../CONTRACTS.md#chk-py-tiers)). The canonical hash value this row inspected is unchanged and still the only one that passes; this row's description of the *mechanism* (a hardcoded inline string) is historical, not current — see the linked section for the live design and its own break/restore proof (canonical PASS, a gcc 16.1.0 build correctly FAILS distinctly from an unrecognised/corrupted one). |
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

## Claim B — "All non-F_CPU warn-baseline entries are genuine noise"

**Verdict: SURVIVES.** Read all 238 lines across all 9 `ci/warn_baseline_*.txt` files directly
(not sampled) and independently re-verified the three specific entries the brief called out as
worth re-checking, by reading the flagged source, not by re-quoting the existing PLAN.md verdict.

### f103's three "redefined" macros (`CoreDebug_DEMCR_TRCENA_Msk`/`DWT_CTRL_CYCCNTENA_Msk`/`IWDG_BASE`)

`grep -rn "CoreDebug_DEMCR_TRCENA_Msk\|DWT_CTRL_CYCCNTENA_Msk\|IWDG_BASE" grbl/platform/` shows:

| Macro | `common/stm32/stm32_timing.c` / `stm32_watchdog.c` | `stm32f103/regs.h` | `stm32f411/regs.h` |
|---|---|---|---|
| `DWT_CTRL_CYCCNTENA_Msk` | `(1UL << 0)` | `(1 << 0)` | `(1UL << 0)` |
| `CoreDebug_DEMCR_TRCENA_Msk` | `(1UL << 24)` | `(1 << 24)` | `(1UL << 24)` |
| `IWDG_BASE` | `0x40003000UL` | `0x40003000` | `0x40003000UL` |

Numerically identical in every column; f103's copies differ from the common code only by the
missing `UL` suffix on the literal — exactly the claimed "differs only in an `1`-vs-`1UL` literal
suffix." This also directly explains why f411 (whose `regs.h` already spells the suffix
identically to the common code) produces **zero** redefinition warning for the same macros — GCC
only warns on macro redefinition when the replacement token sequence differs, and f411's is
byte-identical text. Confirmed, not re-quoted.

### f103/h523 `platform.c` unused `port` parameter in `hal_gpio_interrupt_disable`

Read `grbl/platform/stm32f103/platform.c:113-156` and `grbl/platform/stm32h523/platform.c:207-284`
directly. Both follow the identical shape: `hal_gpio_interrupt_enable(port, mask)` uses `port` to
compute a port-to-EXTI-line routing code (f103: `AFIO->EXTICR[]`; h523: `SYSCFG->EXTICR[]`) because
EXTI lines are a shared, multiplexed resource — only one GPIO port can route to a given EXTI line
number at a time, and enabling an interrupt must claim that routing. `hal_gpio_interrupt_disable`
only clears `EXTI->IMR`/`FTSR`/`RTSR` bits — registers indexed purely by pin number, with no
per-port field at all — so it has no possible use for `port`. Verified by reading both functions
side by side on both ports; the asymmetry is architecturally required, not an oversight.

### hc32f460 `efm_erase_page`'s unused `addr`

Read `grbl/platform/hc32f460/flash.c:40-62` directly. `efm_erase_page(uint32_t addr)` truly never
references `addr` anywhere in its body — only `efm_unlock()`/`EFM->FWMC`/`__DSB()`/`EFM->FSTP`/
`efm_wait_ready()`/`efm_lock()`, none of which take an address. Contrast with its sibling
`efm_program_word(addr, value)`, which does an address-triggered store
(`*(volatile uint32_t *)addr = value`) — the mechanism this MCU family's flash controllers
typically use to also tell the erase command *which page* to target. `efm_erase_page` has no
equivalent store, so on real silicon this may well erase the wrong page (or rely on some other
undocumented default-address behavior) — a genuinely open, disclosed risk. This is **not** graded
"benign" anywhere in the project's own docs: `ci/warn_baseline_hc32f460.txt` carries the warning
with no dismissive comment, and `PLAN.md`'s own entry says outright "at minimum suspicious...
worth a real look at hardware bring-up time — not fixed here," consistent with `platform.md`'s
blanket "EFM register layout UNVERIFIED, hardware bring-up must confirm" disclaimer (no HC32F460
emulator exists to test against). The project is not claiming this is safe — it is holding it open
as a known hardware-bring-up risk. Verified the code says what the project's own docs claim it
says; did not attempt to resolve the underlying hardware question myself (no emulator, no
silicon — same limitation the project already states).

### Remaining 6 baseline files (stm32h523, stm32f411, samd21, ch570, dspic33ak128mc102,
atmega328p, ch32v006 — all read in full)

All entries fall into one of: (a) the shared core-file class (`-Wimplicit-fallthrough=` in
gcode.c/report.c/system.c, `motion_control.c` unused `cycle_mask`, `nvmem.c`/`eeprom.c`
`-Wint-in-bool-context` checksum quirk — all cross-checked against Claim A's own independent
`-fanalyzer`/warning sweep above, same lines, same text); or (b) `stm32_platform.h`'s generic
`-Wtype-limits` macro (checked: `STM32_VALIDATE_RANGE` is deliberately generic over signed/
unsigned call sites, harmless by construction, matches the doc's own judgement). No entry found
in this pass that the project's docs mis-graded, beyond the three already known to have been real
bugs before this session (#25 pin-map, #26 Z-limit overflow, F_CPU) which are explicitly logged as
fixed and absent from the current baselines (confirmed: `grep -rn "SPINDLE_ENABLE_PIN.*redefined"
ci/warn_baseline_*.txt` → zero hits).

---

## Claim C — "No other port is affected" (three sub-claims)

### C1. BUG #25 (two headers both defining a pin) — claimed confined to f103/h523 live, f411
latent, "no other port... has a config.h/platform.h pair that both claim the same pin-shaped
macro name at all" outside those three, with samd21 named as having exactly two deliberate,
`#undef`-announced exceptions (`PROBE_PIN`, `PROBE_MASK`).

**Verdict: REFUTED (undercounted, not a live bug).** Wrote an independent sweep
(`/tmp/.../scratchpad/pinmap_sweep.py`) that parses every `#define`/`#undef` in every port's
`config.h`/`boards/*/config.h` and its paired `platform.h`, across all 11 config.h files
(`_template`, ch32v006, ch570, dspic33ak128mc102, samd21×3 (shared+2 boards), sg2002,
stm32f103/f411/h523) and every `platform.h` (adding `atmega328p`/`hc32f460` — confirmed neither
has a `config.h` at all, matching the claim). Result: `_template`, ch32v006, ch570,
dspic33ak128mc102, sg2002, and all three STM32 ports have **zero** common macro names between the
two files (clean, matches claim). **samd21 (both boards) has FOUR common names, not two**:
`PROBE_PIN`, `PROBE_MASK`, `CONTROL_MASK`, `LIMIT_MASK`. Of these, `PROBE_PIN`/`PROBE_MASK`/
`CONTROL_MASK` are each preceded by their own `#undef` in `platform.h` (confirmed by reading
`grbl/platform/samd21/platform.h:231-241` directly) — the deliberate, announced-override pattern
the doc describes. **`LIMIT_MASK` (platform.h:225) has no preceding `#undef LIMIT_MASK` anywhere
in either file** — read directly: `config.h:263` `#define LIMIT_MASK LIMIT_MASK_A`, then
`platform.h:225` `#define LIMIT_MASK LIMIT_MASK_A // Combined mask for all limit pins` with only
an unrelated `#undef LIMIT_PIN` one line above it, not `#undef LIMIT_MASK`. This is the exact
silent-shadow mechanism §33 says exists nowhere outside the three STM32 ports, present on a
fourth port. Not a live bug today — both sides expand to the literal token `LIMIT_MASK_A`
(textually identical, which is also why GCC's redefinition warning never fires and it was never
in any baseline) — same "latent, not live" class §33 itself uses for stm32f411's benign
duplicates, and the same "one unreviewed edit away" risk it warns about there. **Consequence**:
the "no other port... at all" / "always preceded by an explicit `#undef`" framing in
CONTRACTS.md §33 is factually wrong on both the count (4, not 2) and the mechanism (3 of 4
guarded, not 4 of 4) for samd21 specifically. Low-severity (no runtime effect today, and the
project's own §33 already establishes exactly the right diagnostic frame for this class — it just
didn't apply its own sweep to samd21 the same way it did to the STM32 trio).

### C2. BUG #24 (GPIO port bus clock never gated) — claimed ch32v006-only fix, ch570 verified
immune, no completeness claim made about any other port.

**Verdict: SURVIVES for what is actually claimed; UNVERIFIED beyond it — a real, unaudited gap
exists and should be flagged.** CONTRACTS.md §28 only asserts two things: ch32v006 had the bug and
it's fixed, and ch570 was independently checked and doesn't have the register class to have the
bug at all. Neither claim over-reaches to "and every other port in the tree is clean" — but the
review brief asks for exactly that broader sweep, so I ran it:

- **ch570**: read `grbl/platform/ch570/ch570.h` directly. Confirmed a single GPIO port ("PA",
  base `0x400010A0`, comment: "discrete registers, AVR-style"). The only clock/power-gate register
  in the file, `R8_SLP_POWER_CTRL` (0x4000100F), is used exactly once in `platform.c:119`, inside
  `hal_clock_config()`'s system-clock-divider commit — never referenced by any GPIO code. No
  `IOPxEN`-class bit exists anywhere in this header for GPIO. Claim confirmed independently.
- **stm32f103/f411/h523**: cross-checked every `*_PORT` macro in each port's `platform.h` against
  its `hal_gpio_init()`'s `RCC->APB2ENR`/`AHB1ENR`/`AHB2ENR` literal. All three use exactly
  `{GPIOA, GPIOB, GPIOC}` and all three gate exactly `{GPIOAEN, GPIOBEN, GPIOCEN}` (plus
  `AFIOEN`/`SYSCFGEN` where applicable) — no port referenced in the pin map is missing from the
  enable literal, on any of the three. Clean.
- **hc32f460 — genuine open gap, not addressed by any existing claim.** This port's `hal_gpio_init()`
  (`platform.c:137-162`) never writes to `PWC` for GPIO at all — no clock-gate call for `GPIOA`/
  `GPIOB` anywhere in the port. The port's own cross-check source (Klipper3d/klipper's real,
  shipped HC32F460 firmware, cited in `platform.md:247`) documents this exact chip family using
  `PWC_FcgxPeriphClockCmd()` "clock-gate calls" for peripherals — meaning an FCG-class gate
  register demonstrably exists on this chip. Whether GPIO specifically needs gating (some MCU
  families exempt GPIO from bus gating; others don't) is not stated anywhere in this port's own
  `platform.md`/`regs.h`, both of which already carry a blanket, honest "EFM/PORT register layout
  UNVERIFIED, hardware bring-up must confirm" disclaimer for unrelated reasons. I could not resolve
  this without a real HC32F460 register manual or hardware (neither available in this sandbox), so
  I am **not** claiming this is a live BUG #24 instance — only that it is a plausible, real,
  currently-unaudited candidate for the exact same defect class the project already found and fixed
  once, and no document in this tree currently asks the question for this port. Recommend adding
  it to the gap log explicitly rather than leaving it implicit inside the general UNVERIFIED
  disclaimer.
- **samd21 / dspic33ak128mc102**: no GPIO-port clock-gate code exists in either port either.
  For samd21, this is consistent with SAMD21's PORT peripheral being on the always-enabled part of
  the APB bus by default at reset (a real, well-known architectural fact about this chip family) —
  but I did not confirm this against a primary datasheet source in this session, so it is
  UNVERIFIED by me, not confirmed. Same for dsPIC33's I/O ports (PIC-family GPIO is conventionally
  ungated, unlike AHB/APB-bus peripherals) — architecturally plausible, not independently confirmed
  here. Neither is contradicted by anything found; both are open questions the existing docs don't
  address, same class as hc32f460's gap above but lower-probability given the architectural priors.

### C3. Pin-width truncation class — claimed SPINDLE_ENABLE/SPINDLE_DIRECTION/COOLANT_FLOOD/
COOLANT_MIST/STEPPERS_DISABLE are NOT in the `uint8_t`-truncation risk class (unlike STEP/
DIRECTION/LIMIT/CONTROL/PROBE) because every core use site is a single-bit operation on native
register width.

**Verdict: SURVIVES.** `grep -n "SPINDLE_ENABLE\|SPINDLE_DIRECTION\|COOLANT_FLOOD\|COOLANT_MIST\|
STEPPERS_DISABLE" grbl/spindle_control.c grbl/coolant_control.c grbl/stepper.c grbl/system.c
grbl/limits.c grbl/probe.c grbl/settings.c grbl/report.c` — every call site across all of core
resolves to `GPIO_DIR_OUT(...)`, `GPIO_BSET(...)`, `GPIO_BCLR(...)`, `GPIO_BGETOUT(...)`, or a
`bit_isfalse/bit_istrue(SPINDLE_ENABLE_PORT, (1<<SPINDLE_ENABLE_BIT))` register-width comparison —
never assigned into or returned through a `uint8_t` local/return value the way LIMIT's
`get_limit_pin_mask()` or PROBE's `GPIO_MRD(...)` truncate. Confirmed the macros themselves
(`grbl/platform/common/gpio.h:85,89,97,134`) route through `GPIO_BWR`/`GPIO_BRD`, single-bit
read/write helpers on the port's native register type, not through any `uint8_t`-typed
intermediate. No exception found; the claim's own parenthetical ("checked, not assumed") is
accurate — I re-checked and it holds.

---

## Claim D — Byte-identity claims

**Verdict: SURVIVES.** Per the brief's own warning, did not trust `tools/build_artifacts.py`'s
self-reported hash match (that generator grew from 665 to 1525 lines this session — confirmed via
`git show 62c76d9:tools/build_artifacts.py | wc -l` → 665 vs current `wc -l tools/build_artifacts.py`
→ 1525, the exact figures the brief cites). Instead, independently rebuilt every port's RELEASE
image directly through its own `Makefile` (bypassing `build_artifacts.py` entirely) and diffed the
raw `.bin` bytes against the committed `artifacts/` tree with a plain `md5sum`:

| Port | Build command | `md5sum build/...` | `md5sum artifacts/...` | Match |
|---|---|---|---|---|
| ch32v006 | `make -C grbl/platform/ch32v006 BUILD=RELEASE` | `a265693d67506eb2...` | `a265693d67506eb2...` | yes |
| hc32f460 | `make -C grbl/platform/hc32f460 BUILD=RELEASE` | `11e0eb3f0c0bf102...` | `11e0eb3f0c0bf102...` | yes |
| dspic33ak128mc102 | `make -C grbl/platform/dspic33ak128mc102 BUILD=RELEASE` (real `xc-dsc-gcc` 8.3.1, real DFP at `/opt/Microchip.dsPIC33AK-MC_DFP.1.5.263`) | `879b45a88ec69c13...` | `879b45a88ec69c13...` | yes |
| stm32f103 | `make -C grbl/platform/stm32f103 BUILD=RELEASE` | `8d4641fa49e5129d...` | `8d4641fa49e5129d...` | yes |
| stm32f411 | `make -C grbl/platform/stm32f411 BUILD=RELEASE` | `8028897a8a2c1a97...` | `8028897a8a2c1a97...` | yes |
| stm32h523 | `make -C grbl/platform/stm32h523 BUILD=RELEASE` | `a41505d934a48ed1...` | `a41505d934a48ed1...` | yes |
| samd21 megarm | `make -C grbl/platform/samd21 BOARD=megarm BUILD=RELEASE` | `491ffd90f0f9ccbf...` | `491ffd90f0f9ccbf...` | yes |
| samd21 generic | `make -C grbl/platform/samd21 BOARD=generic BUILD=RELEASE` | `3f28eebf53f8a6d0...` | `3f28eebf53f8a6d0...` | yes |
| ch570 | `make -C grbl/platform/ch570 BUILD=RELEASE` | `01297786e9122908...` | `01297786e9122908...` | yes |
| atmega328p | `make -C grbl/platform/atmega328p validate` | golden gate | `79af184e67b27def...` | yes |

Every one of the 10 CI-matrix units' committed `.bin` is byte-identical to a fresh, independent
rebuild from the current tree — verified with the raw toolchain + `md5sum`, never through the
possibly-compromised generator. This is transitive but strong evidence for the specific historical
claims named in the brief (pin-width batch on hc32f460/ch32v006/dspic33ak128mc102; the
comment-compaction and Makefile-dedup batches): if any of those edits had actually changed
generated code, the *current* tree would no longer byte-match the committed artifact — but it
does, on every port, right now. `_Static_assert` itself is additionally a zero-codegen construct
by C-standard definition (compile-time only, no object-code footprint), so an assert-only diff
cannot change a binary by construction, independent of any tooling trust question.

Did not re-derive the historical parent-commit-vs-child-commit diff for each named batch
individually (would require checking out each intermediate commit and rebuilding under this
review's read-only scope) — the verification performed is "today's committed state survives an
independent rebuild," which is the load-bearing invariant these claims ultimately serve, but is
not literally "replayed the exact before/after commits of each named batch." Noting this
narrower scope explicitly rather than overstating it.

---
