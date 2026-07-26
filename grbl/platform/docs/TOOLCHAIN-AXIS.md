# Toolchain Axis (`TC=gcc|clang`) — Recon Findings and Design

Status: **REOPENED AND PARTIALLY LANDED (2026-07-26).** The original recon
session (same date, earlier the same day) closed this axis at "zero ports"
on a single claim: clang has no equivalent to gcc's
`-fsingle-precision-constant`. An adversarial review (see
`docs/REVIEW-SESSION-CLAIMS.md`, "Claim F") refuted that claim, and a
follow-up session (this document, same date, later revision) independently
re-verified the refutation against every real target this tree ships and
landed what earned its place. **The section below is the correction,
dated per this project's convention for a reversed finding — it does not
silently rewrite the original text, which follows it intact for the
record.**

## CORRECTION (2026-07-26, later session): the "zero ports" conclusion was wrong

**What was wrong.** §2 finding 1 below (original text, unedited) says:
"clang has no equivalent to `-fsingle-precision-constant`... `-cl-single-
precision-constant` exists but is OpenCL-only (rejected for plain C)."
That is false. The flag exists, is unconditionally forwarded by the clang
driver to `-cc1` regardless of `-x c`/`-x cl`, and produces object code
identical in symbol-set shape to real `arm-none-eabi-gcc
-fsingle-precision-constant` on the same input. The search that produced
the original claim read the flag's `--help` text ("OpenCL only") and
never tried it. That is the process failure: **one untried flag, gated on
its own documentation string, closed an entire toolchain axis.**

**What was re-verified, independently, this session** (not re-quoting the
review — every command below was re-run from scratch against this tree's
actual toolchains):

1. **The mechanism, cross-checked against real gcc for parity.** Same test
   file as the review (`float f(float x){return x+1.0;}` plus a
   GRBL-shaped mixed-literal/`sqrtf` variant), `clang -cl-single-
   precision-constant -### -c fp_test.c` shows the flag passed straight to
   `-cc1` unmodified; IR dumps show `fadd float` instead of `fpext`/`fadd
   double`/`fptrunc`.
2. **Every real target this tree ships**, not just the one ARM Cortex-M4
   the original recon and the review both stopped at — the brief that
   reopened this axis specifically asked for the other seven:

   | Target (real port using it) | clang invocation | Without flag (`llvm-nm -U`, generic-libcall names shown for RISC-V, `__aeabi_*` for ARM) | With `-cl-single-precision-constant` |
   |---|---|---|---|
   | Cortex-M0+ (samd21) | `--target=arm-none-eabi -mcpu=cortex-m0plus -mthumb` | `__aeabi_dadd __aeabi_dsub __aeabi_dmul __aeabi_dcmpgt __aeabi_d2f __aeabi_f2d` | zero DP symbols |
   | Cortex-M3 (stm32f103) | `--target=arm-none-eabi -mcpu=cortex-m3 -mthumb` | same 6 as M0+ | zero DP symbols |
   | Cortex-M4 (stm32f411, hc32f460) | `--target=arm-none-eabi -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard` | `__aeabi_dadd __aeabi_dsub __aeabi_dmul __aeabi_dcmpgt __aeabi_d2f __aeabi_f2d` | **zero undefined symbols at all** (hardware FPU inlines the SP ops, no libcall needed either way) |
   | Cortex-M33 (stm32h523) | `--target=arm-none-eabi -mcpu=cortex-m33 -mfpu=fpv5-sp-d16 -mfloat-abi=hard` | same 6 as M4 | zero undefined symbols |
   | RISC-V rv32ec_zicsr/ilp32e (ch32v006) | `--target=riscv32-unknown-elf -march=rv32ec_zicsr -mabi=ilp32e` | `__adddf3 __subdf3 __muldf3 __extendsfdf2 __truncdfsf2 __gtdf2` | zero DP symbols (only `sqrtf`/SP libcalls remain) |
   | RISC-V rv32imc_zicsr/ilp32 (ch570) | `--target=riscv32-unknown-elf -march=rv32imc_zicsr -mabi=ilp32` | same 6 as rv32ec | zero DP symbols |
   | RISC-V rv64imac_zicsr/lp64 (sg2002) | `--target=riscv64-unknown-elf -march=rv64imac_zicsr -mabi=lp64 -mcmodel=medany` | same 6 as rv32ec | zero DP symbols |

   All seven use the picolibc sysroot at
   `/usr/lib/picolibc/riscv64-unknown-elf` (RISC-V) or
   `--sysroot=/usr/lib/arm-none-eabi` (ARM) for `math.h`. **The
   DP-elimination effect is uniform across every real target-ISA/ABI
   combination this project ships — not ARM-specific, not FPU-specific.**
   Cross-checked for parity on one RISC-V target too (not just the ARM M4
   the review already did): `riscv64-unknown-elf-gcc -march=rv32ec_zicsr
   -mabi=ilp32e -specs=picolibc.specs -fsingle-precision-constant` on the
   identical test file produces the byte-identical symbol set
   (`__addsf3 __gtsf2 __mulsf3 __subsf3 sqrtf`) as clang with the new flag.
3. **`assert_no_double.sh` itself was already toolchain-agnostic.** Its
   deny-regex covers both the generic libcall family (`__adddf3` etc,
   what RISC-V's libgcc emits) and the `__aeabi_*` family (what ARM EABI
   targets emit) — verified by reading the script, not assumed. No change
   to the script was needed for any of the above.
