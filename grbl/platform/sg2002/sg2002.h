/*
  sg2002.h - Sophgo SG2002 / CV1800B register map for the C906L runtime core
  Part of Grbl

  ############################################################################
  #                                                                          #
  #   UNVERIFIED - NO PUBLIC TRM EXISTS FOR THIS CHIP.                       #
  #                                                                          #
  #   Sophgo has never published a Technical Reference Manual for SG2002 or  #
  #   its CV1800B sibling. EVERY register base, offset, bit position and     #
  #   interrupt number in this file is COMMUNITY-SOURCED - reconstructed     #
  #   from upstream Linux device trees and drivers, the (unversioned,        #
  #   comment-free) cvitek vendor SDK headers, and board-support repos.      #
  #   None of it is vendor documentation.                                    #
  #                                                                          #
  #   Every block below therefore carries its own `UNVERIFIED:` banner       #
  #   stating exactly what the claim rests on and what a bring-up engineer   #
  #   must confirm first. This is CONTRACTS.md §14 item 7's lesson applied   #
  #   pre-emptively: "struct-shaped best-effort register layouts are worse   #
  #   than absent ones - the offsets compile fine and read plausibly; only   #
  #   the RM exposed them". Here there IS no RM, so the mitigation is to be  #
  #   LOUD at every definition site rather than quietly plausible.           #
  #                                                                          #
  #   Confidence is NOT uniform and the banners say so per block. The DW     #
  #   APB GPIO/Timer blocks and the SiFive PLIC / RISC-V CLINT are           #
  #   third-party IP with published specifications of their own, so only     #
  #   the INSTANTIATION (base address, channel count, IRQ number) is         #
  #   guesswork. The mailbox block is Sophgo-proprietary with no             #
  #   specification anywhere - it is the weakest thing in this file, which   #
  #   is why every access to it is funnelled through the two functions       #
  #   sg2002_doorbell_ring()/sg2002_doorbell_ack() (platform.c): one place   #
  #   to fix when real facts land.                                           #
  #                                                                          #
  ############################################################################

  CORE: XuanTie C906L, RV64, no MMU, machine mode only. This is the RUNTIME
  core on EVERY SG2002 configuration - the RISC-V-vs-ARM strap choice applies
  to the BIG Linux-hosting core (C906 or Cortex-A53), never to this one, so
  there is exactly one port to write. See PLAN.md's sg2002 entry.
*/

#ifndef SG2002_H
#define SG2002_H

#include <stdint.h>

#define SG2002_REG32(addr)   (*(volatile uint32_t *)(uintptr_t)(addr))
#define SG2002_REG64(addr)   (*(volatile uint64_t *)(uintptr_t)(addr))

// ============================================================================
// PERIPHERAL BASE ADDRESSES
//
// UNVERIFIED: taken from the upstream Linux `sophgo,cv1800b` device tree
// (arch/riscv/boot/dts/sophgo/cv18xx.dtsi) and the duo-buildroot-sdk board
// files. The DT is a strong source for BASES (the kernel demonstrably works
// against them on the big core) but says nothing about whether the SAME
// physical addresses are reachable from the C906L's side of the fabric, or
// whether Linux is already driving a given block. BRING-UP ENGINEER MUST
// CONFIRM: (a) each block below is left un-probed by the Linux DT (status =
// "disabled" or removed) before this firmware touches it - two drivers on
// one block is a silent-corruption bug, not a compile error; (b) the block's
// clock/reset is ungated by the time this firmware runs (the C906L has no
// clock-controller driver of its own here, so it INHERITS whatever state
// Linux left; a SYNCBUSY-class hang on a gated block is CONTRACTS.md §12.5's
// "compiles but dead" class).
// ============================================================================

#define SG2002_MAILBOX_BASE     0x01900000UL   // Sophgo proprietary IPC mailbox
#define SG2002_PINMUX_BASE      0x03001000UL   // pad mux / pull configuration ("IOBLK")
#define SG2002_GPIO_BASE        0x03020000UL   // DesignWare apb_gpio, 4 banks, 0x1000 stride
#define SG2002_GPIO_STRIDE      0x00001000UL
#define SG2002_PWM_BASE         0x03060000UL   // cvitek PWM block 0 (4 channels)
#define SG2002_TIMER_BASE       0x030A0000UL   // DesignWare apb_timer, 8 channels
#define SG2002_PLIC_BASE        0x70000000UL   // SiFive-style PLIC
#define SG2002_CLINT_BASE       0x74000000UL   // RISC-V CLINT (mtime/mtimecmp/msip)

