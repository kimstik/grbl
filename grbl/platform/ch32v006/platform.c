/*
  platform.c - CH32V006 real (non-PORT_TODO) chip bring-up code
  Part of Grbl

  Houses PORTING-CHECKLIST Step 1 (clock) and Step 2 (GPIO direction/
  pull-up config) real implementations - the two steps this Phase-4
  batch (M1-M3) delivers for real, as opposed to Steps 3-6 which stay
  PORT_TODO in timer.h/handlers.c/serial.c/nvmem.c/platform.h. No
  platform.c existed in `_template` (critical sections/sei/cli are pure
  macros there, nothing else needed a .c file); this chip needs one
  because CFGLR/CFGHR direction config genuinely requires a
  read-modify-write function, not a macro - stm32f103/platform.c is the
  precedent for that same CRL/CRH-shaped problem.
*/

#include <stdint.h>
#include "ch32v006.h"
#include "platform.h"

// ============================================================================
// GPIO DIRECTION / PULL-UP CONFIGURATION (Step 2)
// ============================================================================
/*
  CFGLR covers pins 0-7, CFGHR covers pins 8-15; each pin gets a 4-bit
  CNF[1:0]MODE[1:0] nibble (ch32v006.h's GPIO_CFG_* constants). This is a
  real read-modify-write per pin - NOT expressible as the single-bit
  GPIO_DREG/GPIO_PREG macros common/gpio.h defaults to (gpio.h's file
  header explains why). Boards in this port only use pins 0-7 (CFGLR) per
  boards/generic/config.h's pin map, but pins 8-15 are handled too so this
  function is correct for any future board that uses the upper byte.
*/
static void ch32_gpio_set_cfg(GPIO_TypeDef* port, uint8_t pin, uint32_t cfg4) {
  volatile uint32_t* reg = (pin < 8) ? &port->CFGLR : &port->CFGHR;
  uint8_t shift = (uint8_t)((pin & 7u) * 4u);
  uint32_t mask = 0xFUL << shift;

  *reg = (*reg & ~mask) | ((cfg4 & 0xFUL) << shift);
}

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask) {
  uint32_t cfg = (GPIO_CFG_CNF_OUT_PUSHPULL << 2) | GPIO_CFG_MODE_OUTPUT_10MHZ;
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) { ch32_gpio_set_cfg(port, pin, cfg); }
  }
}

void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask) {
  // Floating input by default (CONTRACTS.md #1.4: pull-up is a SEPARATE
  // call the core makes via GPIO_MPULLUP_EN/DIS - this function must not
  // assume a pull-up is wanted just because a pin becomes an input).
  uint32_t cfg = (GPIO_CFG_CNF_IN_FLOATING << 2) | GPIO_CFG_MODE_INPUT;
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) { ch32_gpio_set_cfg(port, pin, cfg); }
  }
}

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask) {
  // CNF = 0b10 (input, pull-up/down) + ODR bit = 1 selects pull-UP (WCH
  // clones this exactly from STM32F1's CRL/CRH+ODR pull convention).
  // CONTRACTS.md #1.4: this must actually enable a real pull-up, unlike
  // SAMD21's known-wrong PORT.CTRL mapping - this path is a genuine
  // hardware pull-up, not a stand-in.
  uint32_t cfg = (GPIO_CFG_CNF_IN_PULL << 2) | GPIO_CFG_MODE_INPUT;
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) { ch32_gpio_set_cfg(port, pin, cfg); }
  }
  port->OUTDR |= mask;   // ODR=1 under CNF=0b10 -> pull-up (not pull-down)
}

void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask) {
  // Falls back to floating input - matches GPIO_DIR_INP's default so
  // disabling the pull-up doesn't silently reconfigure MODE/CNF twice.
  uint32_t cfg = (GPIO_CFG_CNF_IN_FLOATING << 2) | GPIO_CFG_MODE_INPUT;
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) { ch32_gpio_set_cfg(port, pin, cfg); }
  }
}

// ============================================================================
// SYSTEM CLOCK BRING-UP (Step 1) - HSI -> PLL x2 -> 48 MHz
// ============================================================================
/*
  UNVERIFIED end-to-end on real silicon this session (no hardware/Renode
  model for this chip yet - see ch32v006.h and CONTRACTS.md's new RISC-V
  section for the specific gaps: HSI default frequency, whether V006's
  PLL is really a fixed x2 like V003, FLASH_ACTLR latency threshold).
  Structure mirrors samd21/startup.c's SystemInit() (enable source, wait
  READY, raise flash latency BEFORE switching, switch, wait SWS): the
  ORDER is the part that is architecture-general and safe to trust even
  though the specific register names/bit positions need re-verification.
*/
void SystemClock_Config(void) {
  // 1. HSI is the CH32V00x family's power-on default source and is
  //    already running (RCC_CTLR_HSION set out of reset) - make sure,
  //    then wait for the ready flag.
  RCC->CTLR |= RCC_CTLR_HSION;
  while (!(RCC->CTLR & RCC_CTLR_HSIRDY)) { /* spin */ }

  // 2. Flash wait state BEFORE raising the clock past the zero-wait-state
  //    ceiling (PORTING-CHECKLIST Step 1; samd21/startup.c:138 is the ARM
  //    analog of this same ordering rule).
  FLASH->ACTLR = (FLASH->ACTLR & ~FLASH_ACTLR_LATENCY_Msk) | FLASH_ACTLR_LATENCY_1;

  // 3. PLL: source = HSI, fixed x2 multiplier (V003-family assumption,
  //     see ch32v006.h RCC_CFGR0 comment - GAP if V006 differs).
  RCC->CFGR0 = (RCC->CFGR0 & ~RCC_CFGR0_PLLSRC) | RCC_CFGR0_HPRE_DIV1;
  RCC->CTLR |= RCC_CTLR_PLLON;
  while (!(RCC->CTLR & RCC_CTLR_PLLRDY)) { /* spin */ }

  // 4. Switch SYSCLK to PLL, confirm via SWS.
  RCC->CFGR0 = (RCC->CFGR0 & ~RCC_CFGR0_SW_Msk) | RCC_CFGR0_SW_PLL;
  while ((RCC->CFGR0 & RCC_CFGR0_SWS_Msk) != RCC_CFGR0_SWS_PLL) { /* spin */ }

  // F_CPU (Makefile CLOCK=48000000) now describes the real SYSCLK, IF the
  // fixed-x2-PLL assumption above holds - PORTING-CHECKLIST Step 1's exit
  // test (scope/emulator-verified clock speed) is NOT satisfied yet; no
  // hardware or cycle-accurate emulator exists for this chip in this
  // session. Logged as an open item, not silently claimed done.
}
