#  Part of Grbl
#
#  Copyright (c) 2009-2011 Simen Svale Skogsrud
#  Copyright (c) 2012-2016 Sungeun K. Jeon for Gnea Research LLC
#
#  Grbl is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Grbl is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Grbl.  If not, see <http://www.gnu.org/licenses/>.


# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

DEVICE     ?= atmega328p
CLOCK      = 16000000
PROGRAMMER ?= -c avrisp2 -P usb
SOURCE    = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
             protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c\
             print.c probe.c report.c system.c
BUILDDIR = build
SOURCEDIR = grbl
# FUSES      = -U hfuse:w:0xd9:m -U lfuse:w:0x24:m
FUSES      = -U hfuse:w:0xd2:m -U lfuse:w:0xff:m

# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE) -B 10 -F

# Compile flags for avr-gcc v4.8.1. Does not produce -flto warnings.
# COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE) -I. -ffunction-sections

# Compile flags for avr-gcc v4.9.2 compatible with the IDE. Or if you don't care about the warnings.
# LTO disabled for HAL build to achieve 100% binary match
# -include for invisible porting: common/gpio.h is auto-included (skipped for AVR via #ifndef __AVR__)
AVR_GCC_PATH ?= $(HOME)/avr-toolchain/avr/bin
COMPILE = $(AVR_GCC_PATH)/avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE) -I. -Igrbl -Igrbl/platform -ffunction-sections -include grbl/platform/common/gpio.h


OBJECTS = $(addprefix $(BUILDDIR)/,$(notdir $(SOURCE:.c=.o)))

# symbolic targets:
all:	grbl.hex

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	$(COMPILE) -MMD -MP -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $(BUILDDIR)/$@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

#.c.s:
	$(COMPILE) -S $< -o $(BUILDDIR)/$@

flash:	all
	$(AVRDUDE) -U flash:w:grbl.hex:i

fuse:
	$(AVRDUDE) $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID grbl.hex

clean:
	rm -f grbl.hex $(BUILDDIR)/*.o $(BUILDDIR)/*.d $(BUILDDIR)/*.elf

# file targets:
$(BUILDDIR)/main.elf: $(OBJECTS)
	$(COMPILE) -o $(BUILDDIR)/main.elf $(OBJECTS) -lm -Wl,--gc-sections

grbl.hex: $(BUILDDIR)/main.elf
	rm -f grbl.hex
	$(AVR_GCC_PATH)/avr-objcopy -j .text -j .data -O ihex $(BUILDDIR)/main.elf grbl.hex
	$(AVR_GCC_PATH)/avr-size --format=berkeley $(BUILDDIR)/main.elf
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d $(BUILDDIR)/main.elf

cpp:
	$(COMPILE) -E $(SOURCEDIR)/main.c

# Validate AVR build integrity against the tiered known-hash table in
# grbl/platform/common/chk.py (see grbl/platform/CONTRACTS.md
# §chk-py-tiers). --require-canonical means only the gcc 7.3.0 no-LTO
# "working horse" hash passes here - a build that merely matches some
# OTHER recognised entry (e.g. a different toolchain's hash) is reported
# distinctly by chk.py itself (yellow "RECOGNISED (non-canonical)", not
# green "OK (canonical)") and still FAILS this gate, exactly like an
# unrecognised/corrupted image does. This recipe performs no comparison
# itself - chk.py owns the table and the pass/fail decision; this target
# only invokes it and surfaces its exit code.
validate: grbl.hex
	@echo "Validating AVR build integrity (grbl/platform/common/chk.py, canonical tier only)..."
	@python3 grbl/platform/common/chk.py --require-canonical grbl.hex

# include generated header dependencies
-include $(BUILDDIR)/$(OBJECTS:.o=.d)
