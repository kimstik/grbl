/*
  regs.h - Sophgo SG2002 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal register definitions for SG2002 (RISC-V C906)
  Based on Sophgo SG2002 datasheet and XuanTie C906 manual
*/

#ifndef SG2002_REGS_H
#define SG2002_REGS_H

#include <stdint.h>

// ============================================================================
// BASE ADDRESSES (SG2002 Memory Map)
// ============================================================================

// UART base addresses
#define UART0_BASE    0x04140000
#define UART1_BASE    0x04150000
#define UART2_BASE    0x04160000
#define UART3_BASE    0x04170000
#define UART4_BASE    0x041C0000

// GPIO base addresses
#define GPIO0_BASE    0x03020000
#define GPIO1_BASE    0x03021000
#define GPIO2_BASE    0x03022000
#define GPIO3_BASE    0x03023000

// Timer base addresses
#define TIMER0_BASE   0x030A0000

// PLIC (Platform-Level Interrupt Controller)
#define PLIC_BASE     0x70000000

// System control
#define SYSCON_BASE   0x03002000

// ============================================================================
// UART REGISTERS
// ============================================================================

typedef struct {
  volatile uint32_t RBR_THR_DLL;  // 0x00: Receive/Transmit/Divisor Latch Low
  volatile uint32_t DLH_IER;      // 0x04: Divisor Latch High/Interrupt Enable
  volatile uint32_t IIR_FCR;      // 0x08: Interrupt ID/FIFO Control
  volatile uint32_t LCR;          // 0x0C: Line Control
  volatile uint32_t MCR;          // 0x10: Modem Control
  volatile uint32_t LSR;          // 0x14: Line Status
  volatile uint32_t MSR;          // 0x18: Modem Status
  volatile uint32_t SCR;          // 0x1C: Scratch
  uint32_t RESERVED0[4];
  volatile uint32_t USR;          // 0x7C: UART Status
  volatile uint32_t TFL;          // 0x80: Transmit FIFO Level
  volatile uint32_t RFL;          // 0x84: Receive FIFO Level
} UART_TypeDef;

#define UART0  ((UART_TypeDef*)UART0_BASE)
#define UART1  ((UART_TypeDef*)UART1_BASE)
#define UART2  ((UART_TypeDef*)UART2_BASE)
#define UART3  ((UART_TypeDef*)UART3_BASE)
#define UART4  ((UART_TypeDef*)UART4_BASE)

// UART Line Status Register bits
#define UART_LSR_DR     (1 << 0)  // Data Ready
#define UART_LSR_THRE   (1 << 5)  // Transmit Holding Register Empty
#define UART_LSR_TEMT   (1 << 6)  // Transmitter Empty

// UART Line Control Register bits
#define UART_LCR_WLS_8  (3 << 0)  // 8 data bits
#define UART_LCR_DLAB   (1 << 7)  // Divisor Latch Access Bit

// UART Interrupt Enable Register bits
#define UART_IER_ERBFI  (1 << 0)  // Enable Received Data Available Interrupt
#define UART_IER_ETBEI  (1 << 1)  // Enable Transmit Holding Register Empty Interrupt

// ============================================================================
// GPIO REGISTERS
// ============================================================================

typedef struct {
  volatile uint32_t SWPORTA_DR;   // 0x00: Port A Data Register
  volatile uint32_t SWPORTA_DDR;  // 0x04: Port A Data Direction Register
  uint32_t RESERVED0[10];
  volatile uint32_t INTEN;        // 0x30: Interrupt Enable
  volatile uint32_t INTMASK;      // 0x34: Interrupt Mask
  volatile uint32_t INTTYPE_LEVEL;// 0x38: Interrupt Type (level/edge)
  volatile uint32_t INT_POLARITY; // 0x3C: Interrupt Polarity
  volatile uint32_t INTSTATUS;    // 0x40: Interrupt Status
  volatile uint32_t RAW_INTSTATUS;// 0x44: Raw Interrupt Status
  volatile uint32_t DEBOUNCE;     // 0x48: Debounce Enable
  volatile uint32_t PORTA_EOI;    // 0x4C: Clear Interrupt
} GPIO_TypeDef;

