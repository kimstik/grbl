/*
  serial.c - dsPIC33AK128MC102 serial port driver (M1-M3: hardware = PORT_TODO)
  Part of Grbl

  TU-replacement route (CONTRACTS.md #0/#7): this file provides the whole
  grbl/serial.h API instead of core grbl/serial.c. Ring-buffer bookkeeping
  (head/tail math, the BUG #12 ordering discipline) is chip-agnostic and
  reused from _template/serial.c (itself lifted from the proven
  samd21/serial.c); only the UART1 register touches are PORT_TODO_SERIAL_*
  (Step 4: U1BRG divisor verified at 115200 per BUG #4, U1RXB/U1TXB data
  regs, UxSTAT flag model - all against the RM, not by F1/AVR analogy).

  REALTIME INTERCEPTION (BUG #19, the samd21 lesson): the RX path below
  routes every byte through the SAME dispatch structure core serial.c
  uses - Step 4's PORT_TODO_SERIAL_RX_READ fill-in must keep the
  realtime-command switch (?/!/~/ctrl-X/overrides) MIRRORING core
  serial.c:127-145 verbatim. The skeleton already contains it so the
  fill-in cannot forget it.
*/

#include <stdint.h>
#include "platform.h"
#include "../../serial.h"
#include "../../grbl.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

// CONTRACTS.md #7: UART at BAUD_RATE, 8N1, RX interrupt enabled, TX
// interrupt disabled. Context: init.
void serial_init(void) {
  PORT_TODO_SERIAL_HW_INIT();
}

void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Block while full, keeping the TX-empty interrupt armed so the ISR can
  // drain the buffer and make room.
  while (next_head == tx_buffer_tail) {
    PORT_TODO_SERIAL_TX_INT_ENABLE();
  }

  // BUG #12 discipline: bracket the data-store + head-publish pair by
  // masking the consuming interrupt (#12.1). On this single-core in-order
  // chip the bracket also covers the compiler (see platform.h __DMB note).
  PORT_TODO_SERIAL_TX_INT_DISABLE();

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  PORT_TODO_SERIAL_TX_INT_ENABLE();
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
// status polling and dead feed-hold/reset - safety-relevant).
void serial_irq_dispatch(void) {
  if (PORT_TODO_SERIAL_RX_PENDING()) {
    uint8_t data = PORT_TODO_SERIAL_RX_READ();

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

  if (PORT_TODO_SERIAL_TX_READY()) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      PORT_TODO_SERIAL_TX_WRITE(tx_buffer[tail]);
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      // Buffer empty - self-disable so the TX-empty condition doesn't
      // re-fire forever (#7, PORTING-CHECKLIST Step 4).
      PORT_TODO_SERIAL_TX_INT_DISABLE();
    }
  }
}
