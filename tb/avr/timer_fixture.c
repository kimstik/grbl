/* Timer1 CTC fidelity fixture, not Grbl: prescaler 1, START_TOP then NEXT_TOP from the ISR. */
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

volatile uint8_t hits, flagged;

ISR(TIMER1_COMPA_vect)
{
  OCR1A = NEXT_TOP;
  ++hits;
#ifdef WAKE
  if (hits == 2) {
    /* Same order as st_go_idle(): mask, then rewrite the prescaler bits. */
    TIMSK1 &= ~(1<<OCIE1A);
    TCCR1B = (TCCR1B & ~((1<<CS12) | (1<<CS11))) | (1<<CS10);
  }
#endif
  if (hits == 4) { TIMSK1 = 0; }
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
#ifdef WAKE
  /* Idle with a masked match pending, then enable as st_wake_up() does. */
  while (hits < 2) {}
  while (!(TIFR1 & (1<<OCF1A))) {}
  flagged = 1;
  TIMSK1 |= 1<<OCIE1A;
#endif
  while (hits < 4) {}
  cli();
  sleep_cpu(); /* simavr stops here: sleep with interrupts disabled */
  for (;;) {}
}
