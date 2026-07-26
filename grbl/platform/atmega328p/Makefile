#  Shim Makefile so the AVR reference port builds like every other platform:
#      make -C grbl/platform/atmega328p
#  The real build lives in the repo-root Makefile and is intentionally left
#  untouched there to preserve the byte-exact golden build (see
#  grbl/platform/common/chk.py). BUILD= is accepted for CI uniformity but
#  ignored: the reference build has a single flavor (-Os, no LTO).

ROOT = ../../..

# Root Makefile defaults AVR_GCC_PATH to a developer-machine location;
# prefer the avr-gcc found on PATH when one exists (e.g. apt gcc-avr).
AVR_GCC := $(shell command -v avr-gcc 2>/dev/null)
ifneq ($(AVR_GCC),)
  AVR_GCC_PATH ?= $(patsubst %/,%,$(dir $(AVR_GCC)))
endif
ifneq ($(AVR_GCC_PATH),)
  ROOT_ARGS = AVR_GCC_PATH=$(AVR_GCC_PATH)
endif

# BOOT-INIT REACHABILITY RATCHET (BUG #23, CONTRACTS.md
# #boot-init-unreachable). Every other port runs common/init_check.sh from
# its own Makefile at link time, right after the no-DP assert. This port's
# real link happens in the golden-MD5-gated root Makefile, which stays
# byte-untouched, so the check is attached HERE - to the shim that CI
# already invokes (`make -C grbl/platform/atmega328p validate`), which is
# also where the golden gate itself is reached from.
#
# The list is DELIBERATELY DIFFERENT IN KIND from every other port's, and
# that difference is the reference point for the whole ratchet. atmega328p
# has no software clock bring-up (fuses set the clock) and no GPIO port-
# clock gating, so there is no hal_clock_config/hal_gpio_init to require.
# What it has is the original 2009 model every other port is a translation
# of: main() calls serial_init/settings_init/stepper_init/system_init, and
# the *_init family configures DDR/PORT directly through the GPIO macros.
# Those are the symbols whose presence means "this image will actually
# configure the machine".
#
# atmega328p also carries no LTO risk - the reference build is -Os with no
# -flto, by design - which is exactly why it is the control case: the one
# port where BUG #23 could not have happened, and the one port that was not
# broken. Its list is here so the ratchet has a green baseline that is not
# just "the four ports we fixed".
INIT_SYMBOLS ?= __init,main,serial_init,settings_init,stepper_init,system_init,limits_init,spindle_init,coolant_init,probe_init
INIT_CHECK    = ../common/init_check.sh
NM           ?= avr-nm
ELF           = $(ROOT)/build/main.elf

all:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) all
	@sh $(INIT_CHECK) $(NM) $(ELF) $(INIT_SYMBOLS)

validate:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) validate
	@sh $(INIT_CHECK) $(NM) $(ELF) $(INIT_SYMBOLS)

clean:
	$(MAKE) -C $(ROOT) clean

.PHONY: all validate clean
