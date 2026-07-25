/*
  script.ld - PORT-TODO: generic Cortex-M linker script placeholder
  Part of Grbl

  PORTING-CHECKLIST.md Step 0 requires a linker script as part of the
  skeleton. This one is deliberately minimal and chip-agnostic: it only
  assumes a single FLASH region (code + rodata + vector table) and a single
  RAM region (data/bss/stack), which is true of essentially every Cortex-M
  part. Replace the two placeholder LENGTH values below with your chip's
  real numbers (and split FLASH if your part reserves a bootloader region,
  see samd21/script.ld for that pattern) before this ever needs to link for
  real.

  Nothing here is a PORT_TODO_*() call - a wrong LENGTH does not fail loudly
  at link time, it fails at flash time or silently corrupts memory. Get the
  numbers from the datasheet, not from guessing.
*/

ENTRY(Reset_Handler)

_stack_size = 0x400;  /* PORT-TODO: size your stack for real worst-case depth */

MEMORY
{
  /* PORT-TODO: replace ORIGIN/LENGTH with your chip's real flash/RAM map */
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 16K
}

SECTIONS
{
  .text :
  {
    /* ARMv6-M/v7-M VTOR requires the vector table on a suitably aligned
       boundary (256 bytes is always sufficient; some parts allow less). */
    . = ALIGN(256);
    KEEP(*(.isr_vector))
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)
    KEEP(*(.init))
    KEEP(*(.fini))
    . = ALIGN(4);
    _etext = .;
  } > FLASH

  .ARM.extab :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } > FLASH

  .ARM.exidx :
  {
    __exidx_start = .;
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    __exidx_end = .;
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

  /* newlib's libnosys sbrk.c (pulled in by --specs=nosys.specs, see the
     Makefile's LDFLAGS comment) references the classic "end" symbol as the
     heap's lower bound - core grbl never calls malloc, but sbrk() being
     merely LINKABLE still requires this to resolve. */
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

  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

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

ASSERT((vector_table & 0xFF) == 0, "vector_table must be 256-byte aligned for VTOR")