#define GPIO0  ((GPIO_TypeDef*)GPIO0_BASE)
#define GPIO1  ((GPIO_TypeDef*)GPIO1_BASE)
#define GPIO2  ((GPIO_TypeDef*)GPIO2_BASE)
#define GPIO3  ((GPIO_TypeDef*)GPIO3_BASE)

// ============================================================================
// TIMER REGISTERS
// ============================================================================

typedef struct {
  volatile uint32_t LOAD_COUNT;   // 0x00: Timer Load Count
  volatile uint32_t CURRENT_VALUE;// 0x04: Timer Current Value
  volatile uint32_t CONTROL;      // 0x08: Timer Control
  volatile uint32_t EOI;          // 0x0C: Timer Interrupt Clear
  volatile uint32_t INT_STATUS;   // 0x10: Timer Interrupt Status
} TIMER_Channel_TypeDef;

typedef struct {
  TIMER_Channel_TypeDef TIMER[8]; // 8 timer channels
  uint32_t RESERVED[20];
  volatile uint32_t TIMERS_INT_STATUS;  // 0xA0: Timers Interrupt Status
  volatile uint32_t TIMERS_EOI;         // 0xA4: Timers Interrupt Clear
  volatile uint32_t TIMERS_RAW_INT_STATUS; // 0xA8: Timers Raw Interrupt Status
} TIMER_TypeDef;

#define TIMER0  ((TIMER_TypeDef*)TIMER0_BASE)

// Timer Control Register bits
#define TIMER_CTRL_ENABLE     (1 << 0)
#define TIMER_CTRL_MODE_FREE  (0 << 1)  // Free-running mode
#define TIMER_CTRL_MODE_USER  (1 << 1)  // User-defined count mode
#define TIMER_CTRL_INT_MASK   (1 << 2)

// ============================================================================
// PLIC (Platform-Level Interrupt Controller)
// ============================================================================

#define PLIC_PRIORITY_BASE    (PLIC_BASE + 0x000000)
#define PLIC_PENDING_BASE     (PLIC_BASE + 0x001000)
#define PLIC_ENABLE_BASE      (PLIC_BASE + 0x002000)
#define PLIC_THRESHOLD_BASE   (PLIC_BASE + 0x200000)
#define PLIC_CLAIM_BASE       (PLIC_BASE + 0x200004)

// Interrupt numbers (SG2002 specific)
#define IRQ_UART0   44
#define IRQ_UART1   45
#define IRQ_UART2   46
#define IRQ_UART3   47
#define IRQ_UART4   48
#define IRQ_GPIO0   60
#define IRQ_GPIO1   61
#define IRQ_GPIO2   62
#define IRQ_GPIO3   63
#define IRQ_TIMER0  16

// ============================================================================
// RISC-V CSR (Control and Status Registers)
// ============================================================================

// Machine Status Register (mstatus) bits
#define MSTATUS_MIE  (1UL << 3)   // Machine Interrupt Enable
#define MSTATUS_MPIE (1UL << 7)   // Previous MIE

// Machine Interrupt Enable (mie) bits
#define MIE_MSIE  (1UL << 3)  // Machine Software Interrupt Enable
#define MIE_MTIE  (1UL << 7)  // Machine Timer Interrupt Enable
#define MIE_MEIE  (1UL << 11) // Machine External Interrupt Enable

// Helper macros for CSR access
#define read_csr(reg) ({ \
  unsigned long __tmp; \
  __asm__ volatile ("csrr %0, " #reg : "=r"(__tmp)); \
  __tmp; })

#define write_csr(reg, val) ({ \
  __asm__ volatile ("csrw " #reg ", %0" :: "rK"(val)); })

#define set_csr(reg, bit) ({ \
  unsigned long __tmp; \
  __asm__ volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })

#define clear_csr(reg, bit) ({ \
  unsigned long __tmp; \
  __asm__ volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })

// Common CSR operations
static inline void enable_interrupts(void) {
  set_csr(mstatus, MSTATUS_MIE);
}

static inline void disable_interrupts(void) {
  clear_csr(mstatus, MSTATUS_MIE);
}

static inline unsigned long save_interrupts(void) {
  return read_csr(mstatus);
}

static inline void restore_interrupts(unsigned long mstatus) {
  write_csr(mstatus, mstatus);
}

#endif // SG2002_REGS_H
