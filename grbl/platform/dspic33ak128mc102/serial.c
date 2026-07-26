/*
  serial.c - dsPIC33AK128MC102 serial port driver (TU-replacement route)
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../../serial.h"
#include "../../grbl.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

// PLAN.md Phase 2 static-assert sweep (2026-07-26), BUG #12 class: head/tail
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

// CONTRACTS.md #7: UART at BAUD_RATE, 8N1, RX interrupt enabled, TX
// interrupt disabled. Context: init.
void serial_init(void) {
  // PPS: RA4 = RP5 -> U1RX (VERIFIED: input-mux field is the RPn number
  // itself). RD3 = RP52 -> U1TX (UNVERIFIED output function code).
  RPINR9bits.U1RXR = 5;
  RPOR12bits.RP52R = PPS_RPOR_FN_U1TX_UNVERIFIED;

  U1CON = 0;                      // module off while configuring
  U1CONbits.BRGS = 1;             // high-speed (/4) baud divisor mode
  U1BRG = (uint32_t)((F_CPU + (2UL * BAUD_RATE)) / (4UL * BAUD_RATE) - 1UL);
  U1CONbits.MODE = 0x0;           // 8N1, no address detect (U_CON__MODE OPTION_9, atdf-verified)
  U1CONbits.RXEN = 1;
  U1CONbits.TXEN = 1;

  _U1RXIF = 0;
  _U1TXIF = 0;
  _U1RXIE = 1;                    // RX interrupt enabled
  _U1TXIE = 0;                    // TX interrupt OFF until there is data to send (contract)
  _U1RXIP = 3;
  _U1TXIP = 3;

  U1CONbits.ON = 1;
}

void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Block while full, keeping the TX-empty interrupt armed so the ISR can
  // drain the buffer and make room.
  while (next_head == tx_buffer_tail) {
    _U1TXIE = 1;
  }

  // BUG #12 discipline: bracket the data-store + head-publish pair by
  // masking the consuming interrupt (#12.1). On this single-core in-order
  // chip the bracket also covers the compiler (see platform.h __DMB note).
  _U1TXIE = 0;

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  _U1TXIE = 1;
}

// Pure ring-buffer math below - no hardware access. The five accessors
// core GRBL calls (serial_read / serial_reset_read_buffer /
// serial_get_rx_buffer_available / serial_get_rx_buffer_count /
// serial_get_tx_buffer_count) are shared verbatim with every other
// TU-replacement port. Included HERE, after the buffers above, because it
// is their definitions it operates on; see that header for what it
// requires and why the "read index once into a local" pattern (core
// serial.c:96-108) must be preserved.
#include "../common/serial_ring_accessors.h"

// UART INTERRUPT DISPATCH (called from _U1RXInterrupt/_U1TXInterrupt in
// handlers.c - real vectors, synthesized IVT; see platform.c banner)
// REALTIME-COMMAND INTERCEPTION mirrors core serial.c:127-145 verbatim
// (BUG #19: a port whose RX ISR buffers these bytes as data has dead
// status polling and dead feed-hold/reset - safety-relevant). U1STAT.RXBF
// (RX buffer full) tells us data is present; U1RXB is the data register
// (reading it is expected to clear RXBF, standard UART shape). U1STAT.TXBE
// (TX buffer empty) tells us we may push another byte into U1TXB.
void serial_irq_dispatch(void) {
  if (U1STATbits.RXBF) {
    uint8_t data = (uint8_t)U1RXB;

    switch (data) {
      case CMD_RESET:         mc_reset(); break; // Call motion control reset routine.
      case CMD_STATUS_REPORT: system_set_exec_state_flag(EXEC_STATUS_REPORT); break;
      case CMD_CYCLE_START:   system_set_exec_state_flag(EXEC_CYCLE_START); break;
      case CMD_FEED_HOLD:     system_set_exec_state_flag(EXEC_FEED_HOLD); break;
      default :
        if (data > 0x7F) { // Real-time control characters are extended ACSII only.
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
          // Throw away any unfound extended-ASCII character by not passing it to the serial buffer.
        } else { // Everything else is gcode. Insert into buffer.
          uint8_t next_head = rx_buffer_head + 1;
          if (next_head == RX_RING_BUFFER) { next_head = 0; }

          if (next_head != rx_buffer_tail) {
            rx_buffer[rx_buffer_head] = data;
            // BUG #12: data store must be ordered before the head publish
            // (compiler barrier on this single-core chip - platform.h).
            __DMB();
            rx_buffer_head = next_head;
          }
        }
    }
  }

  if (U1STATbits.TXBE && _U1TXIE) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      U1TXB = tx_buffer[tail];
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      // Buffer empty - self-disable so the TX-empty condition doesn't
      // re-fire forever (#7, PORTING-CHECKLIST Step 4).
      _U1TXIE = 0;
    }
  }
}
