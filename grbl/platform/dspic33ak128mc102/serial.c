/*
  serial.c - dsPIC33AK128MC102 serial port driver (TU-replacement route)
  Part of Grbl

  PORTING-CHECKLIST Step 4, CONTRACTS.md #7. This is the NEWER dsPIC33A
  UART peripheral - register names are U1CON/U1STAT/U1BRG/U1RXB/U1TXB
  (p33AK128MC102.h), NOT the classic UxMODE/UxSTA/UxTXREG/UxRXREG shape
  used on 16-bit dsPIC33F/E - a fresh register set was mined this session,
  not reused from any donor port (there is no donor: this is the third
  ISA family and the first UART for it).

  Ring-buffer bookkeeping (head/tail math, the BUG #12 ordering
  discipline) is chip-agnostic and unchanged from the M1-M3 skeleton
  (itself lifted from the proven samd21/serial.c pattern); only the
  UART1 register touches below are new.

  REALTIME INTERCEPTION (BUG #19): the dispatch switch below is
  UNCHANGED from the M1-M3 skeleton, which already mirrors core
  grbl/serial.c's HAL_SERIAL_RX_ISR() (serial.c:137-188) verbatim,
  case-for-case - re-verified line-by-line this session. Do not "clean
  this up" - the exact case list, ordering and #ifdef guards (DEBUG,
  ENABLE_M7) are the contract.

  BAUD (BUG #4 class): U1BRG is a 20-bit register (not the classic 16-bit
  UxBRG) with a BRGS "high speed" mode bit (/4 divisor vs /16 - assumed
  meaning, U_CON__BRGS atdf value-group only names enabled/disabled, not
  the divisor arithmetic itself - RM-only). BRGS=1 (/4) is used for finer
  granularity at high Fp. Formula: BRG = round(Fp/(4*baud)) - 1. Fp
  (UART1's peripheral clock) is ASSUMED == F_CPU (platform.h, UNVERIFIED -
  CONTRACTS.md #16.10); at F_CPU=200MHz/115200 baud this gives BRG=433,
  actual baud 115207.4 (+0.006%) - the arithmetic is sound, the Fp
  assumption is the open hardware-bring-up risk.

  PPS: U1RX input mux (RPINR9.U1RXR) IS fully verified - the field is
  literally the source RPn's own pin number (standard PPS input-mux
  convention). U1TX output mux (RPOR12.RP52R) uses an UNVERIFIED
  function-select code (platform.h PPS_RPOR_FN_U1TX_UNVERIFIED) - no
  value-group for any RPORx field exists in the vendored .atdf.
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

// Pure ring-buffer math below - no hardware access. Preserve the "read
// index once into a local" pattern (core serial.c:96-108).

uint8_t serial_read(void) {
  uint8_t tail = rx_buffer_tail;

  if (rx_buffer_head == tail) {
    return SERIAL_NO_DATA;
  }
  uint8_t data = rx_buffer[tail];
  tail++;
  if (tail == RX_RING_BUFFER) { tail = 0; }
  rx_buffer_tail = tail;
  return data;
}

void serial_reset_read_buffer(void) {
  rx_buffer_tail = rx_buffer_head;
}

uint8_t serial_get_rx_buffer_available(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) {
    return (RX_BUFFER_SIZE - (head - tail));
  }
  return (tail - head - 1);
}

uint8_t serial_get_rx_buffer_count(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) { return (head - tail); }
  return (RX_RING_BUFFER - (tail - head));
}

uint8_t serial_get_tx_buffer_count(void) {
  uint8_t head = tx_buffer_head;
  uint8_t tail = tx_buffer_tail;

  if (head >= tail) { return (head - tail); }
  return (TX_RING_BUFFER - (tail - head));
}

// ============================================================================
// UART INTERRUPT DISPATCH (called from _U1RXInterrupt/_U1TXInterrupt in
// handlers.c - real vectors, synthesized IVT; see platform.c banner)
// ============================================================================
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
