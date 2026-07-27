/*
  script.ld - SAMD21G18A linker script
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Memory layout for SAMD21G18A with rSamba bootloader:
  - Bootloader: 512 bytes (0x00000000 - 0x000001FF) - rSamba
  - Application: 255.5 KB (0x00000200 - 0x0003EFFF)
  - NVMEM:       4 KB     (0x0003F000 - 0x0003FFFF) - Settings
  - RAM:         32 KB    (0x20000000 - 0x20007FFF)

  rSamba: https://github.com/kimstik/rSamba
  Ultra-compact 512-byte bootloader for SAMD21
*/

/* Entry point */
ENTRY(Reset_Handler)

/* Stack size */
_stack_size = 0x1000;  /* 4KB stack */

/* Memory regions */
MEMORY
{
  /* rSamba bootloader occupies first 512 bytes */
  FLASH (rx)  : ORIGIN = 0x00000200, LENGTH = 255488  /* 256K - 512B - 4KB */
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 32K
}

/* Section definitions */
SECTIONS
{
  /* Vector table and code */
  .text :
  {
    /* ARMv6-M VTOR implements only bits [31:8]: the vector table must sit on
       a 256-byte boundary. FLASH ORIGIN (0x200) already satisfies this, so
       the ALIGN is a no-op today; it keeps the guarantee if ORIGIN changes. */
    . = ALIGN(256);
    KEEP(*(.isr_vector))    /* Vector table must be first */
    *(.text)                /* Program code */
    *(.text*)
    *(.rodata)              /* Read-only data */
    *(.rodata*)
    *(.glue_7)              /* ARM/Thumb interworking */
    *(.glue_7t)
    KEEP(*(.init))
    KEEP(*(.fini))
    . = ALIGN(4);
    _etext = .;             /* End of code section */
  } > FLASH

  /* ARM exception handling */
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

  /* Initialized data (copied from Flash to RAM at startup) */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;             /* Start of .data in RAM */
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;             /* End of .data in RAM */
  } > RAM AT> FLASH

  /* Address in Flash where .data is stored */
  _sidata = LOADADDR(.data);

  /* Uninitialized data (zero-initialized at startup). (NOLOAD): pure
   * location-counter advance / zero-init, no real file content assigned.
   * GNU ld infers SHT_NOBITS for such a section; ld.lld does NOT and emits
   * real file-backed SHT_PROGBITS instead, which turns `objcopy -O binary`
   * into a multi-hundred-MB .bin (see TOOLCHAIN-AXIS.md, same bug already
   * fixed on stm32f103/f411/h523/hc32f460/ch32v006/ch570/_template - this
   * port was flagged there as still needing it, fixed here 2026-07-27
   * during the toolchain size-matrix session). Verified zero-cost under
   * GNU ld/gcc: fresh RELEASE rebuild's .bin is byte-identical to the
   * committed artifacts/samd21-generic and samd21-megarm grbl_samd21.bin
   * for both boards. */
  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    _sbss = .;              /* Start of .bss */
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;              /* End of .bss */
  } > RAM

  /* Stack (grows downward from end of RAM) */
  .stack (NOLOAD) :
  {
    . = ALIGN(8);
    _sstack = .;
    . = . + _stack_size;
    . = ALIGN(8);
    _estack = .;
  } > RAM

  /* Remove debug information */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  /* Debugging sections */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }

  /* DWARF debug sections */
  .debug_abbrev     0 : { *(.debug_abbrev) }
  .debug_info       0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_line       0 : { *(.debug_line) }
  .debug_frame      0 : { *(.debug_frame) }
  .debug_str        0 : { *(.debug_str) }
  .debug_loc        0 : { *(.debug_loc) }
  .debug_macinfo    0 : { *(.debug_macinfo) }
  .debug_ranges     0 : { *(.debug_ranges) }
  .debug_pubtypes   0 : { *(.debug_pubtypes) }
  .debug_pubnames   0 : { *(.debug_pubnames) }
  .debug_aranges    0 : { *(.debug_aranges) }
}

/* Reset_Handler programs SCB->VTOR = vector_table; ARMv6-M ignores VTOR[7:0]. */
ASSERT((vector_table & 0xFF) == 0, "vector_table must be 256-byte aligned for VTOR")
