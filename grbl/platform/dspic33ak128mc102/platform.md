# dsPIC33AK128MC102 port — THE THIRD ISA FAMILY

Microchip dsPIC33A 32-bit DSC core: neither ARM nor RISC-V. 200 MHz,
dual-precision hardware FPU, motor-control PWM + SCCP, PPS pin remap,
28-pin package — the modern heir to the ATmega328p DIP-28 form factor.
Community hardware reference: MC106 Curiosity (needs its own `boards/`
dir; the shipped `boards/generic` is a paper pinout for the bare chip).

## Status (Phase 6 rolling #2 — Steps 3-6 COMPLETE, 2026-07-26)

- M1: skeleton compiles (toolchain crt0 + linker-synthesized IVT — see
  `platform.c` startup-model banner for why there is no `startup.c`).
- M2: clock 200 MHz (FRC→PLL1, sequence from Microchip's own dsPIC33A
  clock docs — **UNVERIFIED ON SILICON**, no emulator exists) + GPIO
  (LAT/PORT/TRIS/ANSEL/CNPU model, token-paste accessors, critical-
  section-wrapped single-bit writes — see `gpio.h` ATOMICITY note).
- M3: all core `.c` compile.
- **Steps 3-6 (real implementations)**: T1 = stepper timer, SCCP1 =
  pulse-reset (software x8 rescale of the 8-bit overflow-horizon contract
  instead of a hardware /8 prescale — this timer doesn't have one),
  SCCP2 = spindle PWM, UART1 (freshly mined register model — no donor
  port existed for this ISA's UART), NVMEM via ROW PROGRAM into a
  linker-reserved fixed flash address (`__attribute__((address(...)))`,
  link-tested clean against the unmodified vendor `.gld`), GPIO Change
  Notification arm/disarm, real ISR bodies (flag-clear-first, dispatching
  to the core-supplied `__isr_step_impl`/`LIMIT_INT_IRQHandler`/
  `CONTROL_INT_IRQHandler`), real `_delay_us/_delay_ms` via the
  toolchain's own `__delay32`/`libpic30.h`. **`make BUILD=DEBUG` and
  `make BUILD=RELEASE` both build the full ELF+hex and link with ZERO
  `PORT_TODO_*`** (verified: `nm | grep PORT_TODO` empty on both). Sizes:
  RELEASE 41816 B (~41.8KB) code / DEBUG 53220 B (~53.2KB) code (128KB
  flash), RAM ~3.8KB RELEASE (16KB). **These figures are exact and
  reproducible, not approximate** — settled by codegen comparison, not by
  reading the compiler's message text: a RELEASE (`-Os`) build prints
  `Options have been disabled due to restricted license` from `xc-dsc-gcc`
  on every translation unit, and a rebuild of the whole firmware with an
  explicit `-O2` in place of `-Os` produces a BYTE-IDENTICAL 41816 B image
  with zero restriction messages. So the free/unlicensed tier of this
  Microchip compiler silently substitutes `-O2` codegen for `-O3`/`-Os`
  rather than failing loudly or producing a fuzzy result — RELEASE here is
  `-O2`-equivalent codegen, not true `-Os`, but its byte count is exact.
  This is Microchip's own licensing-tier behavior, not this port's install
  recipe: `--LicenseType FreeMode` is the installer's own default (the
  `WorkstationMode`/`NetworkMode` alternatives need an account-bound
  activated license file, not a flag), and Microchip's own bundled manual
  describes the free tier as giving "the basic amount of code optimization"
  vs "increased levels" on PRO. A 60-day free PRO evaluation exists but is
  account-bound, interactive, time-limited, and not CI-scriptable, so it
  isn't a path to a truly-`-Os` automated build — don't re-investigate it.
  (The multi-segment Harvard memory layout — `readelf` shows multiple
  `.text` sections at different program-memory pages — and the lack of a
  `size` tool in xc-dsc are real quirks of this ISA, but they don't affect
  the byte counts above: those come from the same linked `.elf` both
  times.) See CONTRACTS.md §16 items 12-20 for the full register-
  fact writeup, including two specific RM-only gaps (SCCP MOD/CLKSEL/
  TMRPS encodings, PPS OUTPUT function-select codes) that are structurally
  real but numerically UNVERIFIED pending hardware bring-up.
- **FP=DOUBLE is this port's declared default** (native DP FPU — the
  chip class CONTRACTS.md §17.3 was written for): `Makefile` sets
  `FP ?= DOUBLE`, disarms `assert_no_double.sh`, and documents why inline.
  `FP=SINGLE` remains available (bidirectional knob, `boards/generic/
  prelude.h` carries the same SP libm shim as samd21) but is not the
  default and has not been runtime-exercised (no dsPIC33A emulator
  exists).
