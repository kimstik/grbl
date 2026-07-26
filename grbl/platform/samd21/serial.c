/*
  serial.c - SAMD21 serial port driver
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted

  SERCOM3 UART at 115200 baud (PA23=RX/PAD1, PA24=TX/PAD2)
  Interrupt-driven RX/TX with ring buffers
*/

#include <stdint.h>
#include "samd21.h"
#include "platform.h"
#include "../../grbl.h"   // realtime CMD_* bytes, sys, mc_reset(), exec-flag setters (BUG #19)
#include "../../serial.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

// PLAN.md Phase 2 static-assert sweep (2026-07-26), BUG #12 class: head/tail
// below are uint8_t and wrap via plain `+1` (no explicit mod) - the ring
// arithmetic is only correct if RX/TX_RING_BUFFER (SIZE+1) fits in that
// index type, i.e. SIZE <= 255. grbl/config.h's own commented-out override
// already says "(1-254)"; this makes the same limit a build-time fact
// instead of only a comment a board's config.h could silently violate.
_Static_assert(RX_BUFFER_SIZE <= 255 && TX_BUFFER_SIZE <= 255,
               "RX_BUFFER_SIZE/TX_BUFFER_SIZE must fit the uint8_t ring index (BUG #12 class)");

// Ring buffers for RX and TX
static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

void serial_init() {
  // Enable SERCOM3 clock
  PM->APBCMASK |= PM_APBCMASK_SERCOM3;

  // Configure GCLK for SERCOM3 (use GCLK0 = 48MHz)
  GCLK->CLKCTRL = (GCLK_CLKCTRL_ID_SERCOM3_CORE << GCLK_CLKCTRL_ID_Pos) |
                  GCLK_CLKCTRL_GEN_GCLK0 |
                  GCLK_CLKCTRL_CLKEN;
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Configure PA23 (RX/PAD1) and PA24 (TX/PAD2) for SERCOM3 (Function C = 0x2)
  PORT->Group[PORT_GROUPA].PINCFG[23] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PINCFG[24] = PORT_PINCFG_PMUXEN;

  // PA23 is odd (uses upper nibble of PMUX[11])
  // PA24 is even (uses lower nibble of PMUX[12])
  PORT->Group[PORT_GROUPA].PMUX[23 >> 1] = (PORT->Group[PORT_GROUPA].PMUX[23 >> 1] & 0x0F) | (0x2 << 4);
  PORT->Group[PORT_GROUPA].PMUX[24 >> 1] = (PORT->Group[PORT_GROUPA].PMUX[24 >> 1] & 0xF0) | 0x2;

  // Reset SERCOM3
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_SWRST;
  while (SERCOM3->CTRLA & SERCOM_USART_CTRLA_SWRST);
  while (SERCOM3->SYNCBUSY);

  // Configure SERCOM3 as USART with internal clock
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_MODE_USART_INT_CLK |
                   SERCOM_USART_CTRLA_RXPO_PAD1 |         // RX on PAD1 (PA23)
                   (0x1 << SERCOM_USART_CTRLA_TXPO_Pos) | // TX on PAD2 (PA24) - TXPO=1 means PAD2
                   SERCOM_USART_CTRLA_DORD;               // LSB first

  // Configure 8N1, enable TX and RX
  SERCOM3->CTRLB = SERCOM_USART_CTRLB_CHSIZE_8BIT |
                   SERCOM_USART_CTRLB_TXEN |
                   SERCOM_USART_CTRLB_RXEN;
  while (SERCOM3->SYNCBUSY);

  // Calculate baud rate for 115200 @ 48MHz (arithmetic mode)
  // Formula: baud = f_ref / (S * (BAUD + 1)), where S = 16
  // Solving: BAUD = (f_ref / (S * f_baud)) - 1
  // BAUD = (48000000 / (16 * 115200)) - 1 = 26.04 - 1 = 25
  uint16_t baud_value = (48000000UL / (16 * 115200)) - 1;  // = 25
  SERCOM3->BAUD = baud_value;

  // Enable RX Complete interrupt
  SERCOM3->INTENSET = SERCOM_USART_INTFLAG_RXC;

  // Enable SERCOM3 interrupt in NVIC
  NVIC_EnableIRQ(SERCOM3_IRQn);

  // Enable SERCOM3
  SERCOM3->CTRLA |= SERCOM_USART_CTRLA_ENABLE;
  while (SERCOM3->SYNCBUSY);
}

