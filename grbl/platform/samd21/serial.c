#include "serial.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

void    serial_init()	{}
void    serial_write(uint8_t data) {}
uint8_t serial_read() {}
void 	serial_reset_read_buffer() {}


void serial_init(uint32_t baudrate) {
  // Initialize SERCOM3 for UART (PA23=RX/PAD1, PA24=TX/PAD2)

  // Enable SERCOM3 clock
  PM->APBCMASK |= PM_APBCMASK_SERCOM3;

  // Configure GCLK for SERCOM3
  GCLK->CLKCTRL = GCLK_CLKCTRL_ID_SERCOM3_CORE |
                  GCLK_CLKCTRL_CLKEN |
                  (0 << GCLK_CLKCTRL_GEN_Pos);  // Use GCLK0 (48MHz)
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Configure PA23 (RX) and PA24 (TX) for SERCOM3
  PORT->Group[PORT_GROUPA].PINCFG[23] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PINCFG[24] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PMUX[23 >> 1] = (0x2 << 4) | 0x2;  // Function C for both

  // Reset SERCOM3
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_SWRST;
  while (SERCOM3->CTRLA & SERCOM_USART_CTRLA_SWRST);

  // Configure SERCOM3 as USART with internal clock
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_MODE_USART_INT_CLK |
                   SERCOM_USART_CTRLA_RXPO_PAD1 |   // RX on PAD1
                   (2 << SERCOM_USART_CTRLA_TXPO_Pos) |  // TX on PAD2
                   SERCOM_USART_CTRLA_DORD;         // LSB first

  // Configure 8N1
  SERCOM3->CTRLB = SERCOM_USART_CTRLB_CHSIZE_8BIT |
                   SERCOM_USART_CTRLB_TXEN |
                   SERCOM_USART_CTRLB_RXEN;
  while (SERCOM3->SYNCBUSY);

  // Calculate baud rate: BAUD = 65536 * (1 - 16 * (f_baud / f_ref))
  // For 115200 @ 48MHz: BAUD = 65536 * (1 - 16 * (115200 / 48000000)) = 63019
  uint16_t baud_value = 65536 - ((65536 * 16.0f * baudrate) / CPU_FREQ);
  SERCOM3->BAUD = baud_value;

  // Enable SERCOM3
  SERCOM3->CTRLA |= SERCOM_USART_CTRLA_ENABLE;
  while (SERCOM3->SYNCBUSY);
}

void serial_write(uint8_t data) {
  // Write byte to UART
  while (!(SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_DRE));
  SERCOM3->DATA = data;
}

uint8_t serial_read(void) {
  // Read byte from UART
  while (!(SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_RXC));
  return (uint8_t)SERCOM3->DATA;
}

uint8_t serial_available(void) {
  // Check if data available
  return (SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_RXC) ? 1 : 0;
}

void serial_tx_interrupt_enable(void) {
  // Enable TX interrupt
  SERCOM3->INTENSET = SERCOM_USART_INTFLAG_DRE;
}

void serial_tx_interrupt_disable(void) {
  // Disable TX interrupt
  SERCOM3->INTENCLR = SERCOM_USART_INTFLAG_DRE;
}

