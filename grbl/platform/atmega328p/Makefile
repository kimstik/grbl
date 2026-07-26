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

# WARNING RATCHET (ci/warn_ratchet.py) wired at build time - CONTRACTS.md
# #warn-ratchet-build-time-wiring, same precedent as INIT_CHECK above:
# attached to THIS shim (never the golden-MD5-gated root Makefile itself),
# right after the check that's already here. See common/warn_check.sh's
# header for the full soundness rationale.
#
# There is no scratch BUILD_DIR knob on the root Makefile to borrow (every
# other port isolates its ratchet rebuild in a private directory - see any
# other port's Makefile), so the object directory handed to warn_check.sh
# IS the root Makefile's own $(ROOT)/build - exactly the same file set its
# own `clean` target already removes (`rm -f grbl.hex $(BUILDDIR)/*.o
# $(BUILDDIR)/*.d $(BUILDDIR)/*.elf`). warn_check.sh only ever deletes *.o
# there before rebuilding, so this does not touch anything `make clean`
# itself would leave alone, and forcing a full rebuild before `validate`
# changes no bytes: the golden build is deterministic, so a clean rebuild
# reproduces the exact same MD5 a stale/incremental one would.
#
# WARN_EXPECT_OBJECTS is the root Makefile's own SOURCE list length (18
# files: main/motion_control/gcode/spindle_control/coolant_control/serial/
# protocol/stepper/nvmem/settings/planner/nuts_bolts/limits/jog/print/
# probe/report/system) - duplicated here, not derived, because it lives in
# a different Makefile this shim is forbidden from editing (golden-MD5
# gate). If a future change to the root Makefile's SOURCE list ever adds or
# removes a file, this constant must be updated to match, or warn_check
# will FAIL LOUDLY (wrong object count) rather than silently ratchet a log
# that no longer represents a full build - the correct failure mode per
# CONTRACTS.md #warn-ratchet-build-time-wiring, not a bug to work around.
WARN_EXPECT_OBJECTS = 18
WARN_OBJ_DIR  = $(ROOT)/build
WARN_LOG      = $(ROOT)/build/warn_atmega328p.log
WARN_BASELINE = ../../../ci/warn_baseline_atmega328p.txt
WARN_RATCHET  = ../../../ci/warn_ratchet.py
WARN_CHECK    = ../common/warn_check.sh

all:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) all
	@sh $(INIT_CHECK) $(NM) $(ELF) $(INIT_SYMBOLS)
	@sh $(WARN_CHECK) $(WARN_OBJ_DIR) $(WARN_EXPECT_OBJECTS) $(WARN_LOG) \
	    $(WARN_BASELINE) $(WARN_RATCHET) -- \
	    $(MAKE) -C $(ROOT) $(ROOT_ARGS) validate

validate:
	mkdir -p $(ROOT)/build
	$(MAKE) -C $(ROOT) $(ROOT_ARGS) validate
	@sh $(INIT_CHECK) $(NM) $(ELF) $(INIT_SYMBOLS)
	@sh $(WARN_CHECK) $(WARN_OBJ_DIR) $(WARN_EXPECT_OBJECTS) $(WARN_LOG) \
	    $(WARN_BASELINE) $(WARN_RATCHET) -- \
	    $(MAKE) -C $(ROOT) $(ROOT_ARGS) validate

clean:
	$(MAKE) -C $(ROOT) clean

.PHONY: all validate clean
