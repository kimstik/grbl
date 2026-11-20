/* micro.c - isolated generator costs, not firmware/planner/stepper performance.
   Links motion_control.c and avr-libc with the same observable queue stub for
   Wang and the circle fitter. Timer1 counts cycles; UART is polled with interrupts
   disabled during output. The walker and every queue target remain live via hash.
   Part of Grbl. License: GPLv3, see grbl/grbl.h. */
#include "grbl.h"
#include <avr/sleep.h>

settings_t settings;
system_t sys;

static volatile uint16_t ovf;
ISR(TIMER1_OVF_vect) { ovf++; }

static uint32_t now(void)
{
  uint8_t sr=SREG;
  cli();
  uint16_t lo=TCNT1, hi=ovf;
  if ((TIFR1 & _BV(TOV1)) && lo < 0x8000) { hi++; }
  SREG=sr;
  return((uint32_t)hi<<16 | lo);
}

static void put(char c)
{
  while (!(UCSR0A & _BV(UDRE0))) { }
  UDR0=c;
}
static void word(uint32_t n)
{
  char s[11]; uint8_t i=0;
  do { s[i++]=(n%10)+'0'; n/=10; } while (n);
  put(' ');
  do { put(s[--i]); } while (i);
}
static void text(const char *p)
{
  while (pgm_read_byte(p)) { put(pgm_read_byte(p++)); }
}
static void newline(void) { put('\r'); put('\n'); }

static uint32_t start, exit_time, first_gap, worst_gap, hash;
static uint16_t count, realtime;
static float last[N_AXIS];

void protocol_execute_realtime(void) { realtime++; }
void protocol_auto_cycle_start(void) { }
void limits_soft_check(float *target) { (void)target; }
void spindle_sync(uint8_t state, float rpm) { (void)state; (void)rpm; }
uint8_t plan_check_full_buffer(void) { return(0); }
uint8_t plan_buffer_line(float *target, plan_line_data_t *data)
{
  uint32_t t=now(), gap=t-(count ? exit_time : start);
  if (!count) { first_gap=gap; }
  else if (gap > worst_gap) { worst_gap=gap; }
  const uint8_t *b=(const uint8_t *)target;
  uint8_t i;
  for (i=0; i<sizeof(last); i++) { hash=(hash^b[i])*16777619UL; }
  memcpy(last,target,sizeof(last));
  // Feed and flags are observed too, so a later G93 experiment cannot optimize them away.
  b=(const uint8_t *)&data->feed_rate;
  for (i=0; i<4; i++) { hash=(hash^b[i])*16777619UL; }
  hash=(hash^data->condition)*16777619UL;
  count++;
  exit_time=now();
  return(1);
}

extern uint8_t __heap_start;
static void paint(void)
{
  uint8_t *p=&__heap_start, *end=(uint8_t *)SP-16;
  while (p<end) { *p++=0xa5; }
}
static uint16_t untouched(void)
{
  uint8_t *p=&__heap_start;
  while (p<(uint8_t *)RAMEND && *p==0xa5) { p++; }
  return(p-&__heap_start);
}

// Matching finite control nets for every generator. The final net deliberately hits a cap.
static const float nets[][6] PROGMEM = {
  {3,3, 13,3, 10,0},
  {-20,30, 15,30, -5,0},
  {-30,0, 30,0, -10,0},
  {0,0, 12,4, 10,0},
  {3,0.000001, 13,0.000001, 10,0},
  {0.003,0.01, 0.013,0.01, 0.01,0},
  {-3.3333,16.6667, -6.6667,-466.667, -10,8550},
  {-2361.66455,614.281433, -1883.65942,481.836395, -1973.58826,498.736633},
  {100000,100000, 100010,100000, 10,0}
};

int main(void)
{
  paint();
  UBRR0H=0; UBRR0L=8;
  UCSR0A=_BV(U2X0); UCSR0B=_BV(TXEN0); UCSR0C=_BV(UCSZ01)|_BV(UCSZ00);
  TCCR1A=0; TCCR1B=_BV(CS10); TIMSK1=_BV(TOIE1);
  settings.arc_tolerance=0.002f;
  sei();
  uint32_t t=now();
  __builtin_avr_delay_cycles(1000000);
  uint32_t calib=now()-t;
  cli(); text(PSTR("calib")); word(calib); newline(); sei();
  uint8_t k;
  for (k=0; k<sizeof(nets)/sizeof(nets[0]); k++) {
    float p[3]={0,0,0}, q[3]={0,0,0}, a[2], b[2];
    a[0]=pgm_read_float(&nets[k][0]); a[1]=pgm_read_float(&nets[k][1]);
    b[0]=pgm_read_float(&nets[k][2]); b[1]=pgm_read_float(&nets[k][3]);
    q[0]=pgm_read_float(&nets[k][4]); q[1]=pgm_read_float(&nets[k][5]);
    plan_line_data_t data;
    memset(&data,0,sizeof(data)); data.feed_rate=1000.0f;
    count=realtime=0; hash=2166136261UL; first_gap=worst_gap=0;
    start=now();
    uint8_t status=0;
    uint32_t dry=0;
#ifdef BEZIER_CIRCLE_FIT
    status=mc_cubic_b_spline_validate(q,p,a,b);
    dry=now()-start;
#endif
    if (!status) { mc_cubic_b_spline(q,&data,p,a,b); }
    uint32_t total=now()-start;
    uint16_t spare=untouched();
    uint8_t exact=count && !memcmp(last,q,sizeof(last));
    cli();
    text(PSTR("case")); word(k); word(status); word(count); word(total); word(dry);
    word(first_gap); word(worst_gap); word(hash); word(exact); word(realtime); word(spare);
    newline(); sei();
  }
  cli(); text(PSTR("done")); newline();
  while (!(UCSR0A & _BV(TXC0))) { }
  sleep_mode();
  return(0);
}