// ============================================================================
// DESIGNWARE APB GPIO (4 banks x 32 pins)
//
// UNVERIFIED (instantiation only): the REGISTER LAYOUT below is Synopsys
// DesignWare apb_gpio, which has its own published databook and is used
// verbatim by the mainline `gpio-dwapb` driver the cv18xx DT binds to
// ("snps,dw-apb-gpio"). So the offsets are high-confidence; what is
// UNVERIFIED is the base address, the number of banks actually bonded out,
// and whether this particular instantiation was synthesized with the
// optional INT_BOTHEDGE register (offset 0x68). This port does NOT use
// INT_BOTHEDGE - it emulates any-edge by flipping INT_POLARITY in the ISR
// (the ch570 technique, CONTRACTS.md #2.6), which works on every
// configuration including the minimal one.
//
// BRING-UP ENGINEER MUST CONFIRM: bank count, and that PORTA_EOI is
// write-1-to-clear on this synthesis (it is in the databook for edge mode;
// in LEVEL mode EOI has no effect, which would silently re-enter forever -
// this port programs edge mode explicitly for exactly that reason).
// ============================================================================

#define SG2002_GPIO(bank)             (SG2002_GPIO_BASE + (bank) * SG2002_GPIO_STRIDE)

#define SG2002_GPIO_SWPORTA_DR(b)     SG2002_REG32(SG2002_GPIO(b) + 0x00)  // output data
#define SG2002_GPIO_SWPORTA_DDR(b)    SG2002_REG32(SG2002_GPIO(b) + 0x04)  // 1 = output
#define SG2002_GPIO_SWPORTA_CTL(b)    SG2002_REG32(SG2002_GPIO(b) + 0x08)  // 0 = software ctl
#define SG2002_GPIO_INTEN(b)          SG2002_REG32(SG2002_GPIO(b) + 0x30)
#define SG2002_GPIO_INTMASK(b)        SG2002_REG32(SG2002_GPIO(b) + 0x34)
#define SG2002_GPIO_INTTYPE_LEVEL(b)  SG2002_REG32(SG2002_GPIO(b) + 0x38)  // 1 = edge
#define SG2002_GPIO_INT_POLARITY(b)   SG2002_REG32(SG2002_GPIO(b) + 0x3C)  // 1 = rising/high
#define SG2002_GPIO_INTSTATUS(b)      SG2002_REG32(SG2002_GPIO(b) + 0x40)  // masked pending
#define SG2002_GPIO_RAW_INTSTATUS(b)  SG2002_REG32(SG2002_GPIO(b) + 0x44)
#define SG2002_GPIO_DEBOUNCE(b)       SG2002_REG32(SG2002_GPIO(b) + 0x48)
#define SG2002_GPIO_PORTA_EOI(b)      SG2002_REG32(SG2002_GPIO(b) + 0x4C)  // W1C (edge mode)
#define SG2002_GPIO_EXT_PORTA(b)      SG2002_REG32(SG2002_GPIO(b) + 0x50)  // pin level read

// ============================================================================
// PAD PULL CONFIGURATION ("IOBLK")
//
// UNVERIFIED (weak): DesignWare GPIO has NO pull-up/pull-down control of its
// own - pulls live in the SoC's pad-control block, which on cv18xx is a flat
// array of 32-bit per-pad registers in the PINMUX region. The bit positions
// below come from cvitek SDK pinlist headers. The PER-PAD REGISTER INDEX is
// NOT a function of the GPIO bit number in general - it follows the physical
// pad order of the package - so the board config supplies the mapping
// (SG2002_PAD_PU_BASE / _STRIDE), it is NOT derived here.
//
// BRING-UP ENGINEER MUST CONFIRM: the register index of each input pad, and
// the PU/PD bit positions. Getting this wrong does NOT break the build and
// does NOT hang - it silently leaves limit/probe inputs floating, which
// reads as random ALARMs. CONTRACTS.md §1.4 forbids a no-op here, so this
// port implements a REAL write; being wrong is a hardware-bring-up defect,
// being absent would be a contract violation.
// ============================================================================

#define SG2002_PAD_PU_BIT       (1UL << 2)   // pull-up enable
#define SG2002_PAD_PD_BIT       (1UL << 3)   // pull-down enable

