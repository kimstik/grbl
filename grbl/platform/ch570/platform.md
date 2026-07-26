# CH570 port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `boards/generic/config.h`

config.h - Generic CH570 board configuration

PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up, same posture
as every other "generic" board in this tree (ch32v006/stm32f103/...):
peripheral FUNCTION facts below (PWM1-5 fixed pins, UART default remap,
GPIO register shape) are datasheet-confirmed; the choice of which
signal gets which pin is a paper exercise.
REAL PIN BUDGET CAVEAT (this chip specifically, PLAN.md Phase 6 rolling
#4 Part B gap-log item): the CH572/CH570 Datasheet V1.1 states plainly
"The chip provides a group of GPIO ports PA with 12 general input and
output pins" - i.e. ONLY PA0-PA11 physically exist on real silicon. The
vendor SDK's own GPIO_Pin_0..GPIO_Pin_23 defines are shared boilerplate
across the whole CH5xx family tree (bigger siblings bond out more pins)
and do NOT mean this chip has 24 pins. This board's map below
deliberately uses PA0-PA21 anyway, for the same reason ch32v006's
generic board and dsPIC33AK128MC102's generic board both shipped
placeholder maps exceeding a real per-package pin budget: it is a
compile/link target, not a hardware-fit claim, and is explicitly NOT
marked ready for hardware validation. A real board MUST consolidate
signals before bring-up (candidates: share STEPPERS_DISABLE across all
axes as already done here rather than per-axis; drop CONTROL_SAFETY_DOOR
onto CONTROL_FEED_HOLD as already done here; drop COOLANT_MIST under
ENABLE_M7; consider a single shared LIMIT line). Two real, fixed
hardware facts ARE respected regardless: PWM1's dedicated pin is PA7 (no
remap exists for PWM1-5 on this chip), and UART1's default remap is
TX=PA3/RX=PA2 - both used below.
LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1): X/Y/Z STEP and
DIRECTION _BIT values are LOGICAL bits 0,1,2 (core's native uint8_t port
image); the real silicon pin lives in *_PIN. Deliberately placed PAST
bit 7 (STEP=PA8-10, DIRECTION=PA11-13) per the task brief's explicit
request to exercise the L2P/P2L machinery on this port, not just carry
it unused - gpio.h's GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT dispatch through
the MASK_PHYS / L2P / P2L definitions below (samd21/ch32v006 pattern).

## `ch570.h`

ch570.h - CH570 register definitions

```
SOURCING (PLAN.md Phase 6 rolling #4 Part B - "state which and why"):
register FACTS below (addresses, bit positions, reset values) are
transcribed from TWO independent, cross-checked sources, both
Apache-2.0 and both explicitly permitting vendoring:
  1. The CH572/CH570 Datasheet V1.1 (Nanjing Qinheng / WCH, English,
     vendored as `vendor/` siblings' attribution note references it;
     the datasheet text itself is not reproduced here, only facts cited
     inline by section/line where useful).
  2. openwch/ch570's own SDK headers (`CH572SFR.h`, `RVMSIS/core_riscv.h`),
     Apache-2.0, LICENSE copied to vendor/LICENSE-openwch-ch570-Apache-2.0.txt.
The EXPRESSION here (struct shapes, macro names, comments) is written
fresh in this project's own idiom - matching ch32v006.h's and
samd21.h's minimal struct-per-peripheral style, not a vendor CMSIS-style
full pack - the same choice CONTRACTS.md #14's ch32v006.h header made
against the CH32V00X RM. This is NOT a clean-room-from-datasheet-alone
header (unlike ch32v006.h): the SDK was consulted directly because it
is Apache-2.0 and vendorable (PLAN.md's own recon conclusion), so cross-
checking register offsets against real, compiled vendor code (rather
than prose alone) was possible and done.
CHIP: CH570 (QingKe V3C core, RV32IMC + Zicsr on this toolchain), same
SFR map as CH572 (CH572SFR.h's own file banner: "head file(ch572/ch570)";
R8_CHIP_ID distinguishes ID_CH570=0x70 from ID_CH572=0x72 at runtime,
not compile time - this port never reads it, it targets CH570 by Makefile
selection only, same as every other port in this tree). Real, datasheet-
confirmed facts used by this port:
  - Flash: 240KB user code (0x00000-0x3BFFF), BOOT ROM area at 0x3C000+
    (datasheet: `FLASH_ROM_MAX_SIZE 0x03C000`, `BOOT_LOAD_ADDR 0x3C000`).
  - RAM: 12KB (`SZ_RAM 0x00003000`).
  - GPIO: ONE port, "PA" - datasheet ch572ds.txt: "The chip provides a
    group of GPIO ports PA with 12 general input and output pins, all
    of which have interrupt...". The SDK's own GPIO_Pin_0..23 defines
    (up to 24 bits) are shared boilerplate across the whole CH5xx family
    tree (bigger siblings bond out more pins) - THIS chip only actually
    has PA0-PA11 wired. boards/generic/config.h's own header flags this
    explicitly (12-pin real budget vs the fuller placeholder map it
    uses for consistency with every other port's "generic" board).
  - PWM1-5 are FIXED-function pins, not remappable (unlike UART/TMR):
    PWM1=PA7, PWM2=PA2, PWM3=PA3, PWM4=PA4, PWM5=PA8 (datasheet pin
    table). UART TX/RX default to PA3/PA2 (remappable via
    R16_PIN_ALTERNATE_H, default value 0 used by this port).
```

