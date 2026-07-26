# `_template` - copy-me starting point for a new GRBL port

This directory is not a port. It is CONTRACTS.md and PORTING-CHECKLIST.md
materialized as a stub skeleton. Its prelude/Makefile structure (one
`-include` per board, chaining gpio.h -> common/gpio.h -> config.h ->
platform.h) follows `../samd21/` (the original post-prelude reference);
its `boards/<name>/` board directory layout instead follows
`../ch32v006/`, `../ch570/`, `../dspic33ak128mc102/` - those three plus
this template are the majority convention (samd21's bare `<name>/` at the
platform root predates `boards/` and was never migrated - see the
Makefile's header comment if you're reconciling the two). Every macro/
function a real chip would need but this template cannot supply
generically expands to a call to an **undeclared** `PORT_TODO_<name>()`
function. That means:

- every `.c` file in this directory **compiles today**, warnings and all
  (each unimplemented call is an implicit-function-declaration warning -
  `-Wall`/`-Wextra` catch it, nothing hides it);
- the port **only links once every `PORT_TODO_*` symbol has a real
  definition** - `make link` (see below) is *expected* to fail, and its
  failure output is the checklist: every undefined symbol names exactly
  one piece of unfinished work.

This is "linker-as-checklist" (`grbl/platform/CONTRACTS.md`, the cautionary
tale up top: SAMD21's `STP_TMR_PRESCALER_SET` is an empty comment macro -
it compiles, links, and silently runs slow segments 8-64x too fast in a
non-AMASS build). An undefined symbol is loud. An empty macro is not. Never
turn a `PORT_TODO_*` call into a silent no-op to make something link -
that is the one thing this design exists to prevent.

## Two shapes of `PORT_TODO_*`

Most macros are used as statements or rvalue expressions, so they expand
to a plain call: `#define STP_TMR_INIT() PORT_TODO_STP_TMR_INIT()`
(`timer.h`, `platform.h`, `serial.c`, `nvmem.c`, `handlers.c`, `startup.c`).

`GPIO_OREG/IREG/DREG/PREG` (`gpio.h`) are also used as **lvalues**
(`GPIO_OREG(STEP) = v` under `STEP_PULSE_DELAY`) - a call expression can't
serve as an lvalue, so those four instead index into an `extern` array
that is declared but never *defined* anywhere in this template. Same
contract (undefined symbol at link time, named after the accessor), shaped
to stay assignable. See `gpio.h`'s docstring for the full reasoning.

## Copy -> rename -> fill in, in this order

1. `cp -r grbl/platform/_template grbl/platform/<yourchip>` and rename
   `boards/generic` to your first real board if you already know its name.
2. Work through `grbl/platform/PORTING-CHECKLIST.md` **in order** - each
   step's exit test depends on the previous one:
   - **Step 0 (skeleton)**: fix `Makefile`'s `PLATFORM_NAME`/`DEVICE`/`CPU`/
     `CLOCK`/`FPU`, add your device to `grbl/platform/hal.h`'s two
     `PLATFORM_<NAME>` branches (see how `PLATFORM_TEMPLATE` is wired there
     as a model), size `script.ld`'s `MEMORY` block. Exit: `make` compiles
     every object file (it already does, from the template as shipped).
   - **Step 1 (clock)**: implement `SystemInit()`'s
     `PORT_TODO_SYSTEM_CLOCK_INIT()` in `startup.c`; wire `SCB->VTOR` if you
     boot through a bootloader. Exit: verified clock speed (scope/emulator).
   - **Step 2 (GPIO)**: replace `gpio.h`'s four `PORT_TODO_GPIO_*` arrays
     with real register access (`samd21/gpio.h` is the 4-line pattern);
     fill in `boards/generic/config.h`'s real pin numbers; audit RMW
     atomicity per `gpio.h`'s comment. Exit: STEP/DIR pins toggle, a
     jumpered LIMIT pin reads back.
   - **Step 3 (timers)**: implement every `PORT_TODO_STP_*`/`PORT_TODO_PWM_*`
     in `timer.h`, plus the matching `PORT_TODO_*_IRQ_CLEAR_FLAG()` calls
     and real vector-table wiring in `startup.c`/`handlers.c`. Exit: scoped
     step pulses at the right width and rate, including AMASS-disabled.
   - **Step 4 (serial)**: implement `serial.c`'s `PORT_TODO_SERIAL_*`
     primitives (ring-buffer logic is already real/working). Exit: banner
     + `$$` dump over the real UART.
   - **Step 5 (NVMEM)**: implement `nvmem.c`'s `PORT_TODO_NVMEM_READ_BYTE`/
     `WRITE_BYTE` (checksum/bounds/wear-guard logic is already real).
     Exit: `$100=...`, power-cycle, value survives; corrupted byte loads
     defaults.
   - **Step 6 (handlers/integration)**: implement `platform.h`'s
     `PORT_TODO_GPIO_INT_ON/OFF`; wire every `handlers.c`/`serial.c`
     dispatcher into `startup.c`'s vector table for real (then delete
     `handlers.c`'s `__keep_alive` table); leave `HAL_WATCHDOG_*` undefined
     unless implementing `ENABLE_SOFTWARE_DEBOUNCE` properly. Exit: full
     grbl binary - jog, limits, control pins, `?` status.
3. Run the weak-memory checklist in `PORTING-CHECKLIST.md` before calling
   any step done - the `__DMB()`/`__DSB()` calls already in `serial.c`/
   `nvmem.c`/`startup.c` cover the two lessons (BUG #12, BUG #13) that are
   generic; anything new you add needs the same audit.
4. Re-add `-Wl,--gc-sections` to the Makefile's `LDFLAGS` once real vector
   wiring exists (see the Makefile's comment on why it's absent here).
5. Add a `ci/warn_baseline_<yourchip>.txt` and a matrix row in
   `.github/workflows/ci.yml` (existing rows are the template - `_template`
   itself must NOT get a row, see below).
6. Fold anything you learn back into `CONTRACTS.md`/this template
   (PLAN.md's standing law: "each port strengthens the system").

Full definition of done: `PORTING-CHECKLIST.md`'s final section.

## Self-test (what proves the mechanism works)

```
make -C grbl/platform/_template            # compiles every object file - expect a sea of
                                            # "-Wimplicit-function-declaration" warnings and
                                            # this template's own #warning "PORT-TODO: <file>"
                                            # markers. Both are EXPECTED, not bugs.
make -C grbl/platform/_template link       # attempts the full link - expect FAILURE, with
                                            # one "undefined reference to PORT_TODO_*" line
                                            # per remaining piece of unfinished work.
```

`all` (the default target) only builds objects, not `link`, so a plain
`make` here never reports a red exit code - `link` is a separate,
deliberately-red target reserved for this proof and for your own progress
checking as you replace `PORT_TODO_*` calls with real code one at a time.

## `_template` must NOT be added to the CI matrix

`.github/workflows/ci.yml`'s matrix builds every real port and blocks on
`make validate` (golden AVR) plus the warning ratchet. `_template` is
designed to **fail to link by construction** - adding it as a matrix row
would either be a permanently-red CI job (useless noise) or would tempt
someone into stubbing out `PORT_TODO_*` calls just to turn it green, which
is precisely the silent-no-op failure mode this whole design exists to
prevent. If you want template drift caught in CI, add a job that runs
`make -C grbl/platform/_template` (object compile only, no `link`) and
nothing more.
