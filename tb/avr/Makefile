# tb/avr/Makefile - build the simavr cycle-count bench (bench.elf).
#
# Uses the firmware compile line from the top-level Makefile unless COMPILE is
# given, so the cycle counts belong to the flags the firmware ships with.
# Spline options go in DEFS, e.g. make DEFS='-DENABLE_CUBIC_SPLINES'.

ROOT    := ../..
SRC     := $(ROOT)/grbl
BUILD   := build
COMPILE ?= $(shell $(MAKE) -s -C $(ROOT) --no-print-directory --eval 'print-compile: ; @echo $$(COMPILE)' print-compile)
DEFS    ?= -DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES
CC       = $(COMPILE) $(DEFS) -I$(SRC)

FIRMWARE := motion_control gcode spindle_control coolant_control serial protocol \
            stepper eeprom settings nuts_bolts limits jog print probe report system
OBJECTS  := $(addprefix $(BUILD)/,$(addsuffix .o,$(FIRMWARE)) main.o planner.o bench.o)

all: $(BUILD)/bench.elf

$(BUILD)/bench.elf: $(OBJECTS)
	$(CC) -o $@ $^ -lm -Wl,--gc-sections
	avr-size $@

# main.c only contributes the system globals; bench.c owns main().
$(BUILD)/main.o: $(SRC)/main.c | $(BUILD)
	$(CC) -Dmain=grbl_main -c $< -o $@

# Callers keep calling plan_buffer_line(), which bench.c now provides.
$(BUILD)/planner.o: $(SRC)/planner.c | $(BUILD)
	$(CC) -Dplan_buffer_line=tb_plan_buffer_line -c $< -o $@

$(BUILD)/bench.o: bench.c | $(BUILD)
	$(CC) -c $< -o $@

$(BUILD)/%.o: $(SRC)/%.c | $(BUILD)
	$(CC) -c $< -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/bench.elf
	simavr -m atmega328p -f 16000000 $< 2>&1

clean:
	rm -f $(BUILD)/*.o $(BUILD)/bench.elf

.PHONY: all run clean
