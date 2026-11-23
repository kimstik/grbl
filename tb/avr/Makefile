# tb/avr/Makefile - build the simavr benches: bench.elf (cycle counts), dyn.elf (motion).
#
# Uses the firmware compile line from the top-level Makefile unless COMPILE is
# given, so the cycle counts belong to the flags the firmware ships with.
# Spline options go in DEFS, e.g. make DEFS='-DENABLE_CUBIC_SPLINES'.

ROOT    := ../..
SRC     := $(ROOT)/grbl
BUILD   := build
LINES   ?= lines.txt
COMPILE ?= $(shell $(MAKE) -s -C $(ROOT) --no-print-directory --eval 'print-compile: ; @echo $$(COMPILE)' print-compile)
DEFS    ?= -DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES
CC       = $(COMPILE) $(DEFS) -I$(SRC)

FIRMWARE := motion_control gcode spindle_control coolant_control serial protocol \
            stepper eeprom settings nuts_bolts limits jog print probe report system
OBJECTS  := $(addprefix $(BUILD)/,$(addsuffix .o,$(FIRMWARE)) main.o planner.o)

all: $(BUILD)/bench.elf

# dyn.elf: the same firmware with the stepper running, see dyn.c.
dyn: $(BUILD)/dyn.elf

# dump.elf: bench.elf that also prints every segment target, see bench.c.
dump: $(BUILD)/dump.elf

$(BUILD)/bench.elf: $(OBJECTS) $(BUILD)/bench.o
$(BUILD)/dyn.elf: $(filter-out %/serial.o %/system.o,$(OBJECTS)) $(addprefix $(BUILD)/dyn-,serial.o system.o) $(BUILD)/dyn.o
$(BUILD)/dump.elf: $(filter-out %/motion_control.o,$(OBJECTS)) $(BUILD)/dump-motion_control.o $(BUILD)/dump.o
$(BUILD)/bench.elf $(BUILD)/dyn.elf $(BUILD)/dump.elf:
	$(CC) -o $@ $^ -lm -Wl,--gc-sections
	avr-size $@
	@set -- $$(avr-size $@ | tail -1); [ $$(($$1 + $$2)) -le 32768 ] || { echo "$@: $$(($$1 + $$2)) bytes do not fit 32768"; exit 1; }

# bench.c owns main(), main.c only contributes the system globals; dyn.c calls it.
$(BUILD)/main.o: $(SRC)/main.c | $(BUILD)
	$(CC) -Dmain=grbl_main -c $< -o $@

# Callers keep calling plan_buffer_line(), which bench.c and dyn.c now provide.
$(BUILD)/planner.o: $(SRC)/planner.c | $(BUILD)
	$(CC) -Dplan_buffer_line=tb_plan_buffer_line -c $< -o $@

$(BUILD)/bench.o: bench.c $(BUILD)/lines.h | $(BUILD)
	$(CC) -I$(BUILD) -c $< -o $@

# Each line of LINES becomes L("..."); '#' lines are comments. Use a fresh BUILD
# when changing LINES or DEFS; Make does not track command-line options.
$(BUILD)/lines.h: $(LINES) | $(BUILD)
	tr -d '\r' < $< | sed -e '/^#/d' -e '/^$$/d' -e 's/.*/L("&")/' > $@

# dyn.c plays the host in serial_read() and leaves out the $ commands, which it
# never sends, to fit in the flash. Without the RX buffer and with a short TX
# buffer, the stack can be measured beyond the free RAM of the firmware.
$(BUILD)/dyn-serial.o: DYN = -Dserial_read=tb_serial_read -DTX_BUFFER_SIZE=16
$(BUILD)/dyn-system.o: DYN = -Dsystem_execute_line=tb_system_execute_line
$(BUILD)/dyn-%.o: $(SRC)/%.c | $(BUILD)
	$(CC) $(DYN) -c $< -o $@

$(BUILD)/dump.o: bench.c $(BUILD)/lines.h | $(BUILD)
	$(CC) -DTB_DUMP -I$(BUILD) -c $< -o $@

# The dump also prints the trace of BEZIER_Z_LINEAR 3, which the timed bench must not carry.
$(BUILD)/dump-motion_control.o: $(SRC)/motion_control.c | $(BUILD)
	$(CC) -DBEZIER_Z_TRACE -c $< -o $@

$(BUILD)/dyn.o: dyn.c | $(BUILD)
	$(CC) -c $< -o $@

$(BUILD)/%.o: $(SRC)/%.c | $(BUILD)
	$(CC) -c $< -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/bench.elf
	simavr -m atmega328p -f 16000000 $< 2>&1

run-dyn: $(BUILD)/dyn.elf
	simavr -m atmega328p -f 16000000 $< 2>&1

clean:
	rm -f $(BUILD)/*.o $(BUILD)/*.elf $(BUILD)/lines.h

.PHONY: all dyn dump run run-dyn clean
