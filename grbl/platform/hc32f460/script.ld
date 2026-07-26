/*
 * Linker script for HC32F460JETA
 * 512KB Flash, 128KB RAM (conservative subset of the "up to 192KB" max -
 * see platform.md)
 *
 * Flash origin 0x00000000: this chip boots executing flash directly at
 * address 0 (no bootloader-offset requirement assumed for this generic
 * reference board - a real board with a factory bootloader, like the
 * Voxelab Aquila hardware referenced in regs.h, would move this and rely
 * on the Reset_Handler VTOR write to retarget correctly either way).
 */

ENTRY(Reset_Handler)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 512K
  RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 128K
}

_stack_size = 0x400;   /* 1KB stack */

SECTIONS
{
  .text :
  {
    /* ARMv7-M VTOR ignores bits [6:0], so the table needs at least 128-byte
       alignment; the architectural rule is "next power of two >= 4*vectors".
       This port has 48 vectors (16 core + 32 shared Int000-031) = 192 bytes
       -> 256. FLASH ORIGIN is already 256-byte aligned so the ALIGN is a
       no-op today; it keeps the guarantee if ORIGIN moves (bootloader
       offset). The ASSERT at the bottom enforces it. */
    . = ALIGN(256);
    KEEP(*(.isr_vector))   /* Vector table */
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
    _etext = .;
  } > FLASH

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

  .stack :
  {
    . = ALIGN(8);
    . = . + _stack_size;
    . = ALIGN(8);
    _estack = .;
  } > RAM

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
 * 48 vectors * 4 = 192 bytes -> 256-byte alignment.
 * NOTE: this ASSERT does NOT catch a vanished table (ld resolves an
 * undefined vector_table to 0, and (0 & 0xFF) == 0 passes). The guard that
 * actually catches a dropped vector table is the post-link BOOT INTEGRITY
 * check in the Makefile (common/boot_check.sh). See CONTRACTS.md S18. */
ASSERT((vector_table & 0xFF) == 0, "vector_table must be 256-byte aligned for VTOR")
