/* hosted_rt.c - see hosted_rt.h. Part of Grbl / Intelligence assisted / MIT. */

#include "prelude.h"

hrt_state_t hrt;

void hrt_reset(void)
{
  memset(&hrt, 0, sizeof(hrt));
}

void hrt_port_write(uint8_t idx, uint8_t v)
{
  hrt.port[idx] = v;
  hrt.port_written |= (uint8_t)(1u << idx);
}

uint8_t hrt_port_read(uint8_t idx) { return hrt.port[idx]; }

void hrt_bit_set(uint8_t idx, uint8_t mask)
{
  hrt.port[idx] |= mask;
  hrt.port_written |= (uint8_t)(1u << idx);
}

void hrt_bit_clear(uint8_t idx, uint8_t mask)
{
  hrt.port[idx] = (uint8_t)(hrt.port[idx] & ~mask);
  hrt.port_written |= (uint8_t)(1u << idx);
}

void hrt_period_set(uint16_t v)   { hrt.period = v; }
void hrt_pulse_count_set(uint8_t v) { hrt.pulse_reload = v; }
void hrt_pulse_start(void)        { hrt.pulse_armed = 1; }
void hrt_pulse_stop(void)         { hrt.pulse_armed = 0; }
void hrt_timer_enable(void)       { hrt.timer_enabled = 1; }
void hrt_timer_disable(void)      { hrt.timer_enabled = 0; }
void hrt_spindle_pwm(uint8_t v)   { hrt.pwm = v; hrt.pwm_written = 1; }