void serial_write(uint8_t data) {
  // Calculate next head position
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Wait if buffer is full
  while (next_head == tx_buffer_tail) {
    // Enable TX interrupt to drain buffer
    if (!(SERCOM3->INTENSET & SERCOM_USART_INTFLAG_DRE)) {
      SERCOM3->INTENSET = SERCOM_USART_INTFLAG_DRE;
    }
  }

  // CRITICAL SECTION: Prevent race with ISR (BUG #12 fix)
  // Disable DRE interrupt during buffer update to ensure atomic operation
  // Without this, CPU could reorder: head update before buffer write!
  SERCOM3->INTENCLR = SERCOM_USART_INTFLAG_DRE;

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  // Re-enable TX Data Register Empty interrupt
  SERCOM3->INTENSET = SERCOM_USART_INTFLAG_DRE;
}

// The five chip-agnostic ring-buffer accessors core GRBL calls
// (serial_read / serial_reset_read_buffer / serial_get_rx_buffer_available
// / serial_get_rx_buffer_count / serial_get_tx_buffer_count) are shared
// verbatim with every other TU-replacement port. This port originally
// wrote the identical logic with if/else instead of early return and K&R
// empty parens; the shared copy is the early-return/(void) form, and both
// samd21 boards were proven byte-identical across the swap. Included HERE,
// after the buffers above, because it is their definitions it operates on.
#include "../common/serial_ring_accessors.h"

// SERCOM3 interrupt handler
void SERCOM3_Handler(void) {
  uint8_t intflag = SERCOM3->INTFLAG;

  // RX Complete - data received
  if (intflag & SERCOM_USART_INTFLAG_RXC) {
    uint8_t data = SERCOM3->DATA;
    uint8_t next_head;

    // Pick off realtime command characters directly from the serial stream. These characters are
    // not passed into the main buffer, but these set system state flag bits for realtime execution.
    // Mirrors core grbl/serial.c HAL_SERIAL_RX_ISR() verbatim (BUG #19: without this interception
    // '?'/'!'/'~'/ctrl-X and every extended-ASCII override byte fell into the line buffer and were
    // parsed - and rejected - as g-code, so no status reports, no feed hold, no reset).
    switch (data) {
      case CMD_RESET:         mc_reset(); break; // Call motion control reset routine.
      case CMD_STATUS_REPORT: system_set_exec_state_flag(EXEC_STATUS_REPORT); break; // Set as true
      case CMD_CYCLE_START:   system_set_exec_state_flag(EXEC_CYCLE_START); break; // Set as true
      case CMD_FEED_HOLD:     system_set_exec_state_flag(EXEC_FEED_HOLD); break; // Set as true
      default :
        if (data > 0x7F) { // Real-time control characters are extended ACSII only.
          switch(data) {
            case CMD_SAFETY_DOOR:   system_set_exec_state_flag(EXEC_SAFETY_DOOR); break; // Set as true
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
          // Throw away any unfound extended-ASCII character by not passing it to the serial buffer.
        } else { // Write character to buffer
          next_head = rx_buffer_head + 1;
          if (next_head == RX_RING_BUFFER) { next_head = 0; }

          // Store data if buffer not full
          if (next_head != rx_buffer_tail) {
            rx_buffer[rx_buffer_head] = data;
            __DMB();  // Memory barrier - ensure buffer write completes before head update (BUG #12 fix)
            rx_buffer_head = next_head;
          }
        }
    }
  }

  // Data Register Empty - ready to transmit
  if (intflag & SERCOM_USART_INTFLAG_DRE) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      // Send next byte
      SERCOM3->DATA = tx_buffer[tail];
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      // Buffer empty - disable TX interrupt
      SERCOM3->INTENCLR = SERCOM_USART_INTFLAG_DRE;
    }
  }
}
