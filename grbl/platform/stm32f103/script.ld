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
    /* ARMv7-M VTOR ignores bits [6:0], so the table needs at least 128-byte
       alignment; the architectural rule is "next power of two >= 4*vectors".
       F103 has 59 vectors = 236 bytes -> 256. FLASH ORIGIN is already 256-byte
       aligned so the ALIGN is a no-op today; it keeps the guarantee if ORIGIN
       moves (bootloader offset). The ASSERT at the bottom enforces it. */
    . = ALIGN(256);
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

/* BUG #21 ratchet: Reset_Handler programs SCB->VTOR = vector_table.
 * ARMv7-M VTOR ignores bits [6:0]; 59 vectors * 4 = 236 bytes -> 256-byte
 * alignment.
 * NOTE: this ASSERT does NOT catch a vanished table. Verified empirically:
 * with the fix reverted, ld resolves the undefined `vector_table` to 0, and
 * (0 & 0xFF) == 0 passes. Alignment is all it guards. The thing that actually
 * catches a dropped vector table is the post-link BOOT INTEGRITY check in the
 * Makefile (common/boot_check.sh). Do not treat this ASSERT as that guard. */
ASSERT((vector_table & 0xFF) == 0, "vector_table must be 256-byte aligned for VTOR")
