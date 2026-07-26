# SAMD21 port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `config.h`

config.h - SAMD21 platform configuration

Platform-specific configuration for SAMD21G18A

## `core_cm0plus.h`

core_cm0plus.h - Cortex-M0+ stub header

Minimal stub header for ARM Cortex-M0+ core
TODO: Replace with official CMSIS core headers from ARM

## `generic/config.h`

config.h - Generic SAMD21 Board Configuration

Board: Generic SAMD21G18A
MCU: SAMD21G18A
Description: Generic configuration for SAMD21 development boards
This is a template configuration. Copy this file to create
a custom board configuration in a new boards/ subdirectory.

## `handlers.c`

handlers.c - SAMD21 interrupt handlers

Interrupt handlers for GRBL on SAMD21

## `megarm/config.h`

config.h - MegARM Board Configuration

Board: MegARM
MCU: ATSAMC21E18A-MZ
Description: Arduino Mega pin-compatible replacement board
Reference: https://github.com/kimstik/MegARM
Pin mapping based on MegARM layout - ATmega328P to ATSAMC21E18A-MZ

## `nvmem.c`

nvmem.c - SAMD21 EEPROM emulation using Flash

Uses last 4KB of Flash for EEPROM emulation
Flash: 64-byte pages, 256-byte rows (4 pages per row)

## `platform.c`

platform.c - SAMD21 platform implementation

SAMD21G18A: ARM Cortex-M0+, 48MHz, 32KB RAM, 256KB Flash

## `platform.h`

platform.h - SAMD21/ATSAMC21 platform configuration

This file provides platform-specific definitions for SAMD21G18A / ATSAMC21E18A-MZ.
ARM Cortex-M0+, 48 MHz, 32KB RAM, 256KB Flash
Target: MegARM board - https://github.com/kimstik/MegARM

## `samd21.h`

samd21.h - SAMD21 stub header

Minimal stub header for SAMD21G18A
TODO: Replace with official CMSIS headers from Microchip/Atmel

## `serial.c`

serial.c - SAMD21 serial port driver

SERCOM3 UART at 115200 baud (PA23=RX/PAD1, PA24=TX/PAD2)
Interrupt-driven RX/TX with ring buffers

## `startup.c`

startup.c - SAMD21 startup code

Startup code for SAMD21G18A
- Reset handler
- Vector table
- BSS/Data initialization
- Clock initialization (48 MHz from DFLL48M)