## `gpio.h`

gpio.h - CH570 GPIO register accessors and macro overrides

```
Injected by prelude.h BEFORE platform/common/gpio.h (CONTRACTS.md #0).
ONE physical GPIO port on this chip ("PA") - every macro below ignores
the `name##_PORT` token common/gpio.h's DEFAULT formulas would look up
(this chip has no such thing; boards/generic/config.h does not define
any `*_PORT` macros at all, deliberately, so a stray fallback to the
generic formula fails LOUDLY at compile time instead of silently
addressing a nonexistent port struct).
Two chip-shape facts drive the overrides here:
1. DISCRETE, AVR-style registers (DIR/PIN/OUT/CLR/PU/PD_DRV/SET), each a
   plain 32-bit register with ONE independent bit per pin - unlike
   ch32v006/stm32f103's 4-bit-packed CFGLR nibble, there is NO packing
   hazard here: every bit op below is genuinely safe as a direct
   read-modify-write (no neighboring-pin corruption possible), so
   direction/pull-up ARE simple bit ops here, not function calls like
   ch32v006's gpio.h needed.
2. LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1) - core's step
   pipeline is a uint8_t port image. This board's STEP pins are
   physically PA8-PA10 and DIRECTION PA11-PA13 (deliberately chosen
   past bit 7, per the task brief's "L2P/P2L if physical pins exceed
   bit 7" - this port DOES need the machinery, not just carry it for
   show). GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT dispatch per NAME (token-
   pasted, zero runtime cost for the dispatch itself - samd21/gpio.h is
   the reference implementation) to board-supplied L2P/P2L shifts.