- NOT in CI yet: unattended toolchain fetch in CI is a separate ledger
  item (PLAN.md).

## Known toolchain defects

- **`xc-dsc-nm --print-size` silently drops ~90% of function symbols**
  (found auditing `artifacts/dspic33ak128mc102/*.syms` — it summed to
  ~8.2KB against the 41816B RELEASE binary). Root cause, confirmed via
  `xc-dsc-objdump -t`: xc-dsc-gcc/as only emits an ELF `.size` for a small
  minority of functions (~50-60 of ~210 in this port; libm/vendor-object
  functions mostly, plus a handful of core ones). For the rest the symbol
  table entry has NO size at all — not a printed `0`, an absent field —
  and `nm --print-size` combined with `--size-sort` doesn't list a
  sizeless symbol with a blank/zero size, it omits the row entirely. That
  silently dropped `main`, `protocol_main_loop`, `st_prep_buffer`,
  `gc_execute_line`, and most of the rest of this port's code from the
  tracked artifact, understating it by ~33KB with no visible error.
  Fixed in `tools/build_artifacts.py` (`gen_symbol_map` /
  `_estimate_code_symbols`): for this unit only, symbols nm can't size are
  recovered from `xc-dsc-objdump -t` (addresses) + `-h` (code-section
  bounds) via address-delta-to-next-function, capped at the containing
  section's end. Recovered rows are tagged `objdump addr-delta estimate`
  in the `.syms` file — accurate to within a few bytes (jump-table/padding
  bytes between two functions can land on either neighbour depending on
  scan order) but no longer silently absent. Spot-checked against known
  quantities (see "Known repo-wide dead code on this port" below): the
  estimator reproduces `report_echo_line_received`=40B,
  `delay_us`=108B, `serial_get_{rx,tx}_buffer_count`=28B each,
  `plan_get_block_buffer_count`=28B exactly.
- **No `size` tool ships with XC-DSC** (noted above already): `xc-dsc-nm`
  and `xc-dsc-objdump` exist, `xc-dsc-size` does not.
- **Multi-segment Harvard `.text` layout**: `objdump -h` shows five
  separate `.text`-named output sections plus a dozen more anonymous
  per-translation-unit scratch sections (`/tmp/ccXXXXXX.s.scnN`) at
  disjoint addresses, all CODE-flagged and contiguous with each other in
  the address space. The objdump-fallback code above treats every
  CODE-flagged section (by address range, not by literal `.text` name) as
  one flat function-address space — restricting to sections literally
  named `.text` silently drops most of the binary's real code (confirmed
  empirically: name-only filtering totalled ~8KB of ~42KB actual code).

## Known repo-wide dead code on this port

232B of core-mandated or TU-replacement-mandated code that every
`-ffunction-sections`/`--gc-sections` port strips but this one can't (no
`--gc-sections` on this toolchain, see Makefile): `delay_us` (108B,
`grbl/nuts_bolts.c`, zero callers anywhere in this repo — CORE file,
untouchable), `report_echo_line_received` (40B, `grbl/report.c`, guarded
off by default via `REPORT_ECHO_LINE_RECEIVED` but the function itself is
unconditional — CORE file, untouchable), `plan_get_block_buffer_count`
(28B, `grbl/planner.c`, zero callers — CORE file, untouchable),
`serial_get_rx_buffer_count`/`serial_get_tx_buffer_count` (28B each,
`serial.c` — this port's own TU-replacement file, but CONTRACTS.md §7
requires a TU-replacement to honor the FULL `serial.h` API, which
declares both; every other TU-replacement port (samd21, ch32v006, ch570)
implements them too, unused, for the same reason). None of the four are
removable without either editing an untouchable core file or breaking
the TU-replacement API-completeness contract — this cost is accepted and
documented, not fixed.