// ============================================================================
// DESIGNWARE APB TIMER (8 channels)
//
// UNVERIFIED (instantiation only): register layout is the Synopsys apb_timer
// databook shape that mainline's `dw_apb_timer` driver implements and that
// the cv18xx DT binds via "snps,dw-apb-timer". Channel stride 0x14, global
// block at +0xA0. What is UNVERIFIED: the base, the channel count, the
// per-channel PLIC IRQ numbers, and - the one that matters most - the CLOCK
// feeding the block.
//
// !!! THE CLOCK IS THE F_CPU CONTRACT (PORTING-CHECKLIST Step 1) !!!
// This port declares F_CPU = the APB timer input clock, NOT the 700 MHz CPU
// clock. See timer.h's header for the full reasoning (short version: F_CPU
// is what core's stepper arithmetic treats as the STEPPER TIMER's tick rate,
// and the 8-bit pulse-width horizon of CONTRACTS.md §4 is unrepresentable at
// 700 MHz). BRING-UP ENGINEER MUST MEASURE THIS CLOCK and set the Makefile's
// CLOCK variable to the measured value - a wrong value here is invisible to
// every gate in this project and produces a machine whose feedrates are all
// wrong by a constant factor.
//
// This IP has NO prescaler. The /8 tick that AVR's Timer0 gives core for
// free is synthesized in software (timer.h STP_PULSE_RESET_START).
// ============================================================================

#define SG2002_TMR_CH_STRIDE          0x14UL
#define SG2002_TMR(ch)                (SG2002_TIMER_BASE + (ch) * SG2002_TMR_CH_STRIDE)

#define SG2002_TMR_LOADCOUNT(ch)      SG2002_REG32(SG2002_TMR(ch) + 0x00)
#define SG2002_TMR_CURRENTVAL(ch)     SG2002_REG32(SG2002_TMR(ch) + 0x04)
#define SG2002_TMR_CONTROL(ch)        SG2002_REG32(SG2002_TMR(ch) + 0x08)
#define SG2002_TMR_EOI(ch)            SG2002_REG32(SG2002_TMR(ch) + 0x0C)  // READ to clear
#define SG2002_TMR_INTSTATUS(ch)      SG2002_REG32(SG2002_TMR(ch) + 0x10)

#define SG2002_TMR_CTRL_ENABLE        (1UL << 0)
#define SG2002_TMR_CTRL_MODE_USER     (1UL << 1)   // 1 = user-defined reload, 0 = free-run
#define SG2002_TMR_CTRL_INT_MASK      (1UL << 2)   // 1 = interrupt MASKED
#define SG2002_TMR_CTRL_PWM           (1UL << 3)

// ============================================================================
// CVITEK PWM (spindle)
//
// UNVERIFIED: offsets from cvitek SDK headers only; no databook, no upstream
// Linux driver to cross-check against at the time of writing. Channel n of
// block 0. HLPERIOD = high time, PERIOD = full period, both in block-clock
// ticks; POLARITY/PWMSTART/PWM_OE are per-channel bitmaps.
// BRING-UP ENGINEER MUST CONFIRM: all of it, plus the PWM block's own input
// clock (this port derives the divider from F_CPU, which is the TIMER clock
// - if the PWM block runs off a different clock the spindle frequency is
// wrong, though the DUTY RATIO, which is what CONTRACTS.md §6 actually
// binds, stays correct because it is a ratio of two registers).
// ============================================================================

#define SG2002_PWM_HLPERIOD(n)   SG2002_REG32(SG2002_PWM_BASE + 0x00 + (n) * 4)
#define SG2002_PWM_PERIOD(n)     SG2002_REG32(SG2002_PWM_BASE + 0x10 + (n) * 4)
#define SG2002_PWM_POLARITY      SG2002_REG32(SG2002_PWM_BASE + 0x40)
#define SG2002_PWM_START         SG2002_REG32(SG2002_PWM_BASE + 0x44)
#define SG2002_PWM_DONE          SG2002_REG32(SG2002_PWM_BASE + 0x48)
#define SG2002_PWM_UPDATE        SG2002_REG32(SG2002_PWM_BASE + 0x4C)
#define SG2002_PWM_OE            SG2002_REG32(SG2002_PWM_BASE + 0xD0)

// ============================================================================
// SOPHGO MAILBOX (the doorbell)
//
// UNVERIFIED (WEAKEST BLOCK IN THIS FILE - treat as a placeholder shape, not
// a fact): Sophgo's mailbox is proprietary IP with no databook and no
// upstream Linux driver. The upstream remoteproc driver this port's
// lifecycle depends on (`sophgo,cv1800b-c906l`) deliberately deferred its
// mailbox half - the upstream commit says the IPC "will be added in a
// separate patch" - so there is not even kernel source to read. The offsets
// below follow the cvitek SDK's `cvi_mailbox.h` naming (cpu_mbox_en /
// cpu_mbox_set / mbox_int_clr as per-CPU byte arrays).
//
// EVERYTHING here is funnelled through sg2002_doorbell_ring()/_ack() in
// platform.c. When real facts land, those two functions and these four
// defines are the ONLY things that change - no other file in this port
// touches the mailbox.
//
// NOTE ON CORRECTNESS SCOPE: a wrong doorbell address breaks LIVENESS (no
// interrupt, or an interrupt that never clears), not the DATA path - the
// shared-memory ring in shm.h is self-describing via head/tail indices, so
// a host-side poll loop works with the doorbell entirely absent. That is a
// deliberate design property, not luck: the weakest-known block was kept
// off the correctness-critical path.
// ============================================================================

