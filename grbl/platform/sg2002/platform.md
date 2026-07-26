# SG2002 port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `config.h`

config.h - SG2002 platform configuration

Platform-specific configuration for Sophgo SG2002

## `handlers.c`

handlers.c - SG2002 interrupt handlers

Interrupt handlers for UART, GPIO, and timers

## `platform.c`

platform.c - SG2002 platform implementation

Sophgo SG2002 (RISC-V C906) HAL implementation

## `platform.h`

platform.h - SG2002 platform HAL definitions

Sophgo SG2002 (RISC-V C906) HAL implementation for LicheeRV-Nano

## `regs.h`

regs.h - Sophgo SG2002 register definitions

Minimal register definitions for SG2002 (RISC-V C906)
Based on Sophgo SG2002 datasheet and XuanTie C906 manual

## `startup.c`

startup.c - SG2002 startup code

RISC-V C906 startup and exception vectors
