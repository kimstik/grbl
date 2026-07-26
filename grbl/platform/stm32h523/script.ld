/* Linker script for STM32H523CBT6 */

MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 32K
}

ENTRY(Reset_Handler)

SECTIONS
{
  .isr_vector : {
    /* ARMv7-M VTOR ignores bits [6:0], so the table needs at least 128-byte
       alignment; the architectural rule is "next power of two >= 4*vectors".
       H523 has 77 vectors = 308 bytes -> 512. FLASH ORIGIN is already 512-byte
       aligned so the ALIGN is a no-op today; it keeps the guarantee if ORIGIN
       moves (bootloader offset). The ASSERT at the bottom enforces it. */
    . = ALIGN(512);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  .text : {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    . = ALIGN(4);
  } >FLASH

  .rodata : {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  _sidata = LOADADDR(.data);

  .data : {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >RAM AT >FLASH

  .bss : {
    . = ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } >RAM

  . = ALIGN(8);
  _estack = ORIGIN(RAM) + LENGTH(RAM);
}

/* BUG #21 ratchet: Reset_Handler programs SCB->VTOR = vector_table.
 * ARMv7-M VTOR ignores bits [6:0]; 77 vectors * 4 = 308 bytes -> 512-byte
 * alignment.
 * NOTE: this ASSERT does NOT catch a vanished table. Verified empirically:
 * with the fix reverted, ld resolves the undefined `vector_table` to 0, and
 * (0 & 0xFF) == 0 passes. Alignment is all it guards. The thing that actually
 * catches a dropped vector table is the post-link BOOT INTEGRITY check in the
 * Makefile (common/boot_check.sh). Do not treat this ASSERT as that guard. */
ASSERT((vector_table & 0x1FF) == 0, "vector_table must be 512-byte aligned for VTOR")