#define SG2002_MBOX_CPU_HOST     0u   // the big Linux-hosting core
#define SG2002_MBOX_CPU_RTOS     1u   // this core (C906L)

#define SG2002_MBOX_EN(cpu)      SG2002_REG32(SG2002_MAILBOX_BASE + 0x00 + (cpu) * 4)
#define SG2002_MBOX_INT_CLR(cpu) SG2002_REG32(SG2002_MAILBOX_BASE + 0x10 + (cpu) * 4)
#define SG2002_MBOX_SET(cpu)     SG2002_REG32(SG2002_MAILBOX_BASE + 0x60 + (cpu) * 4)

// ============================================================================
// RISC-V CLINT
//
// UNVERIFIED (base only): the OFFSETS below are the de-facto standard SiFive
// CLINT layout that every RISC-V core in the wild implements and that the
// RISC-V ACLINT specification codifies; the BASE comes from the cv18xx DT
// (`clint@74000000`). mtime is this port's time source for _delay_us/_ms -
// a real monotonic counter, chosen over a calibrated busy-loop precisely
// because a busy-loop's cycle count on a superscalar 700 MHz C906L is a
// guess and mtime is not.
//
// BRING-UP ENGINEER MUST CONFIRM: the mtime tick rate (this port assumes it
// equals F_CPU - see SG2002_MTIME_HZ in platform.h) and that the C906L is
// hart 0 in ITS OWN CLINT view.
// ============================================================================

#define SG2002_CLINT_MSIP(hart)     SG2002_REG32(SG2002_CLINT_BASE + 0x0000 + (hart) * 4)
#define SG2002_CLINT_MTIMECMP(hart) SG2002_REG64(SG2002_CLINT_BASE + 0x4000 + (hart) * 8)
#define SG2002_CLINT_MTIME          SG2002_REG64(SG2002_CLINT_BASE + 0xBFF8)

// ============================================================================
// PLIC
//
// UNVERIFIED (base + context number): the LAYOUT is the SiFive PLIC
// specification, which is stable and widely implemented. What is UNVERIFIED
// and genuinely risky is the CONTEXT NUMBER: a PLIC assigns one
// enable/threshold/claim context per (hart, privilege level), and the
// mapping of contexts to harts on this SoC is not documented anywhere. The
// C906L's M-mode context is SG2002_PLIC_CONTEXT, a build knob, NOT a
// hard-coded constant, precisely because it is the single most likely thing
// to be wrong.
//
// BRING-UP ENGINEER MUST CONFIRM: the context index (symptom of a wrong
// value: every interrupt in this port is silently never delivered, and the
// machine simply never steps), and every per-peripheral IRQ number below.
// ============================================================================

/*
  PLIC interrupt numbers.
  UNVERIFIED: read out of the upstream cv18xx device tree's `interrupts`
  properties. The DT is evidence that Linux uses these numbers successfully
  FROM ITS OWN CONTEXT; it is not evidence that the same numbers are
  reachable from the C906L's context, which is a separate PLIC context whose
  enable bits Linux does not touch.
  BRING-UP ENGINEER MUST CONFIRM: each number, by triggering the source and
  observing the claim register.
*/
#define SG2002_IRQ_GPIO(bank)          (60u + (bank))
#define SG2002_IRQ_TIMER(ch)           (79u + (ch))
#define SG2002_IRQ_MAILBOX             101u

/*
  PLIC context for this core in machine mode.
  UNVERIFIED and the single most likely thing in this file to be wrong -
  hence a build knob (-DSG2002_PLIC_CONTEXT=n), not a buried constant.
  SYMPTOM OF A WRONG VALUE: no interrupt this port enables is ever
  delivered; the firmware boots, prints its banner (the TX ring needs no
  interrupt) and then never steps. That is a distinctive enough signature to
  name here so the first bring-up hour is not spent elsewhere.
*/
#ifndef SG2002_PLIC_CONTEXT
  #define SG2002_PLIC_CONTEXT          2u
#endif

