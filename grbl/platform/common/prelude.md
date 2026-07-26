# Build preludes (`-include` injection)
Every non-AVR port injects exactly one header into every translation
unit via the platform Makefile's `-include <board>/prelude.h`. That
header's include order is load-bearing; the reasons are collected here
instead of being restated in each port's copy of the banner.

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `_template/boards/generic/prelude.h`

prelude.h - build prelude for _template / generic board (copy-me starting point)

```
This is the ONE header the platform Makefile injects into every
translation unit via `-include boards/$(BOARD)/prelude.h`
(post-prelude canon - see grbl/platform/samd21/generic/prelude.h for the
original writeup). It replaces a hand-maintained chain of separate
-include flags and fixes their order, which is load-bearing:
  1. ../../gpio.h        This platform's register accessors
                          (GPIO_OREG/IREG/DREG/PREG). MUST come first:
                          ../../../common/gpio.h only supplies AVR-style
                          defaults for accessors that are not already
                          defined.
  2. ../../../common/gpio.h   Generic GPIO bit-op helpers (GPIO_BSET, ...)
                          built on top of the accessors from step 1.
  3. config.h             Board pin map (this directory). Board selection
                          is just the Makefile's BOARD variable pointing
                          -include at a different boards/<name>/prelude.h.
  4. ../../platform.h     Chip-specific HAL: sei/cli, critical sections,
                          GPIO interrupt macros. Must be injected before
                          grbl.h so that common/dummy/avr/io.h sees
                          sei/cli already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks in order to fail
loudly when a non-AVR translation unit is compiled without this
injection (e.g. by invoking the compiler manually instead of the
platform Makefile).
To create a custom board: copy this whole boards/generic/ directory,
adjust config.h - this file usually needs nothing but its header guard
renamed.
```

## `ch32v006/boards/generic/prelude.h`

prelude.h - build prelude for CH32V006 / generic board

```
ONE header the platform Makefile injects into every translation unit
via `-include boards/$(BOARD)/prelude.h` (post-prelude canon, see
samd21/generic/prelude.h for the original writeup). Order is
load-bearing (CONTRACTS.md #0):
  1. ../../gpio.h              CH32V006 register accessors. MUST come
                                first: ../../../common/gpio.h only
                                supplies AVR-style defaults for
                                accessors not already defined.
  2. ../../../common/gpio.h    Generic GPIO bit-op helpers built on
                                top of the accessors from step 1.
  3. config.h                  Board pin map (this directory).
  4. ../../platform.h          Chip-specific HAL: sei/cli, critical
                                sections, GPIO interrupt macros. Must
                                be injected before grbl.h so that
                                common/dummy/avr/io.h sees sei/cli
                                already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to fail loudly
when a non-AVR translation unit is compiled without this injection.
```

## `ch570/boards/generic/prelude.h`

prelude.h - build prelude for CH570 / generic board

```
ONE header the platform Makefile injects into every translation unit
via `-include boards/$(BOARD)/prelude.h` (CONTRACTS.md #0). Order is
load-bearing:
  1. ../../gpio.h              CH570 register accessors. MUST come
                                first: ../../../common/gpio.h only
                                supplies AVR-style defaults for
                                accessors not already defined.
  2. ../../../common/gpio.h    Generic GPIO bit-op helpers built on
                                top of the accessors from step 1.
  3. config.h                  Board pin map (this directory).
  4. ../../platform.h          Chip-specific HAL: sei/cli, critical
                                sections, GPIO interrupt macros. Must
                                be injected before grbl.h so that
                                common/dummy/avr/io.h sees sei/cli
                                already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to fail loudly
when a non-AVR translation unit is compiled without this injection.
```

## `dspic33ak128mc102/boards/generic/prelude.h`

prelude.h - build prelude for dsPIC33AK128MC102 / generic board

```
ONE header the platform Makefile injects into every translation unit
via `-include boards/$(BOARD)/prelude.h` (post-prelude canon, see
samd21/generic/prelude.h for the original writeup). Order is
load-bearing (CONTRACTS.md #0):
  1. ../../gpio.h              dsPIC33AK register accessors (LATx/PORTx/
                                TRISx token-paste dispatch). MUST come
                                first: ../../../common/gpio.h only
                                supplies AVR-style defaults for
                                accessors not already defined.
  2. ../../../common/gpio.h    Generic GPIO bit-op helpers built on
                                top of the accessors from step 1.
  3. config.h                  Board pin map (this directory).
  4. ../../platform.h          Chip-specific HAL: sei/cli, critical
                                sections, GPIO interrupt macros. Must
                                be injected before grbl.h so that
                                common/dummy/avr/io.h sees sei/cli
                                already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to fail loudly
when a non-AVR translation unit is compiled without this injection.
```

