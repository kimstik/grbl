/*
  script.ld - SG2002 C906L linker script
  Part of Grbl

  ############################################################################
  # THIS FILE AND THE DEVICE TREE MUST AGREE. The addresses below are the    #
  # carve-out the `sophgo,cv1800b-c906l` remoteproc node points at through   #
  # its `memory-region` phandle. remoteproc copies each PT_LOAD segment to   #
  # its p_paddr, so a mismatch here does not fail loudly - it writes the     #
  # firmware into whatever else lives at that physical address.              #
  #                                                                          #
  # UNVERIFIED: 0x8fe00000 / 2 MiB follows the cvitek board-support          #
  # convention for the RTOS carve-out on cv18xx parts. It is a DEFAULT,      #
  # not a fact about any particular board. Whoever writes the device tree    #
  # owns this number; change it here and in the Makefile's                   #
  # BOOT_ENTRY_ADDR (which is checked against it post-link) together.        #
  ############################################################################

  There is no flash and no SRAM on this core's side - everything below is
  DDR inside the one carve-out. The region is split three ways so the
  familiar `> DATA AT> CODE` idiom still expresses "initialised data has a
  load address distinct from its run address":

    CODE  1 MiB    .init/.text/.rodata + the load image of .data
    DATA  768 KiB  .data/.bss/.stack at run time
    SHM   256 KiB  the cross-core window (shm.h)

  THE SHM REGION HAS NO SECTION ON PURPOSE. Its address is exported as a
  PROVIDE symbol only, so nothing in the ELF covers it, no PT_LOAD includes
  it, and remoteproc therefore never writes it. That is what gives nvmem.c
  its tier-1 durability (settings survive a firmware stop/start) and what
  keeps a restart from zeroing rings the host may still be attached to.

  DELIBERATELY ABSENT: `_template/script.ld`'s blanket
  /DISCARD/ { libc.a(*) libm.a(*) libgcc.a(*) }. CONTRACTS.md §14 item 4 -
  that block is a latent bug for any target that genuinely needs library
  code, and this one does: even with this port's hardware single-precision
  float (rv64imafc/lp64f - see platform.h's ARCH/ABI note), transcendentals
  core grbl calls (sinf/atan2f/etc, per the FP=SINGLE libm-pin macros in
  every board's prelude.h) are real libm.a calls, not compiler-inlined
  hardware instructions, and crt0/libc still supply startup and memcpy-class
  routines. Discarding those would silently strip a hard dependency instead
  of failing loudly.
*/

ENTRY(_start)

/* 16 KiB. Sized for two nested trap frames (handlers.c supports nesting -
   the stepper/pulse-reset pair may preempt the doorbell handler) plus core
   grbl's own deepest call chain, on a target where DDR is not scarce. */
_stack_size = 0x4000;

MEMORY
{
  CODE (rx)  : ORIGIN = 0x8FE00000, LENGTH = 1M
  DATA (rwx) : ORIGIN = 0x8FF00000, LENGTH = 768K
  SHM  (rw)  : ORIGIN = 0x8FFC0000, LENGTH = 256K
}

SECTIONS
{
  /* _start must be the first thing in the image - it is the ELF entry point
     remoteproc jumps to. KEEP() because --gc-sections is enabled (this port
     reached zero PORT_TODO_* immediately, so CONTRACTS.md §14 item 3's
     porting-time --no-gc-sections posture never applied) and nothing calls
     _start by name. */
  .init :
  {
    KEEP(*(.init))
  } > CODE

  .text :
  {
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(.srodata)
    *(.srodata*)
    . = ALIGN(8);
    _etext = .;
  } > CODE

  .data :
  {
    . = ALIGN(8);
    _sdata = .;
    /* RISC-V gp-relative addressing: gp points 0x800 past the start of the
       small-data area so a signed 12-bit offset reaches the whole 4 KiB
       window. startup.c's _start loads this with relaxation disabled. */
    PROVIDE(__global_pointer$ = . + 0x800);
    *(.sdata)
    *(.sdata*)
    *(.data)
    *(.data*)
    . = ALIGN(8);
    _edata = .;
  } > DATA AT> CODE

  _sidata = LOADADDR(.data);

  .bss (NOLOAD) :
  {
    . = ALIGN(8);
    _sbss = .;
    *(.sbss)
    *(.sbss*)
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(8);
    _ebss = .;
  } > DATA

  /* picolibc's sbrk stub wants "end"/"_end". Core grbl never calls malloc,
     but the symbols must resolve to link (ch32v006/ch570 precedent). */
  PROVIDE(end  = _ebss);
  PROVIDE(_end = _ebss);

  .stack (NOLOAD) :
  {
    . = ALIGN(16);
    _sstack = .;
    . = . + _stack_size;
    . = ALIGN(16);
    _estack = .;
  } > DATA

  /* The cross-core window. A symbol, never a section - see the file header. */
  __shm_start = ORIGIN(SHM);
  __shm_end   = ORIGIN(SHM) + LENGTH(SHM);

  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .comment       0 : { *(.comment) }
  .riscv.attributes 0 : { *(.riscv.attributes) }
  .debug_abbrev  0 : { *(.debug_abbrev) }
  .debug_info    0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_line    0 : { *(.debug_line) }
  .debug_frame   0 : { *(.debug_frame) }
  .debug_str     0 : { *(.debug_str) }
  .debug_loc     0 : { *(.debug_loc) }
  .debug_ranges  0 : { *(.debug_ranges) }
}
