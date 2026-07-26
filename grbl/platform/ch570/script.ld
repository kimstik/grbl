/*
  script.ld - CH570 linker script
  Part of Grbl

  Memory sizes per the CH572/CH570 Datasheet V1.1 (cross-checked against
  openwch/ch570's own SFR header, ch570.h's file header): 240KB user code
  (0x00000000-0x0003BFFF), BOOT ROM area starts at 0x3C000 (not ours -
  never mapped into FLASH below). 12KB SRAM. The LAST 4KB of the user
  code area is the NVMEM EEPROM-emulation window (nvmem.c / platform.h
  HAL_NVMEM_FLASH_START) - FLASH LENGTH below is shortened to 236K so
  code can never grow into it.

  Vector table: startup.c's PFIC_Vector (absolute-address vectored mode) -
  kept via KEEP(.vectors) so a future --gc-sections reinstatement cannot
  discard it (CONTRACTS.md §14 item 3).
*/

ENTRY(_start)

_stack_size = 0x400;  /* 1KB stack - no ISR nesting (INESTEN=0): one interrupt frame max */

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 236K  /* 240K minus 4K NVMEM window */
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 12K
}

SECTIONS
{
  .init :
  {
    KEEP(*(.init))
    KEEP(*(.vectors))
  } > FLASH

  .text :
  {
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
  } > RAM AT> FLASH

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

  /* picolibc's sbrk stub wants "end"/"_end" - core grbl never calls
     malloc, but the symbol must still resolve to link (ch32v006/script.ld
     precedent). */
  PROVIDE(end = _ebss);
  PROVIDE(_end = _ebss);

  .stack :
  {
    . = ALIGN(8);
    _sstack = .;
    . = . + _stack_size;
    . = ALIGN(8);
    _estack = .;
  } > RAM

  /* Deliberately NOT reproducing `_template`'s blanket /DISCARD/ of
     libc.a/libm.a/libgcc.a (CONTRACTS.md §14 item 4 - the exact gap
     ch32v006 folded back into this doc). RV32IMC has a real M extension
     (hardware multiply/divide - platform.h's PLATFORM_HAS_HW_MULTIPLY/
     DIVIDE are both 1) but STILL has no F extension, so grbl's
     throughout floating-point use needs real libgcc/libm soft-float
     code - discarding it here would silently strip a real dependency. */

  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .comment       0 : { *(.comment) }
  .debug_abbrev  0 : { *(.debug_abbrev) }
  .debug_info    0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_line    0 : { *(.debug_line) }
  .debug_frame   0 : { *(.debug_frame) }
  .debug_str     0 : { *(.debug_str) }
  .debug_loc     0 : { *(.debug_loc) }
  .debug_ranges  0 : { *(.debug_ranges) }
}