## `hc32f460/prelude.h`

prelude.h - build prelude for HC32F460

```
Injected into every translation unit by the Makefile via -include, same
pattern as every other non-AVR port in this tree. Order is load-bearing:
  1. gpio.h               HC32F460 register accessors (GPIO_OREG/IREG) and
                          PCONR-based direction/pull overrides. MUST come
                          first: platform/common/gpio.h only supplies
                          AVR-style defaults for names not already defined.
  2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                          GPIO_BGETOUT, ...) built on the accessors above.
  3. ../common/cortexm/cortexm_critical.h
                          sei/cli plus the HAL critical-section and
                          interrupt-control macros, shared verbatim by every
                          Cortex-M port here. MUST be injected before grbl.h:
                          grbl.h pulls <avr/io.h> (the shared common/dummy
                          stub) at its line 29, and that stub errors out
                          unless sei/cli already exist. This port used to
                          satisfy that with a LOCAL avr/io.h shadowing the
                          shared stub; see that header for the full argument.
The pin map and chip HAL (platform.h, which includes regs.h/timer.h)
arrive through grbl.h's ordinary include chain (grbl.h -> platform/hal.h
-> platform.h). GRBL_PRELUDE is the marker grbl/platform/hal.h checks to
reject compiles that bypass the platform Makefile.
```

## `samd21/generic/prelude.h`

prelude.h - build prelude for SAMD21 / generic board

```
This is the ONE header the platform Makefile injects into every translation
unit via `-include $(BOARD)/prelude.h`.  It replaces the former chain of
four separate -include flags and preserves their exact order, which is
load-bearing:
  1. ../gpio.h            SAMD21 register accessors (GPIO_OREG/IREG/DREG/PREG).
                          MUST come first: platform/common/gpio.h only
                          supplies AVR-style defaults for accessors that are
                          not already defined.
  2. ../../common/gpio.h  Generic GPIO bit-op helpers (GPIO_BSET, ...) built
                          on top of the accessors from step 1.
  3. config.h             Board pin map (this directory). Board selection is
                          the Makefile pointing -include at <board>/prelude.h.
  4. ../platform.h        Chip-specific HAL: registers, EIC macros, sei/cli.
                          Must be injected before grbl.h so that
                          common/dummy/avr/io.h sees sei/cli already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks in order to fail
loudly when a non-AVR translation unit is compiled without this injection
(e.g. by invoking the compiler manually instead of the platform Makefile).
To create a custom board: copy the generic/ directory, adjust config.h -
this file usually needs nothing but its header guard renamed.
```

## `samd21/megarm/prelude.h`

prelude.h - build prelude for SAMD21 / MegARM board

```
This is the ONE header the platform Makefile injects into every translation
unit via `-include $(BOARD)/prelude.h`.  It replaces the former chain of
four separate -include flags and preserves their exact order, which is
load-bearing:
  1. ../gpio.h            SAMD21 register accessors (GPIO_OREG/IREG/DREG/PREG).
                          MUST come first: platform/common/gpio.h only
                          supplies AVR-style defaults for accessors that are
                          not already defined.
  2. ../../common/gpio.h  Generic GPIO bit-op helpers (GPIO_BSET, ...) built
                          on top of the accessors from step 1.
  3. config.h             Board pin map (this directory). Board selection is
                          the Makefile pointing -include at <board>/prelude.h.
  4. ../platform.h        Chip-specific HAL: registers, EIC macros, sei/cli.
                          Must be injected before grbl.h so that
                          common/dummy/avr/io.h sees sei/cli already defined.
GRBL_PRELUDE is the marker grbl/platform/hal.h checks in order to fail
loudly when a non-AVR translation unit is compiled without this injection
(e.g. by invoking the compiler manually instead of the platform Makefile).
```

## `sg2002/prelude.h`

prelude.h - build prelude for Sophgo SG2002 (LicheeRV-Nano)

