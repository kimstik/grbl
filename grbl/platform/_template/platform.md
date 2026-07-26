# Port template port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `boards/generic/config.h`

config.h - Generic _template board configuration (copy-me starting point)

Placeholder pin map so the template compiles standalone. Every *_PORT
value below is just an index into the PORT_TODO_GPIO_* arrays in
../../gpio.h - it has no hardware meaning until gpio.h's accessors are
replaced with real registers. Copy this directory (boards/generic ->
boards/yourboard) and replace every value with your real wiring; the
*_BIT numbers only need to stay distinct within their own group and
(for LIMIT/CONTROL/PROBE) inside bits 0-7 (CONTRACTS.md §1.3 - core
truncates input-group reads to uint8_t; SAMD21's megarm board got this
wrong for CONTROL, see CONTRACTS.md §13).
PORT_TODO_GPIO_* is unset-length (extern volatile uint32_t foo[];), so
nothing here needs to know how many logical "ports" exist - just keep
distinct groups on distinct indices so one group's mask writes never
disturb another's bits when GPIO_MWO does a real read-modify-write.

## `gpio.h`

gpio.h - _template GPIO register accessors (copy-me starting point)

CONTRACTS.md §1: GPIO_OREG/IREG/DREG/PREG are the four register accessors
common/gpio.h's GPIO_M* and GPIO_B* families compose on top of
(name##_PORT picks the register set, name##_BIT/_MASK picks the bits
within it). This
file must be included BEFORE ../common/gpio.h (see
boards/generic/prelude.h) - common/gpio.h only supplies AVR-style
defaults for accessors that are not already defined.
DESIGN: GPIO_OREG is used both as an rvalue (GPIO_MRD, GPIO_BSET, ...) AND
as a raw lvalue (`GPIO_OREG(STEP) = st.step_bits` under STEP_PULSE_DELAY,
stepper.c:513) - a call expression cannot serve as an lvalue, so the usual
"call to undeclared PORT_TODO_<name>()" shape does not fit here. Instead
each accessor indexes into an extern array that is declared but never
DEFINED anywhere in this template: it compiles (arrays decay to valid
lvalues/rvalues at any index), and it fails at LINK time with an
undefined reference to the array's name - same "linker enumerates the gap
by name" contract as every other PORT_TODO_* in this port, just shaped to
stay assignable.
Once you have real per-chip port registers, replace all four #defines
below with direct register-struct member access (see samd21/gpio.h:15-18
for the pattern: `PORT->Group[name##_PORT].OUT` etc.) and delete the
PORT_TODO_GPIO_* array declarations.

## `handlers.c`

handlers.c - _template interrupt dispatch + integration glue (copy-me starting point)

Houses the ISR *vector* dispatch wrappers PORTING-CHECKLIST.md Step 6
groups together (CONTRACTS.md §2 gpio, §5 timer): naming/clearing/
forwarding glue between a real vector slot and core's ISR_STEP()-class
bodies. Stateful chip bring-up (delay calibration, GPIO-IRQ controller
arm-up) lives in platform.c instead - see its header comment for why the
split matches every landed port's own file boundary.
Every dispatcher below is deliberately named *_irq_dispatch rather than a
real vector name (TC3_Handler, EIC_Handler, ...) - this template does not
know your chip's vector table layout. Wire each one into startup.c's
vector_table[] under its real IRQ slot once you know it; until then they
are kept reachable only by the __keep_alive table at the bottom of this
file (see its comment - delete that table once real wiring exists).

## `nvmem.c`

nvmem.c - _template EEPROM emulation (copy-me starting point)

TU-replacement route (CONTRACTS.md §0/§10): provides the four-function
NVMEM API core settings.c needs; this platform's Makefile excludes core
nvmem.c/eeprom.c. Bounds-checking, the wear guard (skip a write if the
byte already matches) and the bulk checksum loops are genuinely
chip-agnostic and are real, working code below - only the two innermost
primitives (read one byte, write one byte with whatever
erase-before-write dance your flash controller needs) are PORT_TODO.
Context (§10.1): mainline only, interrupts enabled, never called from
ISR. Blocking here is fine - grbl only calls these from `$` commands
(IDLE/ALARM) - but do NOT add background/deferred writes; settings_read
may follow a write immediately.
Checksum fidelity (§10.4): this file uses bitwise `|` in the checksum
rotate, NOT the AVR core's logical `||` quirk (nvmem.c:127,149 upstream -
preserved there only for byte-golden AVR output). Never import the `||`
quirk into new code, and never "fix" it on AVR - cross-platform NVMEM
image portability is a non-goal; each platform only needs to be
self-consistent between its own write and read paths.

## `platform.c`

platform.c - _template stateful chip glue (copy-me starting point)

