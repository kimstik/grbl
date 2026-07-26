/*
  serial.c - CH32V006 serial port driver (TU-replacement route)
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../../grbl.h"   // realtime CMD_* bytes, sys, mc_reset(), exec-flag setters (BUG #19)
#include "../../serial.h"

// CONTRACTS.md #19 "guard that certifies instead of checking" (wrong-phase
// variant - grbl/CONTRACTS.md gap log): STEP_PULSE_DELAY is genuinely
// unsupported on this chip (see ../../timer.h for the hardware reason),
// but the natural place to say so - an `#ifdef`/`#error` in timer.h - is
// reached through the build prelude, BEFORE grbl.h's own #include
// "config.h" ever defines the macro. A guard there can never fire. This
// file's #include "../../grbl.h" above is the first REAL processing of
// core config.h in this translation unit, so the check is placed here
// instead, where it actually works.
#ifdef STEP_PULSE_DELAY
#error "STEP_PULSE_DELAY is not supported on CH32V006 (single-compare STK pulse timer; TIM3 has no interrupt - see timer.h)"
#endif

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

// BUG #12 class: head/tail
// below are uint8_t and wrap via plain `+1` (no explicit mod) - correct
// only if RX/TX_RING_BUFFER (SIZE+1) fits that index type, i.e. SIZE <= 255.
_Static_assert(RX_BUFFER_SIZE <= 255 && TX_BUFFER_SIZE <= 255,
               "RX_BUFFER_SIZE/TX_BUFFER_SIZE must fit the uint8_t ring index (BUG #12 class)");

static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

void hal_gpio_config_pin(GPIO_TypeDef* port, uint8_t pin, uint32_t cfg4); // platform.c

void serial_init(void) {
  RCC->PB2PCENR |= RCC_PB2PCENR_USART1EN | RCC_PB2PCENR_AFIOEN;  // IOPDEN: hal_gpio_clock_init (BUG #24)

  // PD5 = TX: alternate-function push-pull. PD6 = RX: input with pull-up
  // (idle-high line; avoids garbage while the cable is unplugged).
  hal_gpio_config_pin(SERIAL_TX_PORT, SERIAL_TX_PIN, GPIO_CFG_OUT_AF_PP);
  hal_gpio_config_pin(SERIAL_RX_PORT, SERIAL_RX_PIN, GPIO_CFG_IN_PULL);
  SERIAL_RX_PORT->BSHR = (1UL << SERIAL_RX_PIN);   // ODR=1 -> pull-up

  // Baud (RM 14.3): baud = HCLK/(16*USARTDIV); BRR = mantissa[15:4] +
  // fraction[3:0]. Writing the ROUNDED integer divisor HCLK/baud directly
  // encodes mantissa+fraction in one go (same trick as f103). USART1 is
  // clocked at HCLK = F_CPU (HPRE cleared to /1 in SystemClock_Config).
  // At 115200/48MHz: (48000000+57600)/115200 = 417 = 26+1/16 -> actual
  // 115107.9 baud, -0.08% error (BUG #4 class check: within tolerance).
  USART1->BRR = (F_CPU + (BAUD_RATE / 2)) / BAUD_RATE;

  // 8N1, TX+RX on, RX interrupt on, TX (TXE) interrupt OFF until there is
  // data to send (contract #7 HAL_SERIAL_INIT semantics).
  USART1->CTLR1 = USART_CTLR1_TE | USART_CTLR1_RE | USART_CTLR1_RXNEIE;
  USART1->CTLR1 |= USART_CTLR1_UE;

  PFIC_EnableIRQ(USART1_IRQn);
}

void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Wait for space; keep the drain interrupt enabled while spinning.
  while (next_head == tx_buffer_tail) {
    USART1->CTLR1 |= USART_CTLR1_TXEIE;
  }

  // BUG #12 bracket: mask the consuming interrupt around the data-store +
  // head-publish pair (samd21/serial.c:96-105 pattern).
  USART1->CTLR1 &= ~USART_CTLR1_TXEIE;

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  USART1->CTLR1 |= USART_CTLR1_TXEIE;
}

// The five chip-agnostic ring-buffer accessors core GRBL calls
// (serial_read / serial_reset_read_buffer / serial_get_rx_buffer_available
// / serial_get_rx_buffer_count / serial_get_tx_buffer_count) are shared
// verbatim with every other TU-replacement port. Included HERE, after the
// buffers above, because it is their definitions it operates on; see that
// header for what it requires and why it is a header at all.
#include "../common/serial_ring_accessors.h"

// UART INTERRUPT DISPATCH - called from USART1's PFIC vector (handlers.c),
// which owns the __attribute__((interrupt)) frame. RXNE clears on DATAR
// read; TXE clears on DATAR write (RM 14.8.1/14.8.2) - flag hygiene is
// inherent in servicing, nothing to pre-clear here.
void serial_irq_dispatch(void) {
  if (USART1->STATR & USART_STATR_RXNE) {
    uint8_t data = (uint8_t)USART1->DATAR;

    // Pick off realtime command characters directly from the serial stream.
    // These are not passed into the main buffer; they set system state flag
    // bits for realtime execution. Mirrors core grbl/serial.c
    // HAL_SERIAL_RX_ISR() verbatim (BUG #19, contract #7).
    switch (data) {
      case CMD_RESET:         mc_reset(); break;
      case CMD_STATUS_REPORT: system_set_exec_state_flag(EXEC_STATUS_REPORT); break;
      case CMD_CYCLE_START:   system_set_exec_state_flag(EXEC_CYCLE_START); break;
      case CMD_FEED_HOLD:     system_set_exec_state_flag(EXEC_FEED_HOLD); break;
      default :
        if (data > 0x7F) { // Real-time control characters are extended ASCII only.
          switch(data) {
            case CMD_SAFETY_DOOR:   system_set_exec_state_flag(EXEC_SAFETY_DOOR); break;
            case CMD_JOG_CANCEL:
              if (sys.state & STATE_JOG) { // Block all other states from invoking motion cancel.
                system_set_exec_state_flag(EXEC_MOTION_CANCEL);
              }
              break;
            #ifdef DEBUG
              case CMD_DEBUG_REPORT: {
                HAL_CRITICAL_SECTION_BEGIN();
                bit_true(sys_rt_exec_debug,EXEC_DEBUG_REPORT);
                HAL_CRITICAL_SECTION_END();
              } break;
            #endif
            case CMD_FEED_OVR_RESET: system_set_exec_motion_override_flag(EXEC_FEED_OVR_RESET); break;
            case CMD_FEED_OVR_COARSE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_PLUS); break;
            case CMD_FEED_OVR_COARSE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_MINUS); break;
            case CMD_FEED_OVR_FINE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_PLUS); break;
            case CMD_FEED_OVR_FINE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_MINUS); break;
            case CMD_RAPID_OVR_RESET: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_RESET); break;
            case CMD_RAPID_OVR_MEDIUM: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_MEDIUM); break;
            case CMD_RAPID_OVR_LOW: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_LOW); break;
            case CMD_SPINDLE_OVR_RESET: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_RESET); break;
            case CMD_SPINDLE_OVR_COARSE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_PLUS); break;
            case CMD_SPINDLE_OVR_COARSE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_MINUS); break;
            case CMD_SPINDLE_OVR_FINE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_PLUS); break;
            case CMD_SPINDLE_OVR_FINE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_MINUS); break;
            case CMD_SPINDLE_OVR_STOP: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_STOP); break;
            case CMD_COOLANT_FLOOD_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_FLOOD_OVR_TOGGLE); break;
            #ifdef ENABLE_M7
              case CMD_COOLANT_MIST_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_MIST_OVR_TOGGLE); break;
            #endif
          }
          // Throw away any unfound extended-ASCII character.
        } else { // Write character to buffer
          uint8_t next_head = rx_buffer_head + 1;
          if (next_head == RX_RING_BUFFER) { next_head = 0; }

          if (next_head != rx_buffer_tail) {
            rx_buffer[rx_buffer_head] = data;
            __DMB();   // BUG #12: data store must land before head publish
            rx_buffer_head = next_head;
          }
        }
    }
  }

  // TXE only matters while the drain interrupt is armed - checking TXEIE
  // too keeps a stray TXE (always 1 when idle) from ghost-draining.
  if ((USART1->CTLR1 & USART_CTLR1_TXEIE) && (USART1->STATR & USART_STATR_TXE)) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      USART1->DATAR = tx_buffer[tail];
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      USART1->CTLR1 &= ~USART_CTLR1_TXEIE;   // buffer drained: self-disable
    }
  }
}
