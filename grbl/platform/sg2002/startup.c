/*
  startup.c - SG2002 startup code
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  RISC-V C906 startup and exception vectors
*/

#include <stdint.h>
#include "platform.h"

// External symbols from linker script
extern uint32_t _sdata, _edata, _sidata;
extern uint32_t _sbss, _ebss;
extern uint32_t _stack_top;

// Main function
extern int main(void);

// Exception/interrupt handlers (weak aliases to default handler)
void default_handler(void) __attribute__((weak));
void timer0_ch0_handler(void) __attribute__((weak, alias("default_handler")));
void uart0_rx_handler(void) __attribute__((weak, alias("default_handler")));
void uart0_tx_handler(void) __attribute__((weak, alias("default_handler")));

// Default handler
void default_handler(void) {
  while (1) {
    __asm__ volatile ("wfi");
  }
}

// Reset handler
void _start(void) {
  // Copy .data section from flash to RAM
  uint32_t *src = &_sidata;
  uint32_t *dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // Zero .bss section
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  // Call main
  main();

  // Hang if main returns
  while (1) {
    __asm__ volatile ("wfi");
  }
}

// RISC-V exception handler
void trap_handler(void) __attribute__((interrupt));
void trap_handler(void) {
  // Read mcause to determine exception/interrupt type
  unsigned long mcause = read_csr(mcause);

  if (mcause & (1UL << 63)) {
    // Interrupt
    unsigned long irq = mcause & 0x7FFFFFFF;

    // Machine external interrupt (IRQ 11) - PLIC interrupts
    if (irq == 11) {
      // Claim the interrupt from PLIC
      volatile uint32_t *plic_claim = (volatile uint32_t*)PLIC_CLAIM_BASE;
      uint32_t plic_irq = *plic_claim;

      // Dispatch to appropriate handler based on PLIC interrupt number
      if (plic_irq == IRQ_TIMER0) {
        timer0_ch0_handler();
      } else if (plic_irq == IRQ_UART0) {
        uart0_rx_handler();  // UART RX/TX share same IRQ in some implementations
      }
      // Add more handlers as needed (GPIO, etc.)

      // Complete the interrupt by writing back to PLIC claim register
      *plic_claim = plic_irq;
    }
    // Machine timer interrupt (IRQ 7) - if using mtime/mtimecmp
    else if (irq == 7) {
      timer0_ch0_handler();
    }
  } else {
    // Exception - hang
    default_handler();
  }
}
