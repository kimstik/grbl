# tb/host/Makefile - host correctness bench for G5/G5.1.
#
# Compiles the firmware sources straight from GRBL (default ../../grbl) for
# the PC, in single precision like avr-gcc where double is float. GRBL can
# point at a mutated copy, see mutate.sh.

GRBL    ?= ../../grbl
BUILD   ?= build
DEFS    ?= -DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES
CC       = gcc
CFLAGS   = -std=gnu99 -O2 -g -Wall -I. -I$(GRBL) -include prelude.h $(DEFS)
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

test: $(BUILD)/tb
	$(BUILD)/tb vectors/*.vec
	$(BUILD)/tb --random 5000 1
	$(MAKE) BUILD=$(BUILD)/cubic DEFS=-DENABLE_CUBIC_SPLINES
	$(BUILD)/cubic/tb cubic_only.vec

clean:
	rm -rf $(BUILD)

.PHONY: all test clean
