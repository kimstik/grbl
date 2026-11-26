/* Timer1 CTC fidelity fixture, not Grbl: prescaler 1, START_TOP then NEXT_TOP from the ISR. */
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

volatile uint8_t hits, flagged;

ISR(TIMER1_COMPA_vect)
{
  OCR1A = NEXT_TOP;
  if (++hits == 4) { TIMSK1 = 0; }
}

int main(void)
{
  TCCR1A = 0;
  OCR1A = START_TOP;
  TCCR1B = (1<<WGM12) | (1<<CS10);
#ifdef POLL
  /* Masked compare must still set OCF1A, and set it again after a write-one clear. */
  while (!(TIFR1 & (1<<OCF1A))) {}
  TIFR1 = 1<<OCF1A;
  flagged = 1;
  while (!(TIFR1 & (1<<OCF1A))) {}
  flagged = 2;
#endif
  TIMSK1 = 1<<OCIE1A;
  sei();
  while (hits < 4) {}
  cli();
  sleep_cpu(); /* simavr stops here: sleep with interrupts disabled */
  for (;;) {}
}