```
PORT-TODO: this whole file. Every landed port in this tree (samd21,
ch32v006, ch570, hc32f460, dspic33ak128mc102, stm32f103/f411/h523) needed
a platform.c to hold the STATEFUL chip glue that platform.h's macros
cannot be - things that need a static/local variable, a calibration
constant, or a one-time boot-sequence call, as opposed to platform.h's
pure inline-asm macros (HAL_CRITICAL_SECTION_*, sei/cli - genuinely
stateless PRIMASK sequences, correctly NOT here). This file is that home
for this template. Two things intentionally still live elsewhere:
  - PORT_TODO_SYSTEM_CLOCK_INIT() stays a direct call inside startup.c's
    SystemInit() (not wrapped here) - it must run before this file's own
    globals (delay calibration, millisecond counters) are printed or
    timed, and keeping it in the one file that already owns boot
    sequencing avoids a false "which file runs first" question.
  - ISR *vector* dispatch wrappers (stepper_timer_irq_dispatch() etc.)
    stay in handlers.c, matching every landed port's own file boundary
    (that file's job is naming/clearing/forwarding to core; this file's
    job is chip bring-up state).
```

## `platform.h`

platform.h - _template chip-specific HAL (copy-me starting point)

PORT-TODO: this whole file. Copy _template/ (see README.md), rename the
include guard below, then work through PORTING-CHECKLIST.md in order.
Ground truth for every contract cited here: grbl/platform/CONTRACTS.md.
DESIGN: every macro this file cannot implement without knowing the real
chip expands to a call to an undeclared PORT_TODO_<name>() function
(grbl/platform/CONTRACTS.md, "the cautionary tale" - no silent no-op
stubs, ever). Each .c file that uses one still compiles; the full port
only links once every PORT_TODO_* symbol has a real definition. Undefined
symbols at link time enumerate the remaining work BY NAME - that is the
point of this design, not a bug to work around.

## `serial.c`

serial.c - _template serial port driver (copy-me starting point)

TU-replacement route (CONTRACTS.md §0/§7): this file provides the whole
grbl/serial.h API instead of core grbl/serial.c; this platform's Makefile
excludes the core file. The ring-buffer bookkeeping below (head/tail
math, the DMB memory-ordering fix for BUG #12) is genuinely chip-agnostic
and is reused verbatim from samd21/serial.c - only the actual UART
register touches are PORT_TODO_SERIAL_* calls. That split is deliberate:
copying the ring buffer logic into every port and getting the ordering
subtly wrong each time is worse than sharing one proven implementation
and localizing the hardware-specific 20% behind a handful of PORT_TODO
primitives.

## `startup.c`

startup.c - _template reset/vector code (copy-me starting point)

PORTING-CHECKLIST.md Step 0/Step 1: vector table, .data copy, .bss zero,
system clock bring-up. The data/bss copy loop below is genuinely
chip-agnostic (every Cortex-M works the same way) and ships real,
working code. The vector table only has room filled in for the handful
of exception slots every Cortex-M core defines identically (Reset, NMI,
HardFault, SVC, PendSV, SysTick) - your chip's peripheral IRQs (the
stepper timer, pulse-reset timer, PWM timer, UART, GPIO/EXTI, ...) go in
the PORT-TODO gap below vector_table[15], in whatever order your
datasheet's vector table assigns them, aliased to the *_irq_dispatch()
functions in handlers.c.
ARM-ONLY WARNING (added after the ch32v006/RISC-V port, Phase 4 M1-M3 -
CONTRACTS.md #14): everything in this file assumes ARM Cortex-M
hardware vector fetch - `vector_table[0]` = initial SP and
`vector_table[1]` = Reset_Handler, loaded into the core automatically
on reset, no software involved. RISC-V (including this repo's
ch32v006) has NO equivalent mechanism at all: there is no hardware SP
autoload, and a data-pointer array is not a valid `mtvec` target in
standard direct mode. If you are porting to a non-ARM core, do NOT
start from this file - read `ch32v006/startup.c` instead for a worked
RISC-V alternative (naked `_start` that sets `sp` itself, an
`__attribute__((interrupt))` C trap entry, `mtvec` written via `csrw`)
and CONTRACTS.md #14 for the full list of what else does not transfer.

## `timer.h`

timer.h - _template stepper/pulse/PWM timer primitives (copy-me starting point)

Every macro below is either (a) a pure naming convention with no chip
content (ISR_STEP/ISR_STEP_RESET/ISR_STEP_DELAY - just tell the core what
to call the ISR body function) or (b) a call to an undeclared
PORT_TODO_<name>() function. (b) compiles today (implicit-declaration
warning) and only fails at LINK time, once and only for the macros this
build path actually reaches - CONTRACTS.md's linker-as-checklist.
Do NOT "temporarily" make any of (b) an empty statement to get further.
That is exactly the STP_TMR_PRESCALER_SET trap CONTRACTS.md opens with:
SAMD21's empty prescaler macro compiles, links, and silently runs slow
segments 8-64x too fast. An undefined symbol is loud; an empty macro is
not - that is the entire point of this design.
