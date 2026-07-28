# Makefile - Verilated SEGX/1 executor, built as a conformance subject.
#
# Part of Grbl / Intelligence assisted / License: MIT
#
# Nothing in the firmware build reaches this directory. It is host tooling for
# ci/seg_conformance.py, and it is the only place in the tree that needs
# verilator. If verilator is absent the ratchet says so and CI (which passes
# --require-rtl) fails; a developer without it gets a notice, not a false pass.

ROOT      := ../../../..
BUILD_DIR := $(ROOT)/build/hosted/rtl
BIN       := $(BUILD_DIR)/tb_segx
COMMON    := $(ROOT)/grbl/platform/extensions/common

VERILATOR ?= verilator
VROOT     := $(shell $(VERILATOR) --getenv VERILATOR_ROOT)

RTL := segx_top.v segx_exec.v segx_rx.v segx_slot.v segx_crc8.v

# -Wall is on and clean. The RTL is small enough that a lint waiver would be a
# choice, not a necessity, and this tree ratchets warnings everywhere else.
VFLAGS := --cc -Wall -Wno-DECLFILENAME --x-assign 0 --x-initial 0

CXXFLAGS := -std=gnu++17 -O2 -Wall -Wextra -Werror -Wno-unused-parameter -I$(COMMON) \
            -isystem $(VROOT)/include -isystem $(VROOT)/include/vltstd \
            -isystem $(BUILD_DIR)/obj_top -isystem $(BUILD_DIR)/obj_slot

all: $(BIN)

$(BUILD_DIR)/obj_top/Vsegx_top__ALL.a: $(RTL)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) -Mdir $(BUILD_DIR)/obj_top --top-module segx_top \
	  --prefix Vsegx_top $(RTL)
	$(MAKE) -s -C $(BUILD_DIR)/obj_top -f Vsegx_top.mk

$(BUILD_DIR)/obj_slot/Vsegx_slot__ALL.a: segx_slot.v
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) -Mdir $(BUILD_DIR)/obj_slot --top-module segx_slot \
	  --prefix Vsegx_slot segx_slot.v
	$(MAKE) -s -C $(BUILD_DIR)/obj_slot -f Vsegx_slot.mk

$(BIN): tb_segx.cpp $(BUILD_DIR)/obj_top/Vsegx_top__ALL.a \
        $(BUILD_DIR)/obj_slot/Vsegx_slot__ALL.a $(COMMON)/segwire.h \
        $(COMMON)/segframe.h
	$(CXX) $(CXXFLAGS) -o $@ tb_segx.cpp \
	  $(BUILD_DIR)/obj_top/Vsegx_top__ALL.a \
	  $(BUILD_DIR)/obj_slot/Vsegx_slot__ALL.a \
	  $(VROOT)/include/verilated.cpp $(VROOT)/include/verilated_threads.cpp -lpthread

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
