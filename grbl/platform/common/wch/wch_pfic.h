/*
  wch_pfic.h - PFIC (Program Fast Interrupt Controller) register layout,
  Part of Grbl
*/

#ifndef GRBL_PLATFORM_COMMON_WCH_PFIC_H
#define GRBL_PLATFORM_COMMON_WCH_PFIC_H

#include <stdint.h>
#include <stddef.h>

#ifndef WCH_PFIC_IRQ_WORDS
#define WCH_PFIC_IRQ_WORDS 2   // QingKe V2C default (ch32v006: <=64 IRQ numbers)
#endif

#define PFIC_BASE   0xE000E000UL

typedef struct {
  volatile uint32_t ISR[WCH_PFIC_IRQ_WORDS];        // 0x000 enable status (RO)
  uint32_t RESERVED0[8 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t IPR[WCH_PFIC_IRQ_WORDS];         // 0x020 pending status (RO)
  uint32_t RESERVED1[8 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t ITHRESDR;                        // 0x040 priority threshold
  uint32_t RESERVED2;
  volatile uint32_t CFGR;                            // 0x048 (key-gated system reset)
  volatile uint32_t GISR;                            // 0x04C global interrupt status
  volatile uint32_t VTFIDR;                           // 0x050 VTF channel ID select
  uint32_t RESERVED3[3];
  volatile uint32_t VTFADDRR[2];                      // 0x060 VTF 0/1 address
  uint32_t RESERVED4[38];
  volatile uint32_t IENR[WCH_PFIC_IRQ_WORDS];         // 0x100 enable set (write-1)
  uint32_t RESERVED5[32 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t IRER[WCH_PFIC_IRQ_WORDS];         // 0x180 enable clear (write-1)
  uint32_t RESERVED6[32 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t IPSR[WCH_PFIC_IRQ_WORDS];         // 0x200 pending set
  uint32_t RESERVED7[32 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t IPRR[WCH_PFIC_IRQ_WORDS];         // 0x280 pending clear
  uint32_t RESERVED8[32 - WCH_PFIC_IRQ_WORDS];
  volatile uint32_t IACTR[WCH_PFIC_IRQ_WORDS];        // 0x300 active status (RO)
  uint32_t RESERVED9[64 - WCH_PFIC_IRQ_WORDS];
  volatile uint8_t  IPRIOR[256];                      // 0x400 per-IRQ priority byte
  uint32_t RESERVED10[516];
  volatile uint32_t SCTLR;                            // 0xD10 system control
} PFIC_TypeDef;

#define PFIC   ((PFIC_TypeDef*)PFIC_BASE)

// Compile-time layout proof - holds for any WCH_PFIC_IRQ_WORDS value (the
// arithmetic in the reserved arrays above is what keeps it true, not luck).
_Static_assert(offsetof(PFIC_TypeDef, IPR)    == 0x020, "PFIC IPR offset");
_Static_assert(offsetof(PFIC_TypeDef, ITHRESDR) == 0x040, "PFIC ITHRESDR offset");
_Static_assert(offsetof(PFIC_TypeDef, IENR)   == 0x100, "PFIC IENR offset");
_Static_assert(offsetof(PFIC_TypeDef, IRER)   == 0x180, "PFIC IRER offset");
_Static_assert(offsetof(PFIC_TypeDef, IPSR)   == 0x200, "PFIC IPSR offset");
_Static_assert(offsetof(PFIC_TypeDef, IPRR)   == 0x280, "PFIC IPRR offset");
_Static_assert(offsetof(PFIC_TypeDef, IACTR)  == 0x300, "PFIC IACTR offset");
_Static_assert(offsetof(PFIC_TypeDef, IPRIOR) == 0x400, "PFIC IPRIOR offset");
_Static_assert(offsetof(PFIC_TypeDef, SCTLR)  == 0xD10, "PFIC SCTLR offset");

// PFIC enable/disable. RM 6.5.2 (CH32V00X) / the CH570 recon's independent
// cross-check both document the SAME rule: "when using the PFIC_IENRx
// register to mask any interrupt ... add a 'fence.i' instruction for
// synchronization between the core control state and the interrupt
// enable state" - the fence.i in the disable path is TRM-mandated, not
// decorative, on every QingKe generation this header serves.
//
// Parameter is a plain uint32_t (not a chip-specific IRQn_Type enum) so
// this stays chip-agnostic; every WCH port's own IRQn_Type enum converts
// implicitly (GCC sizes a non-negative-valued enum as unsigned int, same
// representation as uint32_t - verified byte-identical on ch32v006 by
// this batch's Part A rebuild gate).
static inline void PFIC_EnableIRQ(uint32_t irqn) {
  PFIC->IENR[irqn >> 5] = 1UL << (irqn & 0x1F);
}
static inline void PFIC_DisableIRQ(uint32_t irqn) {
  PFIC->IRER[irqn >> 5] = 1UL << (irqn & 0x1F);
  __asm volatile ("fence.i" ::: "memory");
}

#endif // GRBL_PLATFORM_COMMON_WCH_PFIC_H
