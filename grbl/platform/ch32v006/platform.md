# CH32V006 port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `boards/generic/config.h`

config.h - Generic CH32V006 board configuration

PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up: peripheral
FUNCTION mappings below (USART1 default pins, TIM1_CH1 remap options,
EXTI line/port sharing rules) are verified against CH32V00X RM V1.5;
the choice of which package pin carries which GRBL signal is still a
paper exercise (no hardware this session). QFN32/QSOP24-oriented: uses
PB3-5, which the TSSOP20 package may not bond out - copy this directory
to boards/yourboard and re-pin for real silicon.
LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1/#14.8): X/Y/Z
STEP and DIRECTION _BIT values are LOGICAL bits 0,1,2 (core's native
uint8_t port image); the real silicon pin lives in *_PIN. gpio.h's
GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT dispatch through the *_MASK_PHYS /
*_L2P / *_P2L definitions below (samd21/generic/config.h pattern -
contiguous pins, so L2P/P2L collapse to a pure shift).
EXTI CONSTRAINT (found authoring Step 6, folded into CONTRACTS.md #14):
on F1/CH32-style EXTI, line N serves ALL ports' pin N - ONE port per
line via AFIO_EXTICR. LIMIT (PD0-2, lines 0-2) and CONTROL therefore
MUST NOT use pin numbers 0-2 on another port; CONTROL sits on PB3-5
(lines 3-5). All 6 inputs share the single EXTI7_0 vector (handlers.c
dispatches both groups per CONTRACTS.md #2.5).

## `ch32v006.h`

ch32v006.h - CH32V006 clean-room register definitions

Written from scratch against the publicly available CH32V00X Reference
Manual V1.5 (wch-ic.com, covers CH32V002/004/005/006/007) and the
CH32V006 datasheet - register FACTS transcribed from documentation,
NOT copied from any WCH-licensed header (EVT, ch32v00x.h, etc).
Modeled in shape on ../samd21/samd21.h: a minimal struct-per-peripheral
header, not a full vendor CMSIS pack.
VERIFICATION STATUS (Phase 4 Step 3 re-verification pass - supersedes
the M1-M3 "best-effort placeholder" state):
- Peripheral base addresses, PFIC/STK register offsets, the interrupt
  vector table, RCC/FLASH/GPIO/AFIO/EXTI/USART/TIM bit positions below
  were all read out of CH32V00X RM V1.5 directly (section numbers cited
  inline). Items that could NOT be verified are marked UNVERIFIED
  individually - the blanket "everything here is a guess" caveat from
  M1-M3 no longer applies.
- Cross-check: Zephyr's community ch32v006.dtsi (Apache-2.0) agrees on
  every base address and IRQ number used by this port.

## `gpio.h`

gpio.h - CH32V006 GPIO register accessors and macro overrides

```
Injected by prelude.h BEFORE platform/common/gpio.h (that file only
supplies AVR-style defaults for accessors not already defined -
CONTRACTS.md #0). Composition contract (CONTRACTS.md #1): core calls
GPIO_*(NAME); NAME##_PORT/_BIT/_MASK come from boards/<board>/config.h.
Two chip-shape facts drive the overrides here:
1. CFGLR packs 4 bits (CNF+MODE) per pin (ch32v006.h) - direction and
   pull-up CANNOT be single-bit GPIO_DREG/GPIO_PREG ops (the common/
   gpio.h default formula would corrupt neighboring pins' nibbles).
   Same problem stm32f103 solved for CRL/CRH: direction/pull-up are
   real function calls (platform.c). V00X ports are 8 pins wide - no
   CFGHR exists.
2. LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1 / #14.8):
   core's step pipeline is a uint8_t port image - st.step_outbits /
   st.dir_outbits / the invert masks all live in LOGICAL bits 0..2.
   This board's DIRECTION pins are physically PC3-5, so GPIO_MWO /
   GPIO_MRD / GPIO_MDIR_OUT dispatch per NAME (token-pasted, zero
   runtime cost - samd21/gpio.h is the reference implementation) to
   board-supplied STEP_/DIRECTION_ L2P/P2L translations. This closes
   CONTRACTS.md #14 item 8 (the "MUST land before ISR_STEP goes live"
   item) for this port.
```

## `handlers.c`

handlers.c - CH32V006 interrupt vector bodies

PORTING-CHECKLIST Step 6. Real PFIC vector targets (startup.c's
vector table points here): each wrapper clears its peripheral flag
FIRST, then calls the core-supplied ISR body - clearing after would
lose edges/updates arriving during the body, and for ISR_STEP_RESET
specifically would ghost the final compare event after the body stops
the counter (CONTRACTS.md #2.3 / #5.1).
__attribute__((interrupt)): QingKe V2C runs with INTSYSCR.HWSTKEN=0
(no vendor hardware prologue/epilogue - the reset default, see
startup.c's documented choice), so GCC's standard RISC-V interrupt
attribute - full caller-saved spill + `mret` - is exactly the right
frame. Verified by disassembly in the M1-M3 session.
Core-ISR dedup pattern: the bodies (__isr_step_impl, LIMIT_INT_
IRQHandler, ...) are defined by CORE macros (stepper.c ISR_STEP(),
limits.c/system.c HAL_GPIO_IRQ_HANDLER(...)) - this file only owns the
vector frame + flag hygiene, the same split every ARM port uses.

## `nvmem.c`

nvmem.c - CH32V006 EEPROM emulation in main flash (TU-replacement route)

PORTING-CHECKLIST Step 5, CONTRACTS.md #10. samd21/nvmem.c is the
structural reference; the flash controller here is WCH's fast-page
model (RM 18.4, TRM-verified this session):
- 256-byte pages, program AND erase are whole-page only - there is no
  F1-style halfword PG mode on V00X main flash.
- Two lock layers: LOCK (FLASH_KEYR) gates the FPEC, FLOCK
  (FLASH_MODEKEYR) gates fast page mode. Keys 0x45670123/0xCDEF89AB.
- Program sequence (RM 18.4.5): FTPG -> BUFRST (+BSY wait) -> 64 x
  { 32-bit store to the page address, BUFLOAD, BSY wait } -> ADDR ->
  STRT -> BSY wait. Erase (RM 18.4.6): FTER -> ADDR -> STRT -> BSY wait.
- Programming addresses are PHYSICAL (0x08xxxxxx); reads below use the
  same alias for symmetry.
Region: last 1 KB of the 62 KB flash (pages 244-247, 0x0800F400+),
reserved out of script.ld's FLASH region so code can never collide.
Wear model: writes are page-granular read-modify-write, batched per
page by nvmem_write_range() - a bulk settings write touches each
affected 256-byte page ONCE (erase+program), not once per byte. This is
still a synchronous, blocking path (#10.1: no deferred/background
writes - settings_read may follow immediately).
BUG #13 fence discipline (#10.5 / #12.4): __DSB() (fence rw,rw) between
buffer-fill stores and every commit-command MMIO write; BSY polled to
completion after every command. RM note: HSI must be running during
program/erase - it is never turned off by this port.
Context contract (#10.1): mainline only, interrupts enabled, blocking
allowed. While an erase/program is in progress the flash stalls - ISRs
(whose code lives in flash) stall with it; tolerated because settings
writes only happen during `$` commands in IDLE/ALARM.

## `platform.c`

platform.c - CH32V006 chip bring-up + peripheral init functions

Steps 1-2 (clock, GPIO config) plus the Step 3/6 function-shaped
primitives (timer inits, EXTI arm/disarm, delays). Chip facts verified
against CH32V00X RM V1.5 (see ch32v006.h header). stm32f103/platform.c
is the structural precedent for the CRL/CRH-shaped (here: CFGLR)
function-call GPIO config.

## `platform.h`

platform.h - CH32V006 chip-specific HAL

RISC-V RV32EC (QingKe V2C core), 48 MHz, PFIC interrupt controller
(WCH vendor fast-interrupt scheme - NOT CLINT/PLIC). Phase 4 Steps 3-6
batch: every former PORT_TODO_* in this file is now a real, TRM-backed
implementation (chip facts verified against CH32V00X RM V1.5 - see
ch32v006.h's verification header).

## `serial.c`

serial.c - CH32V006 serial port driver (TU-replacement route)

PORTING-CHECKLIST Step 4, CONTRACTS.md #7. USART1 at BAUD_RATE, 8N1,
interrupt-driven RX/TX ring buffers. Register names on this chip are
STATR/DATAR/CTLR1 (ch32v006.h) - F1 bit positions, WCH names, all
TRM-verified (RM 14). Default pin map: TX=PD5, RX=PD6 (RM table 7-10,
USART1_RM=0000 - no remap write needed).
BUG #19 (contract #7): realtime command bytes are intercepted HERE, in
the RX interrupt path, mirroring core grbl/serial.c HAL_SERIAL_RX_ISR()
verbatim - without this, '?'/'!'/'~'/ctrl-X and every extended-ASCII
override byte would fall into the line buffer and be parsed (and
rejected) as g-code: no status reports, no feed hold, no reset.
BUG #12 (contract #7): producer publishes data store -> __DMB() -> head
store on the RX path; the TX path brackets the store+publish pair by
masking the consuming interrupt (TXEIE) - both patterns straight from
samd21/serial.c, the reference implementation.

## `startup.c`

startup.c - CH32V006 reset entry + PFIC vector table

```
PORTING-CHECKLIST Step 0/1 (+ the Step 3-6 vector wiring). RISC-V has
no ARM-style hardware SP/PC autoload from a data table: `_start` (naked,
at the base of flash via .init) sets SP itself, then Reset_Handler does
.data/.bss init, points mtvec at the vector table, and calls main().
INTERRUPT MODE - the M1-M3 "direct vs vendor vectored" open question
(CONTRACTS.md #14.2) is now CLOSED with TRM facts (RM 6.5.3.2 MTVEC):
  MODE0 (bit 0) = 1: entry address = BASEADDR + interrupt_number * 4
  MODE1 (bit 1) = 1: table entries are ABSOLUTE ADDRESSES (function
                     pointers), not jump instructions
This port uses MODE0=1, MODE1=1: a plain `const` array of C function
pointers below IS the vector table - no asm jump stubs needed, and the
hot vectors (TIM2/STK/USART1/EXTI) get hardware dispatch instead of an
mcause switch. BASEADDR is bits [31:2], so 4-byte alignment suffices.
HPE / HARDWARE STACKING - DOCUMENTED CHOICE (task brief asks for it):
QingKe V2C's INTSYSCR (CSR 0x804) has HWSTKEN (bit 0, vendor hardware
prologue: auto register push) and INESTEN (bit 1, 2-level nesting).
BOTH RESET TO 0 AND ARE LEFT AT 0 by this port:
  - HWSTKEN=0 means handlers need a full software frame - which is
    precisely what GCC's __attribute__((interrupt)) emits (spill +
    `mret`; disassembly-verified). Enabling HWSTKEN under GCC-attributed
    handlers would double-save (harmless but slow) and its interaction
    with picolibc/GCC frames is silicon-unverified - correctness first.
  - INESTEN=0 means no preemption: core's sei() inside ISR_STEP
    (stepper.c:355) cannot nest the pulse-reset interrupt into the
    running handler; delivery defers to handler exit. This is the SAME
    accepted posture as the SAMD21 M0+ reference (CONTRACTS.md #5.2:
    "acceptable only because ISR_STEP's tail is short"). Flip-side
    benefit: no nested-trap mepc/mstatus clobber hazard on a core where
    GCC's interrupt attribute does not save those CSRs.
```

## `timer.h`

timer.h - CH32V006 stepper/pulse/PWM timer primitives

```
PORTING-CHECKLIST Step 3, real implementations (Phase 4 Steps 3-6
batch). Timer allotment on this chip:
  stepper timer  = TIM2 (general purpose, IRQ 38)     - CONTRACTS.md #3
  pulse reset    = STK  (QingKe SysTick, IRQ 12)      - CONTRACTS.md #4
  spindle PWM    = TIM1 CH1 (advanced, BDTR.MOE gate) - CONTRACTS.md #6
WHY SysTick and not TIM3: CH32V006's TIM3 is a "streamlined" compare-
only timer with NO interrupt output (RM 13 - it exists to pace TIM1/ADC
and feed DMA). The STK is the only remaining interrupt-capable counter,
and it happens to have a hardware HCLK/8 tick option (STCLK=0) - which
is EXACTLY the AVR Timer0 F_CPU/8 prescale the CONTRACTS.md #4 pulse
math assumes: no rescaling of the core's `>>3` arithmetic needed.
```