## Toolchain (verified recipe — PLAN.md Decision Log, EULA owner-approved)

1. XC-DSC v3.30 (83 MB, SHA-256
   `0df20c1a552bf0ce08aa139b9cb1efd71bf65b9d9f37e3982763f4f8738bfa11`):
   `https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc-dsc-v3.30-full-install-linux64-installer.run`
2. Unattended install (trailing `--netservername ""` REQUIRED though
   undocumented):
   ```
   ./xc-dsc-v3.30-full-install-linux64-installer.run --mode unattended \
     --unattendedmodeui none --prefix /opt/xc-dsc --LicenseType FreeMode \
     --ModifyAll 0 --netservername ""
   ```
3. Device Family Pack (Apache-2.0; an `.atpack` is a zip):
   `https://packs.download.microchip.com/Microchip.dsPIC33AK-MC_DFP.1.5.263.atpack`
   → unzip to `/opt/Microchip.dsPIC33AK-MC_DFP.1.5.263` (or set `DFP_PATH`).

Build: `make BUILD=DEBUG|RELEASE [TOOLCHAIN_PATH=…/bin] [DFP_PATH=…]`;
`make link` = linker-as-checklist diagnostic.

Compile pattern (all three parts load-bearing): `-mcpu=33AK128MC102
-mdfp=<dfp>/xc16` **and** `-Wl,--script=<dfp>/.../p33AK128MC102.gld`
(the toolchain's built-in default linker script is 30F-era).

## ISA-specific decisions (details in file headers)

- **DFP headers, not clean-room** (`gpio.h` header): the DFP is
  Apache-2.0 (unlike Atmel/ASF's proprietary headers that forced the
  samd21 clean-room route) and is also the compiler's own `-mdfp` source
  of device truth.
- **Toolchain crt0 + linker-synthesized IVT** (`platform.c` banner):
  dsPIC33A vectors are addresses filled in by the linker from canonical
  ISR names; a hand-written `vector_table[]` would fight the toolchain.
  Clock config runs pre-main via `__attribute__((user_init))`.
- **No memory-barrier instructions exist on this ISA** (`platform.h`):
  single core, no cache, in-order — `__DSB/__DMB` are compiler barriers.
- **AVR SBI atomicity does NOT transfer** (`gpio.h`): `LATx |= bit` is a
  3-instruction RMW at `-Og`/`-Os` (disasm-proven) and there are no
  LATxSET/CLR registers → GPIO_BSET/BCLR are critical-section wrapped.
- **Interrupt nesting is native** (`handlers.c`, `platform.c`): IPCx
  priorities let the pulse-reset IRQ genuinely preempt the stepper IRQ
  (CCT1IP=5 > T1IP=4) — better than the M0+ reference posture.
- **NVMEM window reserved by fixed address, not a custom linker script**
  (`nvmem.c`): `__attribute__((address(0x81F800)))` on a `static const`
  object claims the last 2KB erase page of program flash; link-tested
  clean against the *unmodified* vendor `.gld` — future code growth that
  collides fails the link loudly instead of corrupting silently.
- **PPS is two different verification classes** (`platform.h`): RPn INPUT
  muxing is fully verified (field = literal RPn number); RPn OUTPUT
  muxing uses UNVERIFIED placeholder function-select codes (no
  value-group exists anywhere in the vendored `.atdf` for any `RPORx`
  field — genuinely RM-only, unlike most of this port's other gaps).
- **FP=DOUBLE is this port's declared default** (`Makefile`): native DP
  FPU makes 64-bit float arithmetic native-cost, not soft-float-tax —
  the chip class CONTRACTS.md §17.3 named before this port existed.


---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `boards/generic/config.h`

config.h - Generic dsPIC33AK128MC102 board configuration

PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up: this is a
paper pinout for the bare 28-pin chip (SOIC/SSOP/VQFN). The
dsPIC33AK128MC102 bonds out exactly 19 GPIO (RA0-4, RB0-4, RC0-4,
RD0-3 - verified from the DFP's own dsPIC33AK128MC102.atdf pin list),
and GRBL needs 20 signals - the same squeeze the ATmega328p/Uno has,
resolved the same way: SPINDLE_ENABLE and SPINDLE_PWM SHARE one pin
under VARIABLE_SPINDLE (cpu_map.h:110-152 precedent, B3 on the Uno).
The MC106 Curiosity community board should get its own boards/ dir.
Pin-budget accounting (19/19 used):
  STEP x3 (RB0-2), DIR x3 (RC0-2), STEPPERS_DISABLE (RB3),
  LIMIT x3 (RD0-2), CONTROL x3 (RA0-2), PROBE (RA3),
  SPINDLE_ENABLE+PWM shared (RB4), SPINDLE_DIRECTION (RC3),
  COOLANT_FLOOD (RC4), UART RX (RA4) + TX (RD3).
ENABLE_M7 (mist coolant) therefore CANNOT fit - #error below, not a
silent drop.
LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1/#14.8): STEP and
DIRECTION groups sit on physical pins 0-2 of their ports, so logical
bits (core's uint8_t port image) == physical bits and the stock
common/gpio.h GPIO_MWO/GPIO_MRD formulas are exactly correct - no
L2P/P2L dispatch needed ON THIS BOARD. A board that scatters STEP/DIR
pins must add the samd21/ch32v006-style per-NAME dispatch in gpio.h.
Input groups (LIMIT/CONTROL/PROBE) land in bits 0-3 (#1.3 satisfied).
INTERRUPT MODEL (Step 6, next batch): dsPIC33AK Change Notification
(CN) is per-PORT with a per-port vector - _CNDInterrupt for LIMIT
(port D), _CNAInterrupt for CONTROL (port A). Unlike EXTI-class chips
there is NO line/port collision constraint (CONTRACTS.md #14.12 does
not apply) and no shared-vector dispatch is needed (#2.5): the two
groups own separate vectors by construction. CNEN0x arms per-pin,
CNCONx.ON gates the whole port - both runtime-writable (#2.1).
PPS NOTE (Steps 3-4): UART and the SCCP PWM output reach pins via
Peripheral Pin Select. RPn numbering (DFP header + datasheet pattern
RPn = 16*port_index + pin + 1, UNVERIFIED against silicon):
RA4 = RP5 (U1RX via RPINR), RD3 = RP52 (U1TX via RP52R),
RB4 = RP21 (SCCP/PWM out via RP21R). Analog default: ANSELx resets to
analog on analog-capable pins - platform.c's hal_gpio_* helpers clear
ANSEL on every direction config (the "input reads zero forever" trap).

## `gpio.h`

gpio.h - dsPIC33AK128MC102 GPIO register accessors and macro overrides

```
Injected by prelude.h BEFORE platform/common/gpio.h (that file only
supplies AVR-style defaults for accessors not already defined -
CONTRACTS.md #0). Composition contract (CONTRACTS.md #1): core calls
GPIO_*(NAME); NAME##_PORT/_BIT/_MASK come from boards/<board>/config.h.
HEADER PROVENANCE DECISION (vs the samd21 clean-room precedent): this
port uses the DFP's own p33AK128MC102.h SFR declarations via <xc.h>.
The samd21 port wrote clean-room register structs because Atmel/ASF
headers carry a Microchip-proprietary license; the dsPIC33AK-MC DFP is
explicitly Apache-2.0 (LICENSE.txt in the .atpack, "Copyright (c) 2026
Microchip... Licensed under the Apache License, Version 2.0") - GPL-
compatible, legally usable, and the DFP is ALSO the compiler's own
-mdfp source of device truth. Re-deriving 38k lines of SFR addresses by
hand would add transcription risk for zero legal gain.
Register model (dsPIC33A GPIO, from the DFP header):
  LATx   - output latch (GPIO_OREG)
  PORTx  - input pins   (GPIO_IREG)
  TRISx  - direction, 1 = INPUT (INVERTED vs AVR DDR where 1 = output -
           the common/gpio.h DREG-based defaults would set direction
           BACKWARDS; every direction macro is overridden with a
           function call instead, stm32f103/ch32v006 precedent)
  ANSELx - analog select, resets to ANALOG on analog-capable pins; a
           digital input with ANSEL set reads 0 forever ("compiles but
           dead" class) - the hal_gpio_* helpers clear it on every
           direction config
  CNPUx  - pull-up enable, bit-per-pin (a REAL pull-up register - the
           samd21 PORT-CTRL mis-mapping (#1.4) cannot recur here)
ATOMICITY (CONTRACTS.md #1.2) - measured, not assumed: xc-dsc-gcc 8.3.1
compiles `LATB |= (1u<<3)` to a THREE-instruction load/bset-register/
store sequence at -Og AND -Os (verified by disassembly this session) -
the AVR single-SBI atomicity does NOT transfer, and dsPIC33A has no
LATxSET/LATxCLR alias registers (grepped the DFP header). Consequences:
  - GPIO_BSET/GPIO_BCLR (STEPPERS_DISABLE/SPINDLE/COOLANT bits, written
    from BOTH mainline and st_go_idle() inside ISR_STEP) are wrapped in
    the save/restore critical section from platform.h.
  - GPIO_MWO (STEP/DIRECTION group writes) keeps the plain RMW formula:
    those groups are written ONLY from stepper ISRs and from init/reset
    paths with stepper interrupts off (core writer discipline, #1.2),
    and a mainline writer of the same LATx register cannot interrupt an
    ISR - while the wrapped GPIO_BSET above means the mainline writer
    itself cannot be torn by the ISR either. Both directions audited.
```

## `handlers.c`

handlers.c - dsPIC33AK128MC102 interrupt vectors + integration glue

Unlike the ARM/RISC-V siblings there is NO vector_table[] array here:
the XC-DSC linker synthesizes the IVT from canonical ISR symbol names
(see platform.c's startup-model banner). Each vector below is a real
dsPIC ISR (DFP vector table doc, xc16/docs/vector_docs/PIC33AK128MC102.html,
cross-checked against the header's commented-out "void _ISR _T1Interrupt(void);"
style declarations) wired to the peripheral allocation from timer.h/platform.c.
Flag-clear-first contract (#2.3/#5.1): every wrapper below clears its
own IFSx bit BEFORE calling the core body. On dsPIC the IFSx bit does
NOT auto-clear on vector entry (unlike AVR) - forgetting it re-enters
forever, the loud kind of bug. `_T1IF`/`_CCT1IF`/`_U1RXIF`/`_U1TXIF`/
`_CNAIF`/`_CNDIF` are the DFP's own IFSx bitfield-access macros
(p33AK128MC102.h) - direct bit clears, not read-modify-write of the
whole IFSx word, so no risk of clearing an unrelated pending flag.
ISR frame note: __attribute__((interrupt)) makes xc-dsc emit full
save/restore + RETFIE. Priorities (IPCx, set in platform.c) and
nesting: dsPIC33A nests by priority natively (INTCON1.NSTDIS=0 at
reset), so core's sei() inside ISR_STEP (stepper.c:355) genuinely lets
the pulse-reset IRQ preempt it - CCT1IP=5 > T1IP=4 (platform.c) - the
first port that can honor the AVR preemption semantic properly instead
of the M0+ "defer, don't nest" posture (#5.2).

## `nvmem.c`

nvmem.c - dsPIC33AK128MC102 EEPROM emulation in main program flash

```
PORTING-CHECKLIST Step 5, CONTRACTS.md #10. TU-replacement route: this
file provides the whole four-function NVMEM API; the Makefile excludes
core nvmem.c/eeprom.c.
FLASH CONTROLLER FACTS (dsPIC33AK128MC102.atdf "nvm" module, atdf-verified
- NOT RM-only, unlike most of this port's peripheral facts):
  FLASH_WORD_WRITE_SIZE_IN_INSTRUCTIONS = 4    (word-program op)
  FLASH_WRITE_ROW_SIZE_IN_INSTRUCTIONS  = 128  (row-program op)
  FLASH_ERASE_PAGE_SIZE_IN_INSTRUCTIONS = 1024 (page-erase op)
On this ISA one "instruction" = 2 bytes of address space (classic
dsPIC/PIC24 24-bit-instruction-over-a-16-bit-wide-address convention -
cross-checked against the .gld's byte-addressed program region size,
0x1FFFC bytes for a 128KB part). So: erase page = 2048 bytes, program
row = 256 bytes (8 rows/page). NVMCON.NVMOP values (atdf value-group
NVMCON_CON__NVMOP, also atdf-verified, not RM-only): 0x3 = page erase,
0x2 = row program (source = NVMSRCADR, a RAM pointer - hardware copies),
0x1 = word program (source = NVMDATA0-3 SFRs directly). Row program is
used here: it lets an entire modified page be staged in a RAM buffer
(this file) and copied into flash 256 bytes at a time by the
controller, matching the "page-batched RMW" shape of samd21/stm32_nvmem
exactly, just with the controller doing the byte-copy instead of a
manual staging-register loop.
NO NVMKEY / unlock-sequence register exists on this device (grepped the
full DFP header and the atdf "nvm" module - confirmed absent, unlike
classic PIC24/dsPIC33F/E's 0x55/0xAA NVMKEY dance). WREN
("Enable Flash program/erase operations", atdf-verified) is the gate
used here. NVMCON.LOCK's exact write protocol is UNVERIFIED (RM not
vendored) and deliberately NOT touched - left at its reset default.
READS are plain pointer dereferences: this device has no PSVPAG/PSV
windowing at all (grepped - the DFP has no PSVPAG anywhere, unlike
classic Harvard-with-PSV dsPIC33F/E) - `no_auto_psv` on the ISRs
(handlers.c) is a compatibility attribute for a feature this core does
not have, confirmed by a real link-tested reservation this session:
`__attribute__((address(HAL_NVMEM_FLASH_START)))` places a static
object at a fixed flash address and links CLEAN against the unmodified
vendor .gld (verified: object placed exactly at the requested address,
zero link errors/overlaps) - no port-authored linker script needed, and
any FUTURE code-size growth that collides with this window fails the
link LOUDLY (ld error), never silently corrupts, which is exactly the
contract's preferred failure mode.
Page-batched RMW (this file's nvmem_write_range()) reproduces the
samd21/stm32_nvmem.c shape: each affected 2048-byte erase page is
erased+reprogrammed AT MOST ONCE per settings write, using a wear guard
(#10.3) so an unchanged page is never touched at all.
BUG #13 fence discipline (#10.5/#12.4): __DSB() (a compiler barrier on
this barrier-free ISA, platform.h) between staging NVMADR/NVMSRCADR and
issuing WR=1; WR is polled to completion (bounded, hardware-timed) after
every erase/row-program command; WRERR checked after (best-effort - no
RM-specified recovery action exists to take beyond what the wear guard
already prevents).
Context contract (#10.1): mainline only, interrupts enabled, blocking
allowed - writes happen during `$` commands (IDLE/ALARM); no deferred/
background writes.
```

## `platform.c`

platform.c - dsPIC33AK128MC102 platform implementation (M1-M3 batch)

```
Contents: device config words, system clock to 200 MHz, GPIO
direction/pull-up helpers. Timers/serial/nvmem/CN interrupts are
Steps 3-6 (next batch) - their PORT_TODO_* symbols live in timer.h /
serial.c / nvmem.c / handlers.c.
============================================================================
STARTUP MODEL (deliberate departure from every ARM/RISC-V sibling port)
============================================================================
There is NO startup.c and NO custom linker script in this port. The
XC-DSC toolchain's own crt0 + the DFP's p33AK128MC102.gld are used
as-is, because on dsPIC33A they already implement everything the ARM
ports hand-wrote, and they are device-blessed:
  - Reset vector: the .gld places `LONG(ABSOLUTE(__reset))` at 0x800000
    (fixed reset location - NOT an ARM-style SP+PC fetch, NOT a RISC-V
    naked _start: the CPU jumps to the address stored there).
  - crt0 (__reset, DISASSEMBLY-VERIFIED this session): sets W15 (stack
    pointer) and SPLIM, programs IVTBASE = vector table base, runs
    __data_init over the .dinit template (the dsPIC equivalent of the
    .data-copy/.bss-zero loops every ARM startup.c writes by hand),
    calls any __attribute__((user_init)) functions, then _main.
  - IVT model: the TOOLCHAIN LINKER synthesizes the interrupt vector
    table (section __ivt_0 at 0x800004, 286 4-byte ADDRESS entries -
    dsPIC33A vectors are addresses, not instructions) directly from
    ISR symbol names (__attribute__((interrupt)) _T1Interrupt etc.);
    unused slots point at a weak __DefaultInterrupt. IVTBASE is a
    RUNTIME SFR (0x88) - the table is relocatable, and AIVT-style
    alternate tables from classic dsPIC are replaced by this
    IVTBASE indirection on dsPIC33A (no AIVT config-word dance).
    Consequence: a port-authored vector_table[] array would FIGHT the
    toolchain's own IVT emission - the correct move on this ISA is to
    define ISRs by their canonical names (handlers.c) and let the
    linker place them.
  - Clock config runs pre-main via __attribute__((user_init)) below -
    crt0 calls it after RAM init, before main (verified in the
    __reset disassembly: rcall __user_init between __data_init and
    the _main call).
============================================================================
CLOCK (PORTING-CHECKLIST Step 1)
============================================================================
Reset state: CLKGEN1 (CPU) runs from FRC 8 MHz. Target: 200 MHz via
PLL1. Sequence and divider values below are taken VERBATIM from
Microchip's own dsPIC33A clock documentation (developerhelp.microchip.com,
"dsPIC33A Clock System"):
    Fpll = Fin * PLLFBDIV / (PLLPRE * POSTDIV1 * POSTDIV2)
         = 8 MHz * 200 / (1 * 4 * 2) = 200 MHz   (VCO = 1.6 GHz)
Register/bitfield names cross-checked against the DFP header (OSCCTRL
PLL1EN/PLL1RDY, PLL1CON NOSC/OSWEN/PLLSWEN/FOUTSWEN/ON/CLKRDY, PLL1DIV
PLLPRE/PLLFBDIV/POSTDIV1/POSTDIV2, CLK1CON NOSC/OSWEN/CLKRDY).
UNVERIFIED ON SILICON (no dsPIC33A emulator exists; hardware validation
item): the whole sequence, plus two RM questions Step 3 must close
before trusting timing math: (a) which clock generator feeds Timer1/
SCCP/UART and at what ratio to the CPU clock; (b) whether any flash
access-time configuration is required at 200 MHz (no wait-state
register exists in the DFP SFR set - dsPIC33A flash appears to be
handled by hardware prefetch, but the RM word is not vendored here).
```

## `platform.h`

platform.h - dsPIC33AK128MC102 chip-specific HAL

THE THIRD ISA FAMILY: dsPIC33A 32-bit DSC core (Microchip) - neither ARM
nor RISC-V. 200 MHz, dual-precision hardware FPU, hardware multiply/
divide. Phase 6 rolling port #2: M1-M3 (identification, clock, GPIO,
interrupt-global-control, critical sections) plus Steps 3-6 (timers,
serial, NVMEM, GPIO-interrupt arming, handlers) are now ALL real -
zero PORT_TODO_* remain at link (see Makefile `make link` / CONTRACTS.md
#16 new items for the Step 3-6 register facts and what is still
UNVERIFIED pending real hardware - no dsPIC33A emulator exists).
Chip facts in this file come from the Apache-2.0 DFP
(Microchip.dsPIC33AK-MC_DFP 1.5.263: p33AK128MC102.h SFR set,
p33AK128MC102.gld memory map, dsPIC33AK128MC102.atdf value-groups) and
from toolchain-disassembly/link evidence gathered this session;
anything not verifiable from those is marked UNVERIFIED loudly. Two
specific gaps the DFP does NOT resolve (grepped exhaustively, see
CONTRACTS.md #16 for the full writeup): the SCCP MOD/CLKSEL/TMRPS field
encodings (no value-group in the .atdf) and the RPn PPS OUTPUT
function-select codes (ditto) - both are RM-only tables. This file picks
defensible, clearly-flagged placeholder values for those so the port
builds and links against real hardware behavior *shapes*; hardware
bring-up must confirm/correct them from the datasheet before trusting
UART TX or spindle PWM output electrically.

## `serial.c`

serial.c - dsPIC33AK128MC102 serial port driver (TU-replacement route)

PORTING-CHECKLIST Step 4, CONTRACTS.md #7. This is the NEWER dsPIC33A
UART peripheral - register names are U1CON/U1STAT/U1BRG/U1RXB/U1TXB
(p33AK128MC102.h), NOT the classic UxMODE/UxSTA/UxTXREG/UxRXREG shape
used on 16-bit dsPIC33F/E - a fresh register set was mined this session,
not reused from any donor port (there is no donor: this is the third
ISA family and the first UART for it).
Ring-buffer bookkeeping (head/tail math, the BUG #12 ordering
discipline) is chip-agnostic and unchanged from the M1-M3 skeleton
(itself lifted from the proven samd21/serial.c pattern); only the
UART1 register touches below are new.
REALTIME INTERCEPTION (BUG #19): the dispatch switch below is
UNCHANGED from the M1-M3 skeleton, which already mirrors core
grbl/serial.c's HAL_SERIAL_RX_ISR() (serial.c:137-188) verbatim,
case-for-case - re-verified line-by-line this session. Do not "clean
this up" - the exact case list, ordering and #ifdef guards (DEBUG,
ENABLE_M7) are the contract.
BAUD (BUG #4 class): U1BRG is a 20-bit register (not the classic 16-bit
UxBRG) with a BRGS "high speed" mode bit (/4 divisor vs /16 - assumed
meaning, U_CON__BRGS atdf value-group only names enabled/disabled, not
the divisor arithmetic itself - RM-only). BRGS=1 (/4) is used for finer
granularity at high Fp. Formula: BRG = round(Fp/(4*baud)) - 1. Fp
(UART1's peripheral clock) is ASSUMED == F_CPU (platform.h, UNVERIFIED -
CONTRACTS.md #16.10); at F_CPU=200MHz/115200 baud this gives BRG=433,
actual baud 115207.4 (+0.006%) - the arithmetic is sound, the Fp
assumption is the open hardware-bring-up risk.
PPS: U1RX input mux (RPINR9.U1RXR) IS fully verified - the field is
literally the source RPn's own pin number (standard PPS input-mux
convention). U1TX output mux (RPOR12.RP52R) uses an UNVERIFIED
function-select code (platform.h PPS_RPOR_FN_U1TX_UNVERIFIED) - no
value-group for any RPORx field exists in the vendored .atdf.

## `timer.h`

timer.h - dsPIC33AK128MC102 stepper/pulse/PWM timer primitives

```
PORTING-CHECKLIST Step 3 - real implementations, CONTRACTS.md #3/#4/#5/#6.
IRQ-capability audited before allocation (the #14.11 lesson - "general
purpose timer" does not imply an interrupt line): all three candidates
below have a REAL vector confirmed against the DFP's own vector table
doc (xc16/docs/vector_docs/PIC33AK128MC102.html):
  - Stepper timer:     Timer1  (T1CON/_T1Interrupt,   IRQ 48)
  - Pulse-reset timer: SCCP1   (CCP1CON1/_CCT1Interrupt, IRQ 49)
  - Spindle PWM:       SCCP2   (CCP2CON1, PWM output only - no ISR needed)
Register field FACTS below (bit widths, which SFR pairs with which flag/
enable/priority bit) come from the DFP header (p33AK128MC102.h) and are
solid. Two specific field ENCODINGS are NOT resolvable from the vendored
DFP/.atdf at all (grepped exhaustively - no value-group exists for
either, unlike e.g. NVMCON_CON__NVMOP which does) and are RM-only
tables: the SCCP CCPxCON1.MOD/CLKSEL/TMRPS mode-select encoding, and the
RPn PPS OUTPUT function-select codes (platform.h). Both are given
defensible, clearly-flagged placeholder values so the port builds and
the STRUCTURE is real; hardware bring-up must confirm the exact values
from Microchip's dsPIC33A family reference manual (not vendored here -
no dsPIC33A emulator exists either, so this whole port's runtime
behavior is provisionally UNVERIFIED pending real silicon, same status
the M1-M3 clock sequence already carries).
```
