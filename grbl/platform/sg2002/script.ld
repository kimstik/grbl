/*
  script.ld - Linker script for SG2002 (RISC-V C906)
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Memory layout for SG2002 with DDR3 RAM
*/

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  /* SG2002 DDR3 memory (256MB, using first 1MB for firmware) */
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 1M
}

SECTIONS
{
  .text : {
    KEEP(*(.text._start))
    *(.text*)
    *(.rodata*)
  } > RAM

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM
  _sidata = LOADADDR(.data);

  .bss : {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM

  /* Stack (grows downward from end of RAM) */
  _stack_top = ORIGIN(RAM) + LENGTH(RAM);

  /* Discard debug info */
  /DISCARD/ : {
    *(.comment)
  }
}
