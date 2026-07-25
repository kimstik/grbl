/*
  script.ld - CH32V006 linker script
  Part of Grbl

  Memory sizes TRM-VERIFIED this session (CH32V00X RM V1.5 figure 1-8):
  62KB flash (256B pages 0-247, physical 0x08000000 aliased to 0x0 for
  execution), 8KB SRAM. The LAST 1KB of flash (0x0800F400-0x0800F7FF,
  pages 244-247) is the NVMEM EEPROM-emulation window (nvmem.c /
  platform.h HAL_NVMEM_FLASH_START) - FLASH LENGTH below is shortened to
  61K so code can never grow into it.

  Vector table: startup.c's PFIC_Vector (absolute-address vectored mode,
  mtvec MODE0=MODE1=1) - kept via KEEP(.vectors) so a future
  --gc-sections reinstatement cannot discard it (CONTRACTS.md #14.3).
  mtvec BASEADDR is bits [31:2]: 4-byte alignment, no special placement.
*/

ENTRY(_start)

_stack_size = 0x400;  /* 1KB stack - PORT-TODO: size for real worst-case depth (no ISR nesting: INESTEN=0, one interrupt frame max) */

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 61K  /* 62K minus 1K NVMEM window */
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 8K
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

  /* picolibc's sbrk stub (pulled in transitively via -specs=picolibc.specs
     if any libc/libm code path references it) wants "end"/"_end" - core
     grbl never calls malloc, but the symbol must still resolve to link. */
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

  /*
    GAP found while authoring this port: `_template/script.ld` (and every
    other platform's script.ld copied from it) discards ALL sections from
    libc.a/libm.a/libgcc.a wholesale via /DISCARD/. That is harmless there
    only because the template link always fails earlier on PORT_TODO_*
    undefined references - it never reaches the point of actually needing
    a pulled-in libgcc soft-float/soft-divide routine. This port has NO
    hardware multiply/divide/float (rv32ec, no M extension - platform.h's
    PLATFORM_HAS_HW_MULTIPLY/DIVIDE are both 0) and grbl's core uses
    floating point throughout (planner/gcode/motion_control), so a real
    future link WILL need real libgcc/libm code. Deliberately NOT
    reproducing the blanket /DISCARD/ here - folded back into
    CONTRACTS.md's new RISC-V section as a template gap for other ports
    to avoid inheriting silently.
  */

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