Injected into every translation unit by the Makefile via -include, same
pattern as samd21's $(BOARD)/prelude.h. Unlike samd21 (whose prelude chains
GPIO register accessors, common/gpio.h helpers, the board pin map and
platform.h), sg2002 currently takes everything through grbl.h's ordinary
include chain, so this prelude deliberately includes nothing - it only
carries the GRBL_PRELUDE marker that grbl/platform/hal.h checks to reject
compiles that bypass the platform Makefile.
When this platform grows -include needs, add them HERE, in dependency
order, instead of adding new -include flags to the Makefile.

## `stm32f103/prelude.h`

prelude.h - build prelude for STM32F103 (Blue Pill)

```
Injected into every translation unit by the Makefile via -include, same
pattern as samd21's $(BOARD)/prelude.h. Order is load-bearing:
  1. gpio.h               STM32F103 register accessors (GPIO_OREG/IREG) and
                          CRL/CRH-based direction/pull overrides. MUST come
                          first: platform/common/gpio.h only supplies
                          AVR-style defaults for names not already defined.
  2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                          GPIO_BGETOUT, ...) built on the accessors above.
  3. ../common/cortexm/cortexm_critical.h
                          sei/cli plus the HAL critical-section and
                          interrupt-control macros, shared verbatim by every
                          Cortex-M port here. MUST be injected before grbl.h:
                          grbl.h pulls <avr/io.h> (the shared common/dummy
                          stub) at its line 29, and that stub errors out
                          unless sei/cli already exist. This port used to
                          satisfy that with a LOCAL avr/io.h shadowing the
                          shared stub; see that header for the full argument.
The pin map and chip HAL (platform.h, which includes timer.h) arrive through
grbl.h's ordinary include chain (grbl.h -> platform/hal.h -> platform.h).
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to reject compiles
that bypass the platform Makefile.
```

## `stm32f411/prelude.h`

prelude.h - build prelude for STM32F411 ("Black Pill")

```
Injected into every translation unit by the Makefile via -include, same
pattern as samd21's $(BOARD)/prelude.h and stm32f103/stm32h523's prelude.h.
Order is load-bearing:
  1. gpio.h               STM32F411 register accessors (GPIO_OREG/IREG) and
                          MODER/PUPDR-based direction/pull overrides. MUST
                          come first: platform/common/gpio.h only supplies
                          AVR-style defaults for names not already defined.
  2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                          GPIO_BGETOUT, ...) built on the accessors above.
  3. ../common/cortexm/cortexm_critical.h
                          sei/cli plus the HAL critical-section and
                          interrupt-control macros, shared verbatim by every
                          Cortex-M port here. MUST be injected before grbl.h:
                          grbl.h pulls <avr/io.h> (the shared common/dummy
                          stub) at its line 29, and that stub errors out
                          unless sei/cli already exist. This port used to
                          satisfy that with a LOCAL avr/io.h shadowing the
                          shared stub; see that header for the full argument.
The pin map and chip HAL (platform.h, which includes timer.h) arrive through
grbl.h's ordinary include chain (grbl.h -> platform/hal.h -> platform.h).
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to reject compiles
that bypass the platform Makefile.
```

## `stm32h523/prelude.h`

prelude.h - build prelude for STM32H523

```
Injected into every translation unit by the Makefile via -include, same
pattern as samd21's $(BOARD)/prelude.h and stm32f103/prelude.h. Order is
load-bearing:
  1. gpio.h               STM32H523 register accessors (GPIO_OREG/IREG) and
                          MODER/PUPDR-based direction/pull overrides. MUST
                          come first: platform/common/gpio.h only supplies
                          AVR-style defaults for names not already defined.
  2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                          GPIO_BGETOUT, ...) built on the accessors above.
  3. ../common/cortexm/cortexm_critical.h
                          sei/cli plus the HAL critical-section and
                          interrupt-control macros, shared verbatim by every
                          Cortex-M port here. MUST be injected before grbl.h:
                          grbl.h pulls <avr/io.h> (the shared common/dummy
                          stub) at its line 29, and that stub errors out
                          unless sei/cli already exist. This port used to
                          satisfy that with a LOCAL avr/io.h shadowing the
                          shared stub; see that header for the full argument.
The pin map and chip HAL (platform.h, which includes timer.h) arrive through
grbl.h's ordinary include chain (grbl.h -> platform/hal.h -> platform.h).
GRBL_PRELUDE is the marker grbl/platform/hal.h checks to reject compiles
that bypass the platform Makefile.
```
