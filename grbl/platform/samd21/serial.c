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
#include "../../serial.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

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

uint8_t serial_read() {
  uint8_t tail = rx_buffer_tail;

  if (rx_buffer_head == tail) {
    return SERIAL_NO_DATA;
  } else {
    uint8_t data = rx_buffer[tail];
    tail++;
    if (tail == RX_RING_BUFFER) { tail = 0; }
    rx_buffer_tail = tail;
    return data;
  }
}

void serial_reset_read_buffer() {
  rx_buffer_tail = rx_buffer_head;
}

uint8_t serial_get_rx_buffer_available() {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) {
    return (RX_BUFFER_SIZE - (head - tail));
  } else {
    return ((tail - head - 1));
  }
}

uint8_t serial_get_rx_buffer_count() {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) {
    return (head - tail);
  } else {
    return (RX_RING_BUFFER - (tail - head));
  }
}

uint8_t serial_get_tx_buffer_count() {
  uint8_t head = tx_buffer_head;
  uint8_t tail = tx_buffer_tail;

  if (head >= tail) {
    return (head - tail);
  } else {
    return (TX_RING_BUFFER - (tail - head));
  }
}

// SERCOM3 interrupt handler
void SERCOM3_Handler(void) {
  uint8_t intflag = SERCOM3->INTFLAG;

  // RX Complete - data received
  if (intflag & SERCOM_USART_INTFLAG_RXC) {
    uint8_t data = SERCOM3->DATA;
    uint8_t next_head = rx_buffer_head + 1;
    if (next_head == RX_RING_BUFFER) { next_head = 0; }

    // Store data if buffer not full
    if (next_head != rx_buffer_tail) {
      rx_buffer[rx_buffer_head] = data;
      __DMB();  // Memory barrier - ensure buffer write completes before head update (BUG #12 fix)
      rx_buffer_head = next_head;
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
