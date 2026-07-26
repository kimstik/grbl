/*
  serial.c - CH570 serial port driver (TU-replacement route)
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../../grbl.h"   // realtime CMD_* bytes, sys, mc_reset(), exec-flag setters (BUG #19)
#include "../../serial.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

// BUG #12 class: head/tail below are
// uint8_t and wrap via plain `+1` - correct only if RX/TX_RING_BUFFER fit
// that index type.
_Static_assert(RX_BUFFER_SIZE <= 255 && TX_BUFFER_SIZE <= 255,
               "RX_BUFFER_SIZE/TX_BUFFER_SIZE must fit the uint8_t ring index (BUG #12 class)");

static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

void serial_init(void) {
  // TX pin idle-high before enabling the output driver (avoids a
  // glitch on the line) - vendor SDK's own UART example does the same
  // (GPIOA_SetBits(bTXD_0) before UART_DefInit()).
  R32_PA_SET = (1UL << SERIAL_TX_PIN);
  R32_PA_DIR |= (1UL << SERIAL_TX_PIN);          // TX: output
  R32_PA_DIR &= ~(1UL << SERIAL_RX_PIN);         // RX: input
  R32_PA_PD_DRV &= ~(1UL << SERIAL_RX_PIN);
  R32_PA_PU     |= (1UL << SERIAL_RX_PIN);       // idle-high pull-up (open cable safety)

  // Default pin-alternate mapping (remap code 0 = TX/PA3, RX/PA2) -
  // still must be explicitly written: R16_PIN_ALTERNATE_H is NOT
  // necessarily 0 out of every reset path (sleep/wake, per the vendor's
  // own UART_Remap() comment - "so it resets to 0 on ShutDown sleep").
  R16_PIN_ALTERNATE_H &= (uint16_t)~(RB_UART_TXD | RB_UART_RXD);

  // Baud (16550-shape, /8 oversampling on this chip, NOT the classic /16 -
  // vendor UART_BaudRateCfg() confirms: DL = round(Fsys / 8 / baud), with
  // the pre-divisor DIV fixed at 1). Same rounding trick as ch32v006/f103:
  // integer round-to-nearest via a +half-divisor bias.
  {
    uint32_t dl = (F_CPU + (4u * BAUD_RATE)) / (8u * BAUD_RATE);
    UART1->DLL = (uint8_t)(dl & 0xFFu);
    UART1->DLM = (uint8_t)((dl >> 8) & 0xFFu);
    UART1->DIV = 1;
  }

  UART1->FCR = RB_FCR_FIFO_TRIG_1B | RB_FCR_FIFO_EN;   // 1-byte trigger, FIFO on
  UART1->LCR = RB_LCR_WORD_SZ_8;                        // 8N1
  UART1->IER = RB_IER_TXD_EN | RB_IER_RECV_RDY;         // TX driver on, RX-ready IRQ on;
                                                          // THR-empty IRQ stays off until
                                                          // there is data to send (contract).

  PFIC_EnableIRQ(UART_IRQn);
}

void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Wait for space; keep the drain interrupt enabled while spinning.
  while (next_head == tx_buffer_tail) {
    UART1->IER |= 0x02;   // RB_IER_THR_EMPTY
  }

  // BUG #12 bracket: mask the consuming interrupt around the data-store +
  // head-publish pair.
  UART1->IER &= (uint8_t)~0x02;

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  UART1->IER |= 0x02;
}

// The five chip-agnostic ring-buffer accessors core GRBL calls
// (serial_read / serial_reset_read_buffer / serial_get_rx_buffer_available
// / serial_get_rx_buffer_count / serial_get_tx_buffer_count) are shared
// verbatim with every other TU-replacement port. Included HERE, after the
// buffers above, because it is their definitions it operates on; see that
// header for what it requires and why it is a header at all.
#include "../common/serial_ring_accessors.h"

// UART INTERRUPT DISPATCH - called from UART1's PFIC vector (handlers.c).
// RBR read clears DATA_RDY; THR write clears TX_FIFO_EMP (16550 shape) -
// flag hygiene is inherent in servicing, nothing to pre-clear here.
void serial_irq_dispatch(void) {
  while (UART1->LSR & RB_LSR_DATA_RDY) {
    uint8_t data = UART1->RBR_THR;

    // Pick off realtime command characters directly from the serial
    // stream. Mirrors core grbl/serial.c HAL_SERIAL_RX_ISR() verbatim
    // (BUG #19, contract #7).
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

  // THR-empty only matters while the drain interrupt is armed - checking
  // IER too keeps a stray "always empty when idle" reading from
  // ghost-draining.
  if ((UART1->IER & 0x02) && (UART1->LSR & RB_LSR_TX_FIFO_EMP)) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      UART1->RBR_THR = tx_buffer[tail];
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      UART1->IER &= (uint8_t)~0x02;   // buffer drained: self-disable
    }
  }
}
