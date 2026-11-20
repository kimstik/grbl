# tb/host/Makefile - host correctness bench for G5/G5.1.
#
# Compiles the firmware sources straight from GRBL (default ../../grbl) for
# the PC, in single precision like avr-gcc where double is float. GRBL can
# point at a mutated copy, see mutate.sh.

GRBL    ?= ../../grbl
BUILD   ?= build
DEFS    ?= -DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES
OPT     ?=
RANDOM  ?= 5000
CC       = gcc
CFLAGS   = -std=gnu99 -O2 -g -Wall -I. -I$(GRBL) -include prelude.h $(DEFS) $(OPT)
# Firmware: single precision and -ffast-math, as on AVR. The bench keeps its
# double model and a working isfinite().
FWFLAGS  = -fsingle-precision-constant -ffast-math
TBFLAGS  = -DTB_HOST_DOUBLE

FIRMWARE := gcode motion_control planner nuts_bolts
OBJECTS  := $(addprefix $(BUILD)/,$(addsuffix .o,$(FIRMWARE)) tb.o stubs.o)

all: $(BUILD)/tb

$(BUILD)/tb: $(OBJECTS)
	$(CC) -o $@ $^ -Wl,--wrap=plan_buffer_line -lm

$(BUILD)/%.o: $(GRBL)/%.c prelude.h | $(BUILD)
	$(CC) $(CFLAGS) $(FWFLAGS) -c $< -o $@

$(BUILD)/%.o: %.c prelude.h | $(BUILD)
	$(CC) $(CFLAGS) $(TBFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $@

check: $(BUILD)/tb
	$(BUILD)/tb vectors/*.vec
	$(BUILD)/tb --random $(RANDOM) 1

# The options of the spline section of config.h, each alone and all together.
# $$12 of 0.002 mm takes 7 times the segments, so fewer random curves there.
TOL = -DBEZIER_SIGMA=settings.arc_tolerance
ZL  = -DBEZIER_Z_LINEAR=2
G93 = $(ZL) -DBEZIER_EXACT_INVERSE_TIME

test: check cubic tol zt zl zl-g93 tol-zl-g93

cubic:
	$(MAKE) BUILD=$(BUILD)/$@ DEFS=-DENABLE_CUBIC_SPLINES
	$(BUILD)/$@/tb cubic_only.vec
tol:
	$(MAKE) BUILD=$(BUILD)/$@ OPT='$(TOL)' RANDOM=1000 check
zt:
	$(MAKE) BUILD=$(BUILD)/$@ OPT=-DBEZIER_Z_LINEAR=1 check
zl:
	$(MAKE) BUILD=$(BUILD)/$@ OPT='$(ZL)' check
zl-g93:
	$(MAKE) BUILD=$(BUILD)/$@ OPT='$(G93)' check
tol-zl-g93:
	$(MAKE) BUILD=$(BUILD)/$@ OPT='$(TOL) $(G93)' RANDOM=1000 check

clean:
	rm -rf $(BUILD)

.PHONY: all check test clean cubic tol zt zl zl-g93 tol-zl-g93