ATOMICITY NOTE (CONTRACTS.md #1.2): R32_PA_SET/R32_PA_CLR are
independent write-only "set this bit high" / "clear this bit low"
registers (WZ - write 1, auto-reads-back 0), NOT one combined atomic
set+clear register like ch32v006's BSHR. A multi-bit group write
(GPIO_MWO) therefore takes TWO register writes (SET then CLR) instead
of STM32's one - individual output bits still change atomically
(no read-modify-write race with an ISR touching other pins), but the
group as a WHOLE is not guaranteed to transition in a single bus cycle
the way a combined register would. Folded into CONTRACTS.md's gap log
this batch: acceptable for STEP/DIRECTION (a few-nanosecond skew across
3 axis bits is not a new hazard class - even AVR's single POUT write
only LOOKS atomic across bits because it is one instruction, not
because the hardware promises simultaneity at the pin-driver level).
```

## `handlers.c`

handlers.c - CH570 interrupt vector bodies

Real PFIC vector targets (startup.c's vector table points here): each
wrapper clears its peripheral flag FIRST, then calls the core-supplied
ISR body (CONTRACTS.md #2.3/#5.1) - same discipline every port in this
tree uses.
__attribute__((interrupt)): plain GCC attribute, machine mode assumed.
QingKe V3C runs with INTSYSCR=0 (startup.c writes it explicitly - see
common/wch/wch_vectors.h's header for why THIS port, unlike ch32v006,
does not just trust the documented reset value), so GCC's software
save/restore frame is the whole story here too (CONTRACTS.md §20).

## `nvmem.c`

nvmem.c - CH570 EEPROM emulation in main flash (TU-replacement route)

```
CONTRACTS.md #10. Materially different flash IP from ch32v006
(PLAN.md recon): 4096-byte erase blocks (not 256B pages), and
write/erase go through a real, linked vendor function (`FLASH_EEPROM_CMD`,
vendor/ISP572.o - NOT a boot-ROM call, see vendor/ISP572.h's header for
the full investigation and why this port vendors the algorithm instead
of reimplementing it), gated by:
  1. the "safe access" SIG1/SIG2 unlock (ch570.h's
     CH570_SAFE_ACCESS_BEGIN/END, ~112-cycle window per write), AND
  2. R8_GLOB_ROM_CFG's RB_ROM_CODE_WE region-write-enable field.
CORRECTION (adversarial review this batch): an earlier draft of this
file set RB_ROM_CODE_WE to "enable 129-240K" (0x40) here believing that
was the operative grant for the whole erase/write operation - narrower
than "enable 0-240K" (0xC0), on a least-privilege theory. Disassembly +
relocation analysis of vendor/ISP572.o
(`riscv64-unknown-elf-readelf -r ISP572.o`) shows this does NOT hold:
both `FLASH_CMD_ROM_WRITE` and `FLASH_CMD_ROM_ERASE` call `FLASH_START`
as their FIRST action, and `FLASH_START` itself unconditionally ORs
R8_GLOB_ROM_CFG with 0xE0 (0xC0 RB_ROM_CODE_WE + 0x20 RB_ROM_CTRL_EN) -
i.e. the vendor code re-widens access to the FULL 0-240K region every
time, regardless of what this file sets beforehand. The narrower grant
below therefore protects only the (very short) margins immediately
before/after the `FLASH_EEPROM_CMD` call, NOT the actual erase/write
window itself - stated honestly rather than left as a false
least-privilege claim. It is kept anyway as cheap, harmless
defense-in-depth for those margins (a stray write elsewhere in this
file reaching a RWA register would still be narrower-scoped), not
because it changes what happens during the real operation.
Region: last 4KB of the 240KB user flash (HAL_NVMEM_FLASH_START,
platform.h), reserved out of script.ld's FLASH region so code can never
collide with it.
Wear model: same page(here: block)-granular read-modify-write batching
as every other port's nvmem.c - a bulk settings write touches the
4KB block ONCE (erase+program), not once per byte.
BUG #13 fence discipline (#10.5/#12.4): __DSB() between the RAM staging
buffer being filled and the FLASH_EEPROM_CMD call that reads it (the
vendor routine reads Buffer from RAM - CONTRACTS' "commit after store,
not before" lesson applies to the argument buffer here, not to MMIO
writes directly, since the whole erase/program sequence is opaque
vendor code).
Context contract (#10.1): mainline only, interrupts enabled outside the
safe-access brackets, blocking allowed - settings writes only happen
during `$` commands in IDLE/ALARM, same as every other port. NOTE:
`FLASH_EEPROM_CMD` itself additionally masks ALL PFIC interrupts for the
duration of the actual erase/write (confirmed by disassembly - it saves
and clears PFIC->IENR, restoring it on return), which is necessary
regardless of this file's own interrupt state, since the CPU cannot
fetch code from flash while it is being programmed/erased.
```

## `platform.h`

platform.h - CH570 chip-specific HAL

RISC-V RV32IMC (QingKe V3C core) + Zicsr, PFIC interrupt controller
(same WCH vendor fast-interrupt scheme as ch32v006 - CONTRACTS.md §20).
PLAN.md Phase 6 rolling #4 Part B: this port consumes common/wch/ (PFIC,
critical sections, mtvec setup) and writes everything chip-specific
(GPIO/UART/timers/flash) fresh - the recon found only ~15-20% of
ch32v006 was reusable here, not the ~60% stm32 family-mix ports get.

## `serial.c`

serial.c - CH570 serial port driver (TU-replacement route)

CONTRACTS.md #7. UART1 at BAUD_RATE, 8N1, interrupt-driven RX/TX ring
buffers. Register shape here is GENUINELY 16550 (MCR/IER/FCR/LCR/IIR/
LSR/RBR/THR/DLL/DLM/DIV, ch570.h) - NOT ch32v006's F1-style STATR/DATAR/
BRR, so that port's serial.c is not reusable (PLAN.md recon).
BUG #19 (contract #7): realtime command bytes intercepted HERE, in the
RX interrupt path, mirroring core grbl/serial.c HAL_SERIAL_RX_ISR()
verbatim.
BUG #12 (contract #7): producer publishes data store -> __DMB() -> head
store on the RX path; TX path brackets the store+publish pair by masking
the consuming interrupt (THR-empty IE) - straight from samd21/serial.c,
the reference implementation every port in this tree follows.

## `startup.c`

startup.c - CH570 reset entry + PFIC vector table

```
Same shape as ch32v006/startup.c (RISC-V has no ARM-style hardware SP/PC
autoload): `_start` (naked, .init) sets SP, Reset_Handler does
.data/.bss init, points mtvec at the vector table via
common/wch/wch_vectors.h::wch_mtvec_set_vectored(), then calls main().
INTERRUPT MODE: mtvec MODE0=MODE1=1 (absolute-address vectored mode) -
CONTRACTS.md §14 item 2/§20: confirmed identical on QingKe V3C.
INTSYSCR - UNLIKE ch32v006, this port explicitly WRITES INTSYSCR=0
(common/wch/wch_vectors.h::wch_intsyscr_clear()) rather than only
trusting the documented reset-0 value. Reason (CONTRACTS.md §20 gap log,
this batch): this port's own recon found WCH's OFFICIAL startup
assembly for this exact silicon family (`startup_CH572.S`, Apache-2.0)
explicitly REPROGRAMS INTSYSCR to 0x3 (HWSTKEN=1, INESTEN=1) during
boot - the opposite of what this project's plain `__attribute__((interrupt))`
handlers need (GCC's software prologue, not the vendor hardware one).
A future silicon revision or boot-ROM path could plausibly leave this
CSR non-zero for the same reason WCH's own example sets it - explicit
defense-in-depth, not just documentation.
  - HWSTKEN=0: handlers need a full software frame - exactly what GCC's
    interrupt attribute emits (spill + `mret`).
  - INESTEN=0: no preemption - core's sei() inside ISR_STEP
    (stepper.c) cannot nest the pulse-reset interrupt into the running
    handler; delivery defers to handler exit. Same accepted posture as
    ch32v006 (CONTRACTS.md §5.2) and the SAMD21 M0+ reference.
```

## `timer.h`

timer.h - CH570 stepper/pulse/PWM timer primitives

```
Timer allotment (PLAN.md Phase 6 rolling #4 recon: "audit IRQ capability
per timer BEFORE assigning roles", CONTRACTS.md §14 item 11 lesson
applied again on a new chip):
  stepper timer  = TMR0 (the ONE FIFO/DMA-capable general timer, IRQ 24)
  pulse reset    = STK  (QingKe SysTick analog, IRQ 12)
  spindle PWM    = PWM1 (fixed pin PA7, IRQ not used)
TMR0 has NO hardware clock prescaler - it is a 26-bit up-counter that
free-runs at Fsys and reloads at CNT_END on cycle-end (ch570.h). AVR/
ch32v006-class ports implement STP_TMR_PRESCALER_SET(v) as a real
clock-select register write; this chip has none, so a silent no-op
(CONTRACTS.md's "canonical violation", the SAMD21 STP_TMR_PRESCALER_SET
bug) is not an option here either. Instead the /1, /8, /64 divisor is
folded into a stored SOFTWARE multiplier that STP_TMR_PERIOD_SET applies
to the value it writes into CNT_END - the externally observable
semantics (period of the underlying real-time tick scales by the
selected divisor) are identical to a hardware prescaler; only the
mechanism differs. 26-bit headroom (67,108,863 max at Fsys) comfortably
covers `65535 (core's uint16_t period) * 64` = 4,194,240, so there is no
overflow risk introducing this multiplier.
```

## `vendor/ISP572.h` - disassembly evidence for the vendored flash driver

`FLASH_EEPROM_CMD` is NOT a far call into a separate boot-ROM address range.
Full disassembly of `vendor/ISP572.o` (`riscv64-unknown-elf-objdump -d`)
shows an ordinary, statically-linked function: every internal call is a
PC-relative `auipc`/`jalr` to another function in the same object, never to
a fixed external address. It talks directly to the memory-mapped flash
controller at 0x40001800-0x40001807 (`R32_FLASH_DATA`, `R32_FLASH_CONTROL`,
`R8_FLASH_CTRL`, `R8_FLASH_CFG` - all datasheet-listed addresses) over an
internal byte-level command/status protocol on `R8_FLASH_CTRL` (0x40001806)
that the public datasheet explicitly declines to document.

Applying the "20 instructions of load-address-and-jump" test a reviewer
should use before accepting any vendored blob, it is clearly not a thin
trampoline. It:

- saves and restores the PFIC interrupt-enable state around the operation
  (`PFIC->ISR`/`IENR` at 0xE000E000), masking all interrupts while flash is
  unreadable - necessary, since the CPU cannot fetch instructions from flash
  during program/erase;
- validates the requested address range against the boot-ROM boundary
  (0x3C000, this port's own `FLASH_USER_SIZE`);
- dispatches eight distinct sub-commands (erase, write, verify, get-ROM-info,
  get-unique-ID, power up/down, software reset, start-I/O - the full `CMD_*`
  set in the header);
- for erase, runs a real block-size-selection loop, choosing among erase
  granularities by address alignment and iterating over the range.

Roughly 1.3KB of real control flow, not a stub. An earlier draft of this
port's comments called this a "boot-ROM call"; that was imprecise and the
disassembly above is the correction.
