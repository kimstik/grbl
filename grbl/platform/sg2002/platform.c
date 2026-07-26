/*
  platform.c - SG2002 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "../hal.h"
#include "platform.h"
#include "config.h"

// PLATFORM INFO

const char* hal_platform_get_name(void) {
  return "Sophgo SG2002 (LicheeRV-Nano)";
}

const char* hal_platform_get_cpu(void) {
  return "RISC-V C906 @ 700MHz";
}

uint32_t hal_platform_get_cpu_freq(void) {
  return F_CPU;
}

// CRITICAL SECTION

uint32_t _hal_critical_state = 0;

uint32_t hal_critical_enter(void) {
  unsigned long mstatus = save_interrupts();
  disable_interrupts();
  return (uint32_t)mstatus;
}

void hal_critical_exit(uint32_t state) {
  restore_interrupts(state);
}

// GPIO INITIALIZATION

void hal_gpio_init(void) {
  // Configure stepper step pins as outputs
  HAL_GPIO_SET_OUTPUT(X_STEP_PORT, 1UL << X_STEP_PIN);
  HAL_GPIO_SET_OUTPUT(Y_STEP_PORT, 1UL << Y_STEP_PIN);
  HAL_GPIO_SET_OUTPUT(Z_STEP_PORT, 1UL << Z_STEP_PIN);

  // Configure stepper direction pins as outputs
  HAL_GPIO_SET_OUTPUT(X_DIR_PORT, 1UL << X_DIR_PIN);
  HAL_GPIO_SET_OUTPUT(Y_DIR_PORT, 1UL << Y_DIR_PIN);
  HAL_GPIO_SET_OUTPUT(Z_DIR_PORT, 1UL << Z_DIR_PIN);

  // Configure stepper disable pin as output
  HAL_GPIO_SET_OUTPUT(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_MASK);
  HAL_GPIO_SET_BITS(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_MASK); // Disabled by default

  // Configure limit switch pins as inputs
  HAL_GPIO_SET_INPUT(X_LIMIT_PORT, 1UL << X_LIMIT_PIN);
  HAL_GPIO_SET_INPUT(Y_LIMIT_PORT, 1UL << Y_LIMIT_PIN);
  HAL_GPIO_SET_INPUT(Z_LIMIT_PORT, 1UL << Z_LIMIT_PIN);

  // Configure control pins as inputs
  HAL_GPIO_SET_INPUT(CONTROL_RESET_PORT, 1UL << CONTROL_RESET_PIN);
  HAL_GPIO_SET_INPUT(CONTROL_FEED_HOLD_PORT, 1UL << CONTROL_FEED_HOLD_PIN);
  HAL_GPIO_SET_INPUT(CONTROL_CYCLE_START_PORT, 1UL << CONTROL_CYCLE_START_PIN);
  HAL_GPIO_SET_INPUT(CONTROL_SAFETY_DOOR_PORT, 1UL << CONTROL_SAFETY_DOOR_PIN);

  // Configure spindle pins as outputs
  HAL_GPIO_SET_OUTPUT(SPINDLE_ENABLE_PORT, 1UL << SPINDLE_ENABLE_PIN);
  HAL_GPIO_SET_OUTPUT(SPINDLE_DIRECTION_PORT, 1UL << SPINDLE_DIRECTION_PIN);

  // Configure coolant pins as outputs
  HAL_GPIO_SET_OUTPUT(COOLANT_FLOOD_PORT, 1UL << COOLANT_FLOOD_PIN);
  HAL_GPIO_SET_OUTPUT(COOLANT_MIST_PORT, 1UL << COOLANT_MIST_PIN);

  // Configure probe pin as input
  HAL_GPIO_SET_INPUT(PROBE_PORT, 1UL << PROBE_PIN);
}

// SERIAL (UART) FUNCTIONS

void hal_serial_init(uint32_t baud_rate) {
  // Calculate divisor for baud rate
  // UART clock from SG2002 configuration
  uint32_t divisor = SG2002_UART_CLK / (16 * baud_rate);

  // Enable divisor latch access
  HAL_SERIAL_UART->LCR = UART_LCR_DLAB;

  // Set divisor
  HAL_SERIAL_UART->RBR_THR_DLL = divisor & 0xFF;
  HAL_SERIAL_UART->DLH_IER = (divisor >> 8) & 0xFF;

  // Configure: 8N1 (8 data bits, no parity, 1 stop bit)
  HAL_SERIAL_UART->LCR = UART_LCR_WLS_8;

  // Enable RX interrupt
  HAL_SERIAL_UART->DLH_IER = UART_IER_ERBFI;
}

// TIMER FUNCTIONS (Stepper interrupt)

void hal_timer_stepper_init(void) {
  // Disable timer
  HAL_TIMER_STEPPER->CONTROL = 0;

  // Set initial period (will be updated by planner)
  HAL_TIMER_STEPPER->LOAD_COUNT = 10000;

  // Configure: user-defined mode, interrupt enabled
  HAL_TIMER_STEPPER->CONTROL = TIMER_CTRL_MODE_USER;
}

void hal_timer_stepper_start(void) {
  HAL_TIMER_STEPPER->CONTROL |= TIMER_CTRL_ENABLE;
}

void hal_timer_stepper_stop(void) {
  HAL_TIMER_STEPPER->CONTROL &= ~TIMER_CTRL_ENABLE;
}

void hal_timer_stepper_set_period(uint32_t ticks) {
  HAL_TIMER_STEPPER->LOAD_COUNT = ticks;
}

uint32_t hal_timer_stepper_get_count(void) {
  return HAL_TIMER_STEPPER->CURRENT_VALUE;
}

// DELAY FUNCTIONS

void hal_delay_ms(uint32_t ms) {
  // Simple busy-wait delay (should be replaced with timer-based delay)
  volatile uint32_t count = ms * (F_CPU / 1000 / 4);
  while (count--) {
    __asm__ volatile ("nop");
  }
}

void hal_delay_us(uint32_t us) {
  volatile uint32_t count = us * (F_CPU / 1000000 / 4);
  while (count--) {
    __asm__ volatile ("nop");
  }
}

// NVMEM FUNCTIONS (Simple RAM-based implementation for now)

static uint8_t nvmem_buffer[HAL_NVMEM_SIZE];

void hal_nvmem_init(void) {
  // Initialize NVMEM buffer (could load from flash in production)
  for (uint32_t i = 0; i < HAL_NVMEM_SIZE; i++) {
    nvmem_buffer[i] = 0xFF;
  }
}

uint8_t hal_nvmem_read_byte(uint32_t addr) {
  if (addr >= HAL_NVMEM_SIZE) return 0xFF;
  return nvmem_buffer[addr];
}

void hal_nvmem_write_byte(uint32_t addr, uint8_t data) {
  if (addr < HAL_NVMEM_SIZE) {
    nvmem_buffer[addr] = data;
  }
}

// SYSTEM RESET

void hal_system_reset(void) {
  // Trigger software reset via WDT or system control register
  // For now, just disable interrupts and loop
  disable_interrupts();
  while (1) {
    __asm__ volatile ("wfi");  // Wait for interrupt
  }
}

// PLIC (Platform-Level Interrupt Controller) FUNCTIONS

static void hal_plic_init(void) {
  volatile uint32_t *plic_priority = (volatile uint32_t*)PLIC_PRIORITY_BASE;
  volatile uint32_t *plic_enable = (volatile uint32_t*)PLIC_ENABLE_BASE;
  volatile uint32_t *plic_threshold = (volatile uint32_t*)PLIC_THRESHOLD_BASE;

  // Set interrupt priorities (1-7, 0=disabled)
  plic_priority[IRQ_UART0] = 5;
  plic_priority[IRQ_TIMER0] = 7;  // Highest priority for stepper timer
  plic_priority[IRQ_GPIO0] = 4;
  plic_priority[IRQ_GPIO1] = 4;

  // Enable interrupts in PLIC
  // Enable bits are organized in 32-bit words
  plic_enable[IRQ_UART0 / 32] |= (1 << (IRQ_UART0 % 32));
  plic_enable[IRQ_TIMER0 / 32] |= (1 << (IRQ_TIMER0 % 32));
  plic_enable[IRQ_GPIO0 / 32] |= (1 << (IRQ_GPIO0 % 32));
  plic_enable[IRQ_GPIO1 / 32] |= (1 << (IRQ_GPIO1 % 32));

  // Set priority threshold to 0 (allow all priorities)
  *plic_threshold = 0;
}

// PLATFORM INITIALIZATION

void hal_platform_init(void) {
  // Initialize GPIO
  hal_gpio_init();

  // Initialize NVMEM
  hal_nvmem_init();

  // Initialize PLIC (Platform-Level Interrupt Controller)
  hal_plic_init();

  // Enable machine external interrupts (for PLIC)
  set_csr(mie, MIE_MEIE);

  // Enable global interrupts
  enable_interrupts();
}