#define SG2002_PLIC_PRIORITY(irq)      SG2002_REG32(SG2002_PLIC_BASE + (irq) * 4)
#define SG2002_PLIC_PENDING(irq)       SG2002_REG32(SG2002_PLIC_BASE + 0x1000 + ((irq) / 32) * 4)
#define SG2002_PLIC_ENABLE(ctx, irq)   SG2002_REG32(SG2002_PLIC_BASE + 0x2000 + (ctx) * 0x80 + ((irq) / 32) * 4)
#define SG2002_PLIC_THRESHOLD(ctx)     SG2002_REG32(SG2002_PLIC_BASE + 0x200000 + (ctx) * 0x1000)
#define SG2002_PLIC_CLAIM(ctx)         SG2002_REG32(SG2002_PLIC_BASE + 0x200000 + (ctx) * 0x1000 + 4)

// ============================================================================
// C906 / XTheadCmo CACHE MAINTENANCE
//
// The cross-core coherency primitives (CONTRACTS.md #cross-core-cache-
// coherency). These are T-Head VENDOR instructions, not base RISC-V.
//
// VERIFIED AGAINST THIS TOOLCHAIN (not assumed from documentation - that is
// exactly the mistake CONTRACTS.md §19 Lesson 1 and §20 both record):
// assembled with riscv64-unknown-elf-gcc 13.2.0 / binutils 2.42 using
// `-march=rv64imac_zicsr_xtheadcmo_xtheadsync` and disassembled back:
//   th.dcache.cva  a0 -> 0255000b      th.dcache.civa a0 -> 0275000b
//   th.dcache.iva  a0 -> 0265000b      th.dcache.call    -> 0010000b
//   th.sync.s         -> 0190000b      th.sync.is        -> 01b0000b
// Adding those two extension strings to -march does NOT change multilib
// selection - re-checked 2026-07-26 against this port's CURRENT
// rv64imafc_zicsr/lp64f (still resolves rv64imafc/lp64f, checked with
// -print-multi-directory; originally checked against the port's prior
// rv64imac_zicsr/lp64, same non-effect) - and does NOT let the compiler
// emit these ops on its own - they only appear where this file's inline
// asm puts them. The encodings themselves are pure hex-value facts,
// unaffected by the port's F/D ABI choice either way.
//
// UNVERIFIED: that the C906L *implements* XTheadCmo. The C906 does (it is a
// documented part of the XuanTie ISA extension set); the cut-down "L"
// variant is community-described as a C906 with the MMU and some extensions
// removed, and no document states which. An unimplemented op traps as an
// illegal instruction - a LOUD failure, which is the acceptable direction.
// This is also why SHM_COHERENCY=NONCACHEABLE exists as an alternative
// (platform.h): it needs no vendor instruction at all.
// ============================================================================

// Clean (write back) the cache line containing `addr` to memory.
static inline void sg2002_dcache_clean_line(const volatile void *addr) {
  __asm__ volatile (".insn r 0x0b, 0, 0x01, x0, %0, x5" :: "r"(addr) : "memory");
}

// Invalidate the cache line containing `addr` (discard our stale copy).
static inline void sg2002_dcache_invalidate_line(const volatile void *addr) {
  __asm__ volatile (".insn r 0x0b, 0, 0x01, x0, %0, x6" :: "r"(addr) : "memory");
}

/*
  Why `.insn` and not the mnemonics: the mnemonics require the
  `_xtheadcmo` -march string, and putting a vendor extension into -march for
  the WHOLE build to satisfy two inline-asm sites would also stamp the
  extension into the ELF's arch attribute for every object, misrepresenting
  the binary's real ISA requirements. `.insn r <opcode>, <funct3>, <funct7>,
  rd, rs1, rs2` emits the identical word with the base -march.

  Encoding cross-check (this is the verification, do not delete it): the
  XTheadCmo family is opcode 0x0b, funct3 0, rd=x0, rs2 selecting the
  operation, funct7 = 0x01 for the by-address ops:
    th.dcache.cva  rs1  = 0x0250000b | (rs1 << 15)   rs2 = x5  (0x05)
    th.dcache.iva  rs1  = 0x0260000b | (rs1 << 15)   rs2 = x6  (0x06)
    th.dcache.civa rs1  = 0x0270000b | (rs1 << 15)   rs2 = x7  (0x07)
  funct7 0x01 << 25 = 0x02000000; rs2 5 << 20 = 0x00500000; sum 0x0250000b
  with opcode 0x0b - matches the disassembly above exactly.
*/

// Full data fence. Base RISC-V, no vendor extension needed.
#define SG2002_FENCE()   __asm__ volatile ("fence rw, rw" ::: "memory")

#endif // SG2002_H
