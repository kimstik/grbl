# tools/hosted/Makefile - build the hosted oracle (seg_oracle).
#
# Compiles grbl/stepper.c STRAIGHT OUT OF THE TREE - no copy, no fork. If the
# frozen consumer ever changes, the goldens move and ci/seg_conformance.py says
# so. Part of Grbl / Intelligence assisted / License: MIT

ROOT      := ../..
BUILD_DIR := $(ROOT)/build/hosted
BIN       := $(BUILD_DIR)/seg_oracle

F_CPU ?= 16000000UL

CFLAGS := -std=gnu11 -O1 -g -DF_CPU=$(F_CPU) \
          -I. -I$(ROOT)/grbl/platform/extensions/common \
          -I$(ROOT)/grbl -I$(ROOT)/grbl/platform -I$(ROOT)/grbl/platform/common/dummy \
          -include prelude.h -Wall -Wextra

# -Werror applies to the code THIS directory owns. The frozen stepper.c is
# compiled without it on purpose: its producer half (st_prep_buffer, linked but
# never called here) is float arithmetic written for a compiler where
# double==float, which is exactly what the FP=SINGLE knob exists to pin on the
# firmware side. Silencing that with -Wno-* would also silence it for our files.
OWN_CFLAGS := -Werror

DEPS := prelude.h hosted_rt.h cpu_map.h \
        $(ROOT)/grbl/platform/extensions/common/seg_tap.h \
        $(ROOT)/grbl/platform/extensions/common/segframe.h

OBJ := $(BUILD_DIR)/stepper.o $(BUILD_DIR)/hosted_rt.o $(BUILD_DIR)/stubs.o \
       $(BUILD_DIR)/oracle.o

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) -o $@ $(OBJ) -lm

$(BUILD_DIR)/stepper.o: $(ROOT)/grbl/stepper.c $(DEPS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.c $(DEPS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(OWN_CFLAGS) -c -o $@ $<

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
