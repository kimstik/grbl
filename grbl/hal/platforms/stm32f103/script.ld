/*
 * Linker script for STM32F103C8T6 (Blue Pill)
 * 64KB Flash, 20KB RAM
 */

ENTRY(Reset_Handler)

/* Memory layout */
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 64K
  RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 20K
}

/* Stack size */
_stack_size = 0x400;  /* 1KB stack */

/* Sections */
SECTIONS
{
  /* Code and read-only data */
  .text :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))  /* Vector table */
    *(.text)              /* Code */
    *(.text*)
    *(.rodata)            /* Read-only data */
    *(.rodata*)
    . = ALIGN(4);
    _etext = .;
  } > FLASH

  /* Initialized data (copied from flash to RAM at startup) */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > RAM AT > FLASH

  _sidata = LOADADDR(.data);

  /* Uninitialized data (zero-initialized at startup) */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > RAM

  /* Stack */
  .stack :
  {
    . = ALIGN(8);
    . = . + _stack_size;
    . = ALIGN(8);
    _estack = .;
  } > RAM

  /* Heap (if needed) */
  .heap :
  {
    . = ALIGN(4);
    _sheap = .;
    . = ORIGIN(RAM) + LENGTH(RAM) - _stack_size;
    . = ALIGN(4);
    _eheap = .;
  } > RAM
}