4. **Full end-to-end port build, closing the gap the review explicitly
   left open** ("did not rebuild a complete port end-to-end... run the
   project's actual `assert_no_double.sh` script against the resulting
   real ELF"). Compiled all 24 real stm32f411 RELEASE source files
   (17 core + 4 platform + 3 stm32-common) with clang, real flags mirroring
   `common/stm32/common.mk` plus `-cl-single-precision-constant
   -flto=thin`, linked with `clang -fuse-ld=lld` against the apt
   `arm-none-eabi-gcc` newlib-nano libs (`-L
   .../newlib/thumb/v7e-m+fp/hard -L
   .../gcc/arm-none-eabi/13.2.1/thumb/v7e-m+fp/hard -lc_nano -lm -lnosys
   -lgcc`), then ran the project's real, unmodified ratchet scripts
   against the resulting ELF:
   - `tools/assert_no_double.sh llvm-nm <elf>` → **PASSED: no DP machinery**
   - `grbl/platform/common/init_check.sh llvm-nm <elf>
     Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init` →
     **BOOT INIT: OK**
   - `grbl/platform/common/boot_check.sh <bin> 0x08000000 524288` →
     **BOOT INTEGRITY: OK**, `.bin` = 33448 bytes (not 402MB — see the
     `(NOLOAD)` fix below, applied to this exact `script.ld` and proven
     necessary: relinking the identical objects against the **pre-fix**
     script.ld under `lld` reproduced the 402,783,232-byte `.bin` this doc
     originally reported, confirming the bug and the fix are both real,
     together, on a real clang/ThinLTO/FP=SINGLE image).
   `text`/`data` = 33368/80 (vs the canonical gcc RELEASE build's
   26228/80, measured fresh this session — the code-size delta is real
   clang-vs-gcc codegen difference now that both sides are genuinely
   FP=SINGLE, not the DP-soft-float tax finding 1 originally misattributed
   it to).

**Consequence.** §6's per-port table below and §11's recommendation are
corrected in place (marked, not deleted) — see those sections. Three
other blockers the original recon also reported were re-checked this
session per the reopening brief; their status:

- **`script.ld` `(NOLOAD)` gap (§2 finding 2): FIXED**, in every port this
  session was allowed to touch (`_template`, `ch32v006`, `ch570`,
  `stm32f103`, `stm32f411`, `stm32h523` — `hc32f460`/`samd21`/`sg2002` were
  out of scope, owned by concurrent work). Verified zero-cost under gcc:
  rebuilt all five real ports' RELEASE image after the edit, `md5sum`
  against the committed `artifacts/` tree — byte-identical on every one.
  Golden AVR `make -C grbl/platform/atmega328p validate` unaffected
  (`79af184e67b27defd27a39309ac53563`).
- **AVR (§3 AVR table): STILL DISQUALIFYING, re-confirmed independently.**
  `wdt.h`'s "value '64' out of range for constraint 'I'" reproduces at
  `-Os` explicitly (not an `-O0` artifact). Grepped `grbl/*.c`/`*.h` plus
  `atmega328p/platform.h`: exactly one macro (`HAL_WATCHDOG_RESET()` →
  `wdt_reset()`) references any `wdt_*` symbol, and nothing anywhere calls
  that macro — `-D_AVR_WDT_H_` (skip the header entirely) lets all 18 real
  core `.c` files pass `-fsyntax-only` with zero errors, independently
  re-run this session. PROGMEM re-confirmed separately, worse than a
  missing feature: `const char PROGMEM msg[] = "hi"` compiles with only a
  `-Wunknown-attributes` warning and lands `msg` as ordinary `.rodata`
  with an undefined reference to `__do_copy_data` — i.e. it would be
  copied flash→RAM at boot on a 2KB-RAM chip. AVR stays gcc-only forever,
  independent of the golden-MD5 argument, which alone would already
  settle it.
- **ThinLTO differential (§4): re-run for real, still negative (no new
  regression), now on a genuinely FP=SINGLE clang image.** The original
  run's conclusion was correct but was measured on a DP-contaminated
  binary (finding 1 was still open at the time); this session's full
  end-to-end build (above) is the first time the ThinLTO check has run
  against clang code that is actually FP=SINGLE. `init_check.sh`/
  `boot_check.sh` both PASS on it — BUG #21/#23's mitigations
  (`__attribute__((used))` plus a real call chain from `Reset_Handler`)
  are portable C, confirmed to survive a second LTO implementation again,
  this time on the correct binary.

**What was NOT re-verified this session** (stating the boundary honestly,
per the reopening brief's own instruction): the full end-to-end
port-build proof (item 4 above) was only done for stm32f411/ARM. The
RISC-V symbol-level checks (item 2) are real and match gcc byte-for-byte
at the object-file level, but no RISC-V port was linked end-to-end through
`lld` with its own `script.ld`/picolibc the way stm32f411 was — a RISC-V
port's own linker script, crt0/picolibc interaction, and the
`assert_no_double.sh` pass on a *linked* RISC-V ELF are still unverified
past the object-file level. samd21/hc32f460 were not touched by this
session at all (concurrent-work boundary), so their clang buildability is
inferred from the Cortex-M0+/M4 symbol-level results, not independently
confirmed end-to-end.

See "Landed plumbing" and "Recommendation (corrected)" near the end of
this document for what was built on top of this and why the Makefile
wiring itself was deliberately deferred.

---

## 0. Why this axis at all

Not to replace gcc. avr-gcc 7.3.0 defines the golden AVR MD5 by construction
— there is no "better" compiler for that target, only a different one. The
value of a second compiler is a second, independently-implemented set of
diagnostics and a second, independently-implemented LTO — this project has
been bitten twice (BUG #21: LTO deleted an unreferenced vector table; BUG
#23: LTO deleted an unreachable init chain) by exactly the class of failure
where "the compiler quietly removed something real" and only adversarial
review caught it. A second LTO implementation is a structurally different
chance to catch the third instance of that class before a user does.

## 1. Availability (measured this session)

- `clang` 18.1.3 (Ubuntu), `lld`/`ld.lld` 18.1.3, `llvm-nm`/`llvm-objcopy`/
  `llvm-objdump`/`llvm-size`/`llvm-ar`/`llvm-readelf` all present at
  `/usr/bin`. `clang --print-targets` includes `arm`, `arm64`, `arm64_32`,
  `armeb` — no `avr` target (AVR backend was removed from upstream LLVM;
  `clang --target=avr` still works because Ubuntu's clang package links an
  AVR backend some distros keep — do not assume this is portable to every
  clang install; it happened to be present here).
- `arm-none-eabi-gcc` 13.2.1 (Debian/Ubuntu package), sysroot resolved via
  `-print-sysroot`/`-print-file-name=`: headers at
  `/usr/lib/arm-none-eabi/include`, per-multilib libs under
  `/usr/lib/arm-none-eabi/newlib/<multilib>/` (libc/libm) and
  `/usr/lib/gcc/arm-none-eabi/13.2.1/<multilib>/` (libgcc). clang needs both
  `-L` paths explicitly (its own multilib autodetection does not know this
  gcc's layout) plus `--sysroot=/usr/lib/arm-none-eabi` for headers.
- `avr-gcc` 7.3.0 at `/usr/bin` (matches the golden-MD5 toolchain exactly —
  confirmed by rebuilding `make -C grbl/platform/atmega328p` — no wait,
  atmega328p is exempt from the platform Makefile pattern; confirmed via
  root `Makefile`'s own `make validate`, MD5 `79af184e67b27defd27a39309ac53563`,
  unchanged throughout this session).
- RISC-V (`riscv64-unknown-elf-gcc`) and XC-DSC (`/opt/xc-dsc`) toolchains
  also present. **Later session (2026-07-26, the correction above)**: clang
  also has working `riscv32`/`riscv64` backends (`clang --print-targets`),
  and picolibc's cross sysroot for this triple lives at
  `/usr/lib/picolibc/riscv64-unknown-elf` (serves rv32 and rv64 targets
  both — the sysroot is ISA-generic, only `-march=`/`-mabi=` on the
  compile line is ISA-specific). XC-DSC remains not a clang candidate at
  all — no LLVM backend exists for dsPIC33A.

## 2. Can clang build one ARM port? (stm32f411, chosen over samd21 — one
board, no per-board `config.h` selection, fewer moving parts)

**Compiles and links: yes**, with caveats below. Built RELEASE by hand
(no Makefile plumbing landed — see §6) mirroring `common/stm32/common.mk`'s
real flag set:
`--target=arm-none-eabi -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16
-mfloat-abi=hard --sysroot=/usr/lib/arm-none-eabi -Os -flto=thin`, linked
with `-fuse-ld=lld` against the two `-L` paths above.

**Two real, load-bearing problems found, one blocking, one already fixed
(and now committed, unrelated to this axis):**

1. ~~**BLOCKING: clang has no equivalent to `-fsingle-precision-constant`.**
   Checked `clang --help` and `clang -cc1 --help` for every flag with
   "single-precision"/"excess-precision"/"fp-eval" in the name —
   `-cl-single-precision-constant` exists but is OpenCL-only (rejected for
   plain C); `-fexcess-precision=`/`-ffp-eval-method=` control evaluation
   width for already-typed expressions, not the type of a bare literal.
   GCC's flag exists specifically to keep unsuffixed floating literals
   `float` instead of promoting to `double` — the entire FP=SINGLE
   contract (CONTRACTS.md §17) that keeps every non-AVR port AVR-faithful
   (avr-gcc's `double==float`) depends on it. Without it, ordinary mixed
   float/literal expressions throughout `planner.c`/`stepper.c`/
   `motion_control.c`/`gcode.c` silently promote through double, and
   `tools/assert_no_double.sh` (run with `llvm-nm`, works fine
   mechanically) **FAILS**: 23 distinct `__aeabi_d*`/`__*df2`/`__*df3`
   double-precision soft-float symbols get linked in, none of which exist
   in the gcc build. This is not a missing feature that can be worked
   around by a prelude macro trick — the existing SP-libm call-site
   mapping (`sqrt(x)` → `sqrtf(x)` etc., already in every port's
   `prelude.h`) only rewrites named function calls, not bare arithmetic
   between a `float` and an unsuffixed literal.
   **Consequence for the axis**: any clang build of an FP=SINGLE port is,
   today, silently an FP=DOUBLE-semantics build wearing an FP=SINGLE
   label — larger code, slower (soft double math on an SP-only FPU), and
   a real behavioral deviation from the AVR-faithful semantic this project
   otherwise polices with a hard post-link assert. This is the single
   fact that should decide the scope question (see §8).~~
   **WRONG — struck through, not deleted, per this project's convention
   for a reversed finding. See the "CORRECTION (2026-07-26)" section at
   the top of this document.** `-cl-single-precision-constant` is not
   OpenCL-gated: `clang -cl-single-precision-constant -### -c x.c` shows
   it forwarded to `-cc1` unconditionally in plain C mode, and it produces
   the identical DP-elimination effect as gcc's flag, verified via IR
   dumps, `nm` on real cross-builds across all 7 real target
   configurations this tree ships, and (this session) a full end-to-end
   port build with the project's own unmodified `assert_no_double.sh`
   passing. The "BLOCKING"/"rejected for plain C" framing below was never
   tested against actual compilation — only against `--help` text.

2. **Real (now fixed, independent of this axis): `stm32f411/script.ld`'s
   `.bss`/`.stack`/`.heap` output sections have no `(NOLOAD)` marker.**
   GNU ld infers `SHT_NOBITS` for an output section whose only content is
   a location-counter advance (no input sections assigned); `ld.lld` does
   NOT make the same inference and emits real, file-backed `SHT_PROGBITS`
   for exactly the same script — `readelf -l` on the two linkers' outputs
   for the identical script shows GNU ld splitting `.bss`/`.stack`/`.heap`
   into three `PT_LOAD` segments with `FileSiz=0`, while lld merges them
   into one segment with `FileSiz==MemSiz`. Consequence:
   `objcopy -O binary` on the lld-linked ELF produced a **402 MB** `.bin`
   (padding the address gap between FLASH at `0x08000000` and the
   RAM-resident heap section lld treated as loadable) instead of ~26 KB.
   Fix verified: adding `(NOLOAD)` to the three output section headers
   (a standards-compliant linker-script directive both GNU ld and lld
   honor identically) restores the expected `.bin` size and `readelf -l`
   segment layout under lld, with **zero effect** on the GNU ld/gcc build
   (confirmed: identical section layout before/after the `(NOLOAD)` edit
   when linked with GNU `ld`).
   **STATUS UPDATE (2026-07-26, later session): LANDED.** Applied to
   every `script.ld` this session was allowed to touch — `_template`,
   `ch32v006`, `ch570`, `stm32f103`, `stm32f411`, `stm32h523`
   (`hc32f460`/`samd21`/`sg2002` were out of scope for this session,
   owned by concurrent work at the time — still need the identical fix,
   flagged, not forgotten). Re-verified zero-cost under gcc on all five
   real (non-`_template`) ports touched: fresh RELEASE rebuild's `.bin`
   `md5sum` matches the committed `artifacts/` tree exactly, on every one.
   Also re-verified the bug itself still reproduces without the fix
   (re-linked the same clang/lld objects against the pre-fix script,
   got the identical 402,783,232-byte `.bin`) and that the fix eliminates
   it under a real clang/ThinLTO/FP=SINGLE build too (33448-byte `.bin`,
   not just the gcc case originally tested).

**Size comparison** (both `-Os -flto`/`-flto=thin`, `FP=SINGLE` requested
on both sides — clang's number is therefore not a fair fully-SINGLE
comparison per finding 1 above, but is the number you get with today's
flags):
| | gcc (LTO) | clang (ThinLTO) |
|---|---|---|
| `.text` | 26132 | 37220 |
| `.data` | 80 | 296 |
| `.bss` | 129968 | 129752 |
| `assert_no_double.sh` | PASS | **FAIL** (23 DP symbols) |

The clang `.text` delta (+11 KB, +43%) is dominated by the DP soft-float
library pulled in by finding 1, not by clang being a worse optimizer per
se — not a clean apples-to-apples number until finding 1 has an answer.

**STATUS UPDATE (2026-07-26, later session): the table above is now
stale on both counts (finding 1 is fixed, and this session's fresh gcc
rebuild measured 26228/80 text/data, not 26132/80 — a small drift from
whatever exact tree state produced the original number, re-confirmed
byte-identical to the committed `artifacts/stm32f411/grbl_stm32f411.bin`
either way). The real, current, genuinely-FP=SINGLE-on-both-sides
comparison, measured this session:**

| | gcc 13.2.1 (`-flto`) | clang 18.1.3 (`-flto=thin`) |
|---|---|---|
| `.text` | 26228 | 33368 |
| `.data` | 80 | 80 |
| `assert_no_double.sh` | PASS | **PASS** (was FAIL before the fix) |
| `init_check.sh` (BUG #23) | PASS | PASS |
| `boot_check.sh` (BUG #21) | PASS | PASS |
| `.bin` size | 26308 (matches committed artifact) | 33448 (no lld bloat, `(NOLOAD)` fix applied) |

The remaining `.text` delta (+7140 bytes, +27%) is now a real
clang-vs-gcc codegen/optimizer comparison — both sides are genuinely
FP=SINGLE, so this is no longer measuring finding 1's DP tax. Not
investigated further this session (out of scope for the reopening
brief, which asked for a landing decision, not an optimizer bake-off);
worth a follow-up if code size on a clang-verified image ever matters
operationally.

**Boot sanity**: with the `(NOLOAD)` fix applied, `common/boot_check.sh`
(BUG #21 ratchet) and `common/init_check.sh` (BUG #23 ratchet) both PASS
on the clang/ThinLTO binary via `llvm-nm` — vector table at `0x08000000`,
`Reset_Handler`/`hal_system_init`/`hal_clock_config`/`hal_gpio_init` all
defined and reachable. `llvm-nm` and `llvm-objcopy` read gcc-built ELFs
without incident (tested directly: `llvm-nm build/grbl_stm32f411.elf`
lists the same symbols GNU `nm` does) — no tool-compatibility gap on
either side of the pairing (gcc ELF + llvm-nm, clang ELF + GNU nm both
work; not required for a landing decision but confirms the "swap NM per
toolchain" plumbing in §4 has no hidden mismatch to design around).

## 3. Core-diagnostic catalogue (the important deliverable)

Complete list of what clang emits on **core** files (`grbl/*.c`, outside
`grbl/platform/`) — never on port files, since those already differ and are
expected to. No core file was edited to silence anything. Two targets
tested: ARM (stm32f411's flags, `-Os -flto=thin`) and AVR (syntax-only pass
with the golden Makefile's flags, `-Os -mmcu=atmega328p`).

### ARM target, core-file diagnostics

| File:line | Diagnostic | Judgement |
|---|---|---|
| `stepper.c:1015` | `-Winteger-overflow`: `TICKS_PER_MICROSECOND*1000000*60` overflows `int`, folds to `1465032704` | **Real, not noise.** gcc's `-Woverflow` already flags the identical line (verified: it was sitting in `ci/warn_baseline_stm32{f103,f411,h523}.txt` as accepted debt) — this is BUG #18's exact class (F_CPU needs a `UL` suffix; already fixed on samd21/ch32v006's own Makefiles) **never rolled out to `common/stm32/common.mk`**, which still has plain `-DF_CPU=$(CLOCK)` with no suffix. Live, currently-shipping, on stm32f103/f411/h523/hc32f460 (every port sharing that common.mk). Flagged here, **not fixed in this session** — out of scope for a toolchain-axis probe, a one-line Makefile fix (`$(CLOCK)UL`) for whoever picks it up next. |
| `settings.c:339` | `-Wconstant-conversion`: `get_limit_pin_mask()` truncates `1<<Z_LIMIT_BIT` (1024→0) for a `uint8_t` return | **Real — this is BUG #26** (fixed this session, see PLAN.md/CONTRACTS.md). gcc's `-Woverflow` had already caught the identical line on all three affected ports; both were sitting in the accepted warning baseline unexamined. The value clang added here was not a fact gcc lacked, it was a sharper diagnostic name prompting someone to actually trace the consequence. |
| `settings.c:26` | `-Wduplicate-decl-specifier`: `const __flash settings_t defaults` — `__flash` expands to `const` on this port's prelude for non-AVR, giving `const const` | Noise. Redundant qualifier, zero behavioral effect, gcc doesn't warn on it by default (no GCC-equivalent warning flag in `-Wall -Wextra`). |
| `nvmem.c:127,149` | `-Wint-in-bool-context`: `(checksum << 1) \|\| (checksum >> 7)` | Noise — already known, already in every port's baseline, already documented as deliberate (CONTRACTS.md §10.4: "Never fix the AVR `\|\|`" — this is the upstream-grbl checksum quirk preserved for byte-golden AVR). |
| `motion_control.c:206` | `-Wunused-parameter`: `cycle_mask` | Noise — already in every port's baseline. |
| `motion_control.c:109` | `-Wabsolute-value`: `fabsf()` given an argument clang infers as `double` | **Was attributed to finding 1 (§2); re-checked this session and no longer reproduces once `-cl-single-precision-constant` is added** — confirms the diagnosis was correct (an unsuffixed literal earlier in the same expression was the cause) and that the fix (§2 correction) actually resolves it, not just the symbol-table symptom. |
| `gcode.c`/`report.c`/`system.c` fallthrough warnings | `-Wimplicit-fallthrough=` | Noise — already in every port's baseline, intentional fallthrough with a comment, same as gcc's identical warning. |
| **Hard errors on core code** | **none** | clang compiles every core `.c` file at `-Os` with zero errors, ARM target. |

### AVR target, core-file diagnostics (syntax-only pass, real Makefile flags
plus `-D_AVR_WDT_H_` — see below for why)

| File:line | Diagnostic | Judgement |
|---|---|---|
| `grbl.h:32` → `<avr/wdt.h>` | **HARD ERROR**, not a warning: `value '64' out of range for constraint 'I'` (×2, inside `wdt_enable`/`wdt_disable`) | **Headline finding for AVR — re-confirmed independently 2026-07-26 (later session), incl. at `-Os` explicitly.** avr-libc's `wdt.h` selects between an I/O-space inline-asm form (`"I"` constraint, 0–63) and a memory-mapped form via a **runtime** `if (_SFR_IO_REG_P(...))` — a compile-time-constant condition GCC folds and dead-code-eliminates before ever validating the untaken branch's asm constraints. clang validates inline-asm operand constraints in both branches before/independent of that dead-branch elimination, so the untaken branch (which targets I/O space registers, not applicable to `WDTCSR`'s actual address on atmega328p) fails to compile even though it can never execute. **Confirmed this is unconditional, not an `-Os`-only artifact**: re-ran at `-Os` explicitly (the hypothesis in the original brief) — identical failure, ruling out "only broken with optimization off." **Nothing in `grbl/` or `grbl/platform/atmega328p/` calls any `wdt_*` function** (grepped `grbl/*.c grbl/*.h` outside `platform/` — zero hits; the ONE reference anywhere is `atmega328p/platform.h`'s `HAL_WATCHDOG_RESET()` macro, itself never invoked by anything — CONTRACTS.md §9 already states "no platform implements this family"), so the remedy is a flags-layer one: `-D_AVR_WDT_H_` pre-defines avr-libc's own include guard, skipping the header's body entirely before `grbl.h`'s unconditional `#include <avr/wdt.h>` is reached. Verified: with that one define, all 18 core `.c` files pass `-fsyntax-only` with **zero errors**. This is exactly the kind of flags-layer-only, core-file-untouched remedy CONTRACTS.md's core-purity rule ([§32](CONTRACTS.md#core-purity-under-a-second-toolchain)) requires. |
| `report.c` (55 lines) | `-Wunknown-attributes`: `unknown attribute '__progmem__' ignored` (`PSTR()` macro → avr-libc's `PROGMEM` → `__attribute__((__progmem__))`) | **Headline finding, functionally severe, not cosmetic — re-confirmed independently 2026-07-26.** Verified directly (small isolated test file, not just the warning text): `const char PROGMEM msg[] = "hi"` compiled with clang for AVR lands `msg` as an ordinary `R` (rodata) symbol with an **undefined reference to `__do_copy_data`** pulled in — i.e., clang silently drops the attribute and the object falls back to avr-gcc's ordinary Harvard-architecture behavior for `const`: copied from flash to RAM at startup by crt0's data-init loop, not left resident in flash and read back via `LPM`. The GNU named-address-space spelling (`const __flash char x[]`) fares **worse**: it compiles with **no diagnostic at all** and the same wrong placement — clang accepts the syntax and silently discards its meaning. Consequence for a real Tier-1 AVR build: `report.c`'s ~50 status/error `PSTR()` strings plus `settings.c`'s entire default-settings table (`const __flash settings_t defaults`) would all get copied into SRAM at boot instead of staying in flash — on a chip with **2 KB total RAM**, this does not merely waste space, it is very likely a silent RAM overflow with no link-time error (AVR linkers here have no `script.ld`-style `MEMORY{}`/`ASSERT` region enforcement the way the ARM ports do) — exactly the "compiles, links, boots wrong" class this project exists to catch, except the failure mode here is baked into the target's language-extension support, not LTO. This alone is close to disqualifying for AVR (see §11) — combined with the golden-MD5 argument (which by itself already settles it), AVR is gcc-only forever, full stop. |
| `stepper.c:326,496`, `serial.c:94,130`, `system.c:64`, `limits.c:107` | `-Wunknown-attributes`: `unknown attribute 'externally_visible' ignored` (ISR macro's `__INTR_ATTRS`) | **Checked, confirmed noise, not a defect.** `externally_visible` is a GCC whole-program-optimization visibility hint; separately verified that the co-occurring `signal` attribute (the one that actually matters — it controls whether the AVR backend emits interrupt-correct prologue/epilogue and `reti` instead of `ret`) **is** recognized by clang: compiled an isolated `ISR(...)` body and inspected the emitted assembly directly — full register/SREG save-restore and a trailing `reti`, byte-for-byte the shape an AVR ISR needs. `externally_visible` being silently ignored has no calling-convention consequence. |
| **Hard errors on core code, unconditional (not `-Os`-dependent), other than `wdt.h`** | **none found** | All 18 core `.c` files pass `-fsyntax-only` once the one wdt.h workaround is applied — re-confirmed with a fresh, independent sweep this session (`clang --target=avr -mmcu=atmega328p -Os -D_AVR_WDT_H_ ...` over every `grbl/*.c`, zero non-zero exits). |

## 4. ThinLTO differential (stm32f411, `-flto=thin` vs. gcc's `-flto`)

**No BUG #21/#23-class regression found.** `vector_table`, `Reset_Handler`,
`hal_system_init`, `hal_clock_config`, `hal_gpio_init` all present and
reachable in the ThinLTO build (`init_check.sh`/`boot_check.sh` both PASS,
§2). This is expected, not a coincidence: the mitigations those two bugs'
fixes landed (`__attribute__((used))` plus an address-taken reference in
`Reset_Handler`, and a real call from `Reset_Handler` into the init chain)
are portable C mechanisms, not GCC-specific pragmas — so they hold under a
structurally different LTO implementation too. That is itself a useful
negative result: the FIX for BUG #21/#23 was done right the first time
(compiler-portable, not GCC-whisperer tricks), which a second LTO
implementation now corroborates rather than merely assumes.

**One difference found, investigated, confirmed benign**: a straight `nm`
symbol-name diff between the gcc and clang RELEASE ELFs shows ~40 names
present in gcc's output absent from clang's — nearly all of them the
board's unused peripheral IRQ vectors (`ADC_IRQHandler`,
`DMA1_Stream*_IRQHandler`, etc.), each declared
`__attribute__((weak, alias("Default_Handler")))`. clang's LTO resolves
the alias directly to `Default_Handler`'s address at the vector-table's
one use site and does not bother emitting a separate named symbol table
entry for the now-redundant alias name — gcc's LTO keeps the alias name.
**Verified this is a naming artifact, not lost code**: dumped the raw
vector table bytes at `0x08000000` and confirmed the slot for, e.g.,
`ADC_IRQHandler` (array index 34) contains `Default_Handler`'s real
address with the Thumb bit set — the code that runs is identical, only
the debug-visible name for the alias is gone. Also observed: several
internal `static` variables (`block_buffer`, `segment_buffer_head`, `pl`,
`prep`, etc.) lose their names in the clang/ThinLTO symbol table entirely
— expected LTO internalization behavior for locals with no external
reference once whole-program visibility resolves them, not a size or
placement difference (confirmed via the `.bss`/`.data` size table in §2,
once the `(NOLOAD)` fix is applied, sizes track close to 1:1 modulo the
DP-soft-float delta already explained).

**Conclusion: ThinLTO did not find a new instance of the class it was
brought in to find, on this port, this session.** Worth stating plainly
since a negative result here is exactly as valid a probe outcome as a
positive one.

**STATUS UPDATE (2026-07-26, later session): re-run for real against a
genuinely FP=SINGLE clang image** (the run above predates the §2
correction, so it was measured on a DP-contaminated binary — the
DP-soft-float delta it references in the last paragraph no longer
exists). The full end-to-end build in the correction section at the top
of this document IS this re-run: same conclusion holds
(`init_check.sh`/`boot_check.sh` both PASS), now on the binary that
actually matters. No new BUG #21/#23-class finding on the corrected
build either — this is the honest negative result the reopening brief
asked for, not assumed unchanged from the earlier, DP-contaminated run.

## 5. Layer design (for when/if this lands)

Three layers, cleanly separated so a port's Makefile never has an `ifeq
($(TC),...)` chain:

- **Layer 1 — port semantic** (unchanged, in each port's own Makefile):
  the port declares *what* it wants — `-Os`-class size optimization, no
  double precision, LTO on, freestanding. It does not know or care which
  compiler realizes those wants.
- **Layer 2 — toolchain dialect** (`common/toolchain/family/gcc.mk`,
  `common/toolchain/family/clang.mk` — **LANDED this session, see "Landed
  plumbing" below**): *how* a given compiler spells layer 1's wants —
  `-Os` vs. `-Oz` (clang's smaller-but-slower size level, worth trying if
  the axis ever needs it, not adopted by default), `-flto` vs.
  `-flto=thin`, and critically the `CC`/`NM`/`OBJCOPY`/`OBJDUMP`/`SIZE`
  binary names the existing ratchets (`assert_no_double.sh`,
  `init_check.sh`, `boot_check.sh`) already take as parameters — no
  ratchet script needs to change, they already accept the tool name as an
  argument (confirmed this session again, end-to-end: `llvm-nm` drops
  into both scripts' existing `nm`-argument slot with zero script
  changes, and both scripts PASSED against a real clang-built ELF).
- **Layer 3 — target dialect** (per-port, e.g.
  `stm32f411/Makefile`): `-mcpu=`/`-mfpu=` are identical strings for gcc
  and clang on ARM (confirmed — same flag spelling both toolchains, this
  session's build used the port's real `CPU`/`FPU` Makefile variables
  unchanged). Where a genuine per-(platform × compiler) difference
  exists, the naming convention is `EXTRA_CFLAGS_$(TC)` (e.g.
  `EXTRA_CFLAGS_clang`), appended once by layer 2, never an `ifeq` chain
  in the port file. **After this session, the one concrete instance
  originally flagged here (§2 finding 1's SP-libm mapping "might need a
  clang-specific prelude variant") turned out to need NO such variant —
  `-cl-single-precision-constant` alone, supplied once by layer 2's
  `TC_FP_SINGLE_CFLAGS`, is sufficient. No `EXTRA_CFLAGS_clang` instance
  exists in the landed plumbing.**

`TC ?= gcc` in every port's Makefile (or wherever layer 2 is included)
keeps every existing build path byte-identical by default — nothing about
today's `make` invocations changes unless `TC=clang` is passed explicitly.
**This session: the family/profile files exist and are proven correct,
but `TC ?= gcc` is not yet wired into any port Makefile — see "Landed
plumbing" for why, and for the byte-identity proof performed a different
way (out-of-tree) instead.**

## 6. Per-port toolchain support (measured/inferred this session)

**STATUS UPDATE (2026-07-26, later session) — table corrected in place;
original text struck through where superseded, kept for the record:**

| Port | `TOOLCHAINS_SUPPORTED` | Why |
|---|---|---|
| `atmega328p` | **gcc only, forever** (unchanged) | Golden MD5 is *defined* by avr-gcc 7.3.0's exact codegen — there is no "clang matches" question to ask, byte-identity to a specific compiler's output IS the spec. Independent of that: clang's AVR target has a hard compile error in avr-libc's `wdt.h` (unconditional, §3) and — more seriously — no working PROGMEM/`__flash` support at all (§3), which for an 18-string-plus-a-settings-table 2 KB-RAM target is close to disqualifying even ignoring the golden-MD5 question. **Re-confirmed independently this session, unchanged conclusion.** |
| `dspic33ak128mc102` | **XC-DSC only** (unchanged) | Different ISA family entirely (dsPIC33A), no LLVM backend exists for it. Not a clang candidate under any flag combination. |
| ~~`stm32f103`/`stm32f411`/`stm32h523`/`hc32f460` (ARM Cortex-M, FP=SINGLE) — gcc only, until §2 finding 1 has an answer~~ **CORRECTED: gcc + clang, FP=SINGLE holds under both.** | Compiles, links, and now genuinely satisfies FP=SINGLE under clang: `-cl-single-precision-constant` closes finding 1 (see the correction at the top of this document). `assert_no_double.sh`/`init_check.sh`/`boot_check.sh` all PASS on a real end-to-end stm32f411 build (this session). `stm32f103`/`stm32h523` share the identical `common/stm32/common.mk` flag shape and the identical M3/M33 symbol-level result (§ correction table) — not independently linked end-to-end this session, but the mechanism-level evidence is as strong as stm32f411's was before its own end-to-end proof. `hc32f460` was out of scope this session (concurrent work) — Cortex-M4 symbol-level result (identical to stm32f411's own M4 case) applies, but this port specifically was not independently tested. |
| `dspic33ak128mc102`-adjacent native-DOUBLE ports (none landed yet) | n/a | A future FP=DOUBLE-by-design ARM/RISC-V port would not hit finding 1 at all — worth remembering this blocker is FP=SINGLE-specific, not universal. (Now moot for FP=SINGLE ports too, but the observation stands.) |
| ~~`samd21`, `ch32v006`, `ch570` — untested this session, same FP=SINGLE blocker expected~~ **CORRECTED: gcc + clang at the object level, confirmed this session; RISC-V link-level unverified.** | `ch32v006` (rv32ec_zicsr/ilp32e) and `ch570` (rv32imc_zicsr/ilp32) both independently measured at the object-file level this session: `-cl-single-precision-constant` eliminates the identical DP-libcall set gcc's `-fsingle-precision-constant` eliminates, byte-for-byte symbol match confirmed against real riscv64-unknown-elf-gcc on the same test input. Neither was linked end-to-end through its own `script.ld`/picolibc the way stm32f411 was (out of scope this session — flagged, not silently assumed). `samd21` (Cortex-M0+) was measured at the object level (identical symbol-elimination result to stm32f411's own M0+-adjacent case) but not linked end-to-end — also out of scope (concurrent work owns this port this session). |
| `sg2002` | n/a (unchanged) | Design-complete, implementation-deferred at the time of the original recon; **now built** (PLAN.md, "sg2002 COMPLETE") but out of scope for this session's clang work (concurrent-work boundary). rv64imac_zicsr/lp64 measured at the object level this session (identical DP-elimination result) — not linked end-to-end. |

**Overall recommendation for this axis's scope, given the data above: see
§11 (corrected) at the end of this document — the honest scope today is
NOT zero ports.**

## 7. `artifacts/` stays keyed to ONE canonical toolchain (gcc)

`artifacts/` is the release/observability surface (PLAN.md's "track build
artifacts in git" decision) — it must have one unambiguous byte-identity
target per unit or the staleness ratchet (`tools/build_artifacts.py
check`) cannot state a single fact about whether a given commit's
artifact is fresh. clang is a **verification axis**, not a **release
axis**: nothing under `artifacts/` should ever be produced by
`TC=clang`, regardless of whether the axis lands. This needs to be an
explicit, written rule (not just current practice) the moment `TC=clang`
exists as an option at all, because the failure mode is not hypothetical
— `tools/build_artifacts.py build` has no `--toolchain` flag today, and
the very first person who runs it after a `TC` default gets flipped
locally, or who adds `--toolchain=clang` "just to try it," silently
produces a same-named artifact file the manifest cannot distinguish from
a gcc build. The rule this document proposes: `tools/build_artifacts.py`
should refuse (loud error, not silent) to record any `TC` other than the
per-unit canonical one into `artifacts/`, the same way it already refuses
a stale manifest today.

**STATUS (2026-07-26, later session): rule still stands, unchanged, now
with a name for it — "canonical-toolchain rule" (`docs/
TOOLCHAIN-VERSIONS.md` §5, which generalizes this exact rule to the
version axis too and already treats atmega328p's golden-MD5 mechanism as
the founding instance). `tools/build_artifacts.py` was NOT modified this
session** (no `--toolchain` flag added, no enforcement landed) — this
remains a proposed rule, not yet code. Every profile this session's
"Landed plumbing" section adds is documented as canonical-vs-verification
in its own file header, but nothing enforces that at the tooling level
yet. Flagged as a real remaining gap, not silently assumed closed.

## 8. Warn baselines must be keyed per-toolchain

`ci/warn_baseline_<port>.txt` today implicitly means "gcc's warning set."
The moment clang builds anything, its warning vocabulary is different
enough (different names for overlapping diagnostics, entirely new
categories like `-Wconstant-conversion` with no gcc equivalent, as §3
shows) that reusing the same baseline file either floods the ratchet with
every one of clang's differently-worded restatements of already-accepted
gcc warnings, or — worse — silently accepts clang-only new warnings
because the ratchet was never asked to distinguish. Proposed convention:
`ci/warn_baseline_<port>.<tc>.txt` (e.g.
`ci/warn_baseline_stm32f411.gcc.txt`, `ci/warn_baseline_stm32f411.clang.txt`),
with `ci/warn_ratchet.py` taking the toolchain as an explicit argument
(same pattern as the NM-binary argument it already takes) rather than
inferring it. This session's own core-diagnostic catalogue (§3) is a
worked example of why this matters: several of clang's diagnostics on the
exact same lines gcc already flagged use different `-W` names entirely
(`-Wconstant-conversion` vs. gcc's `-Woverflow`, both on
`settings.c:339`) — a single shared baseline file would treat these as
two different warnings needing two different accept-lines for the same
fact, defeating the "one line per real thing" design the ratchet already
has for gcc alone.

**STATUS (2026-07-26, later session): rule still stands, unchanged. No
`ci/warn_baseline_*.clang.txt` file was created this session** — doing so
without a CI job (or at least a documented manual invocation) to generate
it from a real log would be inventing a baseline with no build behind it,
exactly the kind of guard that cannot meaningfully fail this project
warns against elsewhere. This is real, deferred work: the moment a port's
Makefile is wired to `TC=clang` (this session deliberately did not do
that — see "Landed plumbing"), a real warning log exists to seed the
baseline from, and this convention should be applied then, not invented
speculatively now.

## 9. Core-purity rule — proposed CONTRACTS.md wording

**STATUS (2026-07-26, later session): ALREADY LANDED**, independently of
this session's work — `CONTRACTS.md` §32
(`core-purity-under-a-second-toolchain`) carries this exact rule
verbatim (checked directly, not assumed from this document's own
proposal text below matching). No action needed; the proposed text below
is kept for historical context of where §32 came from.

A diagnostic on frozen core code is never fixed by editing core — only
suppressed at the flags/prelude layer, or accepted in a baseline. This
session found several concrete instances of exactly that choice already
being made correctly by the existing project (the `nvmem.c` `||`
quirk, CONTRACTS.md §10.4: "Never fix the AVR `||`") — the rule below
generalizes that precedent explicitly for the toolchain axis, since
clang will surface core-code diagnostics gcc's baseline never had reason
to record.

```
<a id="core-purity-under-a-second-toolchain"></a>
## 32. Core-purity rule for a second toolchain (cite the slug, not "§32", from elsewhere)

grbl/ (outside grbl/platform/) is byte-for-byte frozen — written for
avr-gcc 7.3.0 in 2011, golden-MD5-gated, and never edited to satisfy any
tool. A second compiler will emit diagnostics on core files a
single-compiler baseline never had reason to record; that is the entire
point of running one. When that happens:

1. NEVER edit a grbl/ core file to silence a diagnostic, on any
   toolchain, for any reason. Not even a redundant-qualifier or
   dead-code-branch fix. The byte-golden AVR invariant is the project's
   central thesis; a "harmless cleanup" on core is not exempt from it
   just because it was clang, not gcc, that found the spot.
2. A diagnostic on core code is handled at exactly one of two layers:
   (a) the flags/prelude layer, if a compiler flag or a pre-processor
   define can make the diagnostic legitimately not apply (example this
   session: `-D_AVR_WDT_H_` skips an unused, uncallable avr-libc header
   whose untaken branch clang validates differently than gcc — a
   flags-layer fact about the header, not a claim about core); or
   (b) accepted into that toolchain's own warn baseline
   (ci/warn_baseline_<port>.<tc>.txt, see the toolchain-axis doc) if
   there is no legitimate flag-layer suppression and the diagnostic is
   judged noise, with the judgement written down at the point of
   acceptance, not silently absorbed.
3. If a diagnostic on core code cannot be handled either way — it is a
   genuine hard error with no flags-layer bypass, and it is not
   noise — that toolchain does not support that port. Record it as a
   TOOLCHAINS_SUPPORTED exclusion (toolchain-axis doc), not as a TODO to
   eventually silence.
4. A hard ERROR (not warning) on core code under a toolchain being
   evaluated is a headline finding, not routine baseline noise — report
   it prominently the moment it's found (this session: avr-libc's
   wdt.h "value out of range for constraint" under clang, handled per
   rule 2(a) since a flags-layer bypass existed; had none existed, rule 3
   would have applied and AVR would already be gcc-only for this reason
   alone, independent of the golden-MD5 argument that also applies).
```

## 10. CI cost, honestly

Not a 10-port × 2-toolchain × 2-flavor cartesian product (40 rows). One
representative per ISA family as a separate matrix leg is the honest
shape:
- ARM Cortex-M family: one port (stm32f411 is already the recon target;
  keep it as the representative rather than re-picking).
- RISC-V family: one port (ch32v006 or ch570 — not tested this session).
- AVR: **not a clang leg at all** — §6/§3 already answer this one, no CI
  minutes should be spent re-asking it per push.
- dsPIC: **not a clang leg** — no LLVM backend exists for the ISA.

That is a 2-row addition (ARM-representative × clang, RISC-V-representative
× clang) to whatever the gcc matrix already is, run as a separate,
clearly-labeled "toolchain verification" leg — not blocking (report-only,
same posture as the provenance workflow), since a clang failure means
"clang found something or clang itself has a gap," neither of which
should block a gcc-verified release the way a real gcc regression would.

**STATUS (2026-07-26, later session): shape unchanged, now buildable.**
"RISC-V family: one port — not tested this session" is now tested at the
object level (both ch32v006's and ch570's ISA variants, plus sg2002's
rv64 — three RISC-V ABI variants, not just one representative, since
testing all three cost nothing extra once the harness existed). The CI
row recommendation is unchanged: still 2 rows (one ARM-representative,
one RISC-V-representative), still report-only, still not landed this
session (no `.github/workflows/ci.yml` edit — CI wiring is out of scope
until the Makefile-level `TC=clang` wiring itself lands, which this
session deliberately deferred, see "Landed plumbing").

## 11. Recommendation (original, superseded — kept for the record)

~~**Do not land the `TC=gcc|clang` plumbing yet.** Every port tested or
reasoned about this session fails the FP=SINGLE ratchet under clang for
a fundamental (not flag-gap) reason — clang has never implemented an
equivalent to `-fsingle-precision-constant`, and that is not something a
prelude trick or a Makefile flag can route around, because it changes the
*type* GRBL core's own unsuffixed floating-point literals get, throughout
`planner.c`/`stepper.c`/`gcode.c`/`motion_control.c`. Landing the axis
today would mean either (a) a `TC=clang` that silently runs every
FP=SINGLE port as FP=DOUBLE with no visible label change, defeating the
whole reason FP=SINGLE exists, or (b) disarming `assert_no_double.sh` for
clang specifically, which converts the project's own hard-won correctness
ratchet into a toolchain-flag-shaped hole.~~

~~That said, this was not a wasted probe...~~

~~If the FP=SINGLE blocker ever gets a real answer... Until then: **the
honest scope of this axis today is zero ports**, and that is a valid,
useful answer for the owner to rule on, not a failure of the probe.~~

**The premise above ("clang has never implemented an equivalent") was
false — see the correction at the top of this document. Recommendation
below replaces it.**

## 11b. Recommendation (corrected, 2026-07-26, later session)

**Land the Layer-2 plumbing (done — see "Landed plumbing" below). Do NOT
wire it into any port Makefile this session.** With the blocker gone, the
numbers are:

- **7 of 10 real-hardware ports (everything except atmega328p,
  dspic33ak128mc102, and the design-only gap) are clang-buildable at the
  mechanism level with FP=SINGLE genuinely holding**: stm32f103/f411/
  h523/hc32f460 (ARM), ch32v006/ch570/sg2002 (RISC-V). Of those, **1 is
  proven end-to-end** (stm32f411: real 24-file build, real link via
  `lld`, real `assert_no_double.sh`/`init_check.sh`/`boot_check.sh` all
  PASS on the resulting ELF) and **6 are proven at the object/symbol
  level only** (identical DP-elimination mechanism, not independently
  linked through their own `script.ld`/crt0/picolibc).
- **2 ports are gcc-only forever, unrelated to the FP=SINGLE fix**:
  `atmega328p` (golden-MD5 IS avr-gcc 7.3.0's exact output, plus a
  disqualifying, independently-reconfirmed PROGMEM defect and a
  reconfirmed `wdt.h` hard error with a working flags-layer bypass),
  `dspic33ak128mc102` (no LLVM backend for the ISA at all).
- **Landing the axis earns its cost for the ARM family specifically,
  today**: one representative (stm32f411) is fully proven, the other
  three ARM ports share byte-identical flag shapes
  (`common/stm32/common.mk`) and the identical Cortex-M3/M4/M33
  symbol-level result, so the marginal risk of them differing is low
  and cheap to close (link each end-to-end, ~30 minutes of work per
  port, not a new investigation).
- **RISC-V earns provisional landing** — the mechanism is proven
  uniformly across all 3 ISA variants this tree ships, but "provisional"
  until at least one port is linked end-to-end the way stm32f411 was;
  recommend that be the very next session's first task before RISC-V
  moves from "verification-only, object-level" to "verification-only,
  proven" in the per-port table.
- **The honest scope of this axis today is: plumbing landed, ARM proven,
  RISC-V mechanism-confirmed-but-not-linked, AVR/dsPIC out for reasons
  unrelated to the original blocker.** Not zero ports, and not "all
  clang-capable ports fully proven" either — stated with the numbers
  above, not a single adjective.

**Why the Makefile wiring itself was NOT done this session** (a
deliberate scope decision, not an oversight): this session's brief
flagged a concurrently-live agent auditing ratchet invocation across
port Makefiles — the exact lines (`ASSERT_FP =`, `INIT_CHECK =`,
`BOOT_CHECK =`, the `CC`/`PREFIX` assignments) that landing `TC=` support
would need to touch. Rather than risk a collision on files another
session was actively working on, this session:
1. Built and proved the family/profile plumbing completely (below),
2. Proved it produces the exact right flags/tools per profile (`make -f`
   test harness, all profiles),
3. Proved the mechanism it enables works end-to-end (the full manual
   stm32f411 build above, using the same flags the plumbing would
   generate),
4. Left the actual `include common/toolchain/profiles/...` line out of
   every port Makefile, so this session's changes are add-only new files
   plus linker-script edits — zero risk of clobbering concurrent
   Makefile work.

This is a real, disclosed scope cut: the plumbing is landed as files, not
as wired behavior. "Land what earns its place" is satisfied for the
files themselves (measurably correct, proven against real output); the
wiring step is the next session's first task, not silently absorbed into
"done."

---

## Landed plumbing (2026-07-26, later session)

Three-layer design (§5) implemented as new files, per the design docs'
own proposed layout, with the `TC_VER` branching correction `docs/
TOOLCHAIN-VERSIONS.md` §4 already called for:

```
common/toolchain/family/gcc.mk     # TC_CC/TC_NM/TC_OBJCOPY/.../TC_OPT_FLAG/
                                    # TC_LTO_CFLAGS/TC_FP_SINGLE_CFLAGS,
                                    # TC_VER-gated -fanalyzer/-Wuse-after-free/
                                    # -Wdangling-pointer ladder
common/toolchain/family/clang.mk   # same variable surface, clang spellings:
                                    # -Oz available but NOT default (-Os kept
                                    # for gcc parity), -flto=thin, llvm-*
                                    # tools, -cl-single-precision-constant
common/toolchain/profiles/avr-gcc-7.3.mk    # CANONICAL atmega328p
common/toolchain/profiles/avr-gcc-15.mk     # verification, one-time data point
common/toolchain/profiles/avr-gcc-16.mk     # verification, weekly-job candidate
common/toolchain/profiles/arm-gcc-13.2.mk   # CANONICAL stm32f103/f411/h523/hc32f460
common/toolchain/profiles/arm-gcc-14.2.mk   # verification
common/toolchain/profiles/arm-clang-18.mk   # verification, PROVEN end-to-end
common/toolchain/profiles/riscv-gcc-13.2.mk # CANONICAL ch32v006/ch570/sg2002
common/toolchain/profiles/riscv-clang-18.mk # verification, object-level only
```

Every file has a header comment stating whether it is canonical or
verification-only, per the canonical-toolchain rule (§7, `docs/
TOOLCHAIN-VERSIONS.md` §5): exactly one profile per unit may ever own
`artifacts/`; every other profile for that unit is verification-only by
construction (its header says so) and this session never ran
`tools/build_artifacts.py build` against a non-canonical profile (in
fact never ran it at all — no artifact was touched this session).

**Correctness proof (since nothing is wired in yet, "byte-identical to
existing build paths" is proven two ways, not by rebuilding through the
plumbing):**
1. **Trivially, by construction**: `grep -rn "toolchain/family\|toolchain/
   profiles" grbl/platform/*/Makefile grbl/platform/*/*.mk` → zero
   matches. No existing Makefile includes any of these files yet, so no
   existing build path can possibly be affected — the byte-identity
   claim for every current build is vacuously true this session.
2. **The plumbing itself is correct**: a standalone `make -f` test
   harness (not committed — scratch-only, this session's proof, not
   project infrastructure) included each profile and printed its
   resulting `TC_CC`/`TC_NM`/`TC_OPT_FLAG`/`TC_LTO_CFLAGS`/
   `TC_FP_SINGLE_CFLAGS`/`TC_VER_GE_10`/`TC_VER_GE_12` — every profile
   parsed with zero Make errors and produced the exact flags this
   document's tables above report using, cross-checked line by line
   (e.g. `arm-clang-18.mk` → `CC=clang --target=arm-none-eabi
   --sysroot=/usr/lib/arm-none-eabi`, `FP=-cl-single-precision-constant`,
   `LTO_L=-flto=thin -fuse-ld=lld` — the identical flags used in the full
   end-to-end stm32f411 build above, which independently proves those
   flags work, not just that the Makefile variable expands correctly).
   `avr-gcc-7.3.mk` (the canonical AVR profile) correctly leaves
   `TC_VER_GE_10`/`TC_VER_GE_12` empty (7.3 < both thresholds) —
   confirms the `TC_VER` branching family/gcc.mk implements actually
   gates as designed, not just documented as a plan.

**What "landed" does NOT mean here**: no port's real build today invokes
any of these files. The next session that wires `TC ?= <profile>` into a
real port Makefile (starting with `common/stm32/common.mk`, since that's
the one file feeding four ARM ports at once) must re-run the byte-
identity proof the load-bearing way — rebuild through the actual wired
Makefile with `TC` defaulted, diff against `artifacts/` — before that
lands, exactly the way this session did for the `(NOLOAD)` script.ld fix.

## Process-failure retrospective (what was checked, what was not — 2026-07-26)

The sentence that cost this axis was one line in the original §2 finding
1: `-cl-single-precision-constant exists but is OpenCL-only (rejected for
plain C)`. That sentence was written after reading `--help` output, not
after running the compiler. Stated plainly, for whoever reads this next:

**What the original recon checked**: `clang --help`/`clang -cc1 --help`
grepped for flag names containing "single-precision"/"excess-precision"/
"fp-eval". Found the one candidate flag. Read its help text. Stopped.

**What it did not check**: whether the flag's help text ("OpenCL only")
was actually enforced by the compiler when the flag was used outside
OpenCL mode. One `clang -cl-single-precision-constant -c x.c` — a single
extra command — would have shown `EXIT 0`, no rejection, immediately.

**What this session (and the review before it) checked instead**: the
flag on real C source, at three levels of scrutiny (does it compile
without error; does the IR show the literal-typing change it claims to
make; does a real cross-compiled object's symbol table lose the DP
libcalls) — and, this session specifically, whether the effect
generalizes across every real target-ISA/ABI combination the project
ships (it does, uniformly, §2 correction table) and whether it survives
a full port build through a real linker with the project's own
unmodified ratchet scripts (it does, stm32f411, this document's
correction section).

**The generalizable lesson, stated for the next axis-closing decision in
this project**: a tool's own `--help` text describing a flag's intended
use case is not evidence about what the tool's parser actually enforces.
Where a single command can distinguish "documented as X" from "behaves as
X," run the command before writing the conclusion down. This is not a
new rule for this project — it is the same discipline PORTING-CHECKLIST.md
and CONTRACTS.md already apply to hardware register claims ("RM-verified"
vs "UNVERIFIED, flagged at definition site") — but this session is the
first time it cost an entire axis's conclusion, so it is worth stating
here, at the point where it was learned, rather than only in the abstract.
