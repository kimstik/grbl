// SAMD21 specific timer primitives with correct naming

/* TODO list - keep me compact for reference at the file top

// spindle_control.c
PWM_INIT();
PWM_DISABLE();
PWM_ENABLE();
PWM_IS_ENABLED()
PWM_SET(duty_value);

// stepper.c
 ISR_STEP_DELAY()
 ISR_STEP_RESET()
 ISR_STEP()

STP_PULSE_DELAY_INIT()

STP_PULSE_RESET_INIT()
STP_PULSE_RESET_COMPARE_SET(val);
STP_PULSE_RESET_COUNT_SET(val);
STP_PULSE_RESET_START();
STP_PULSE_RESET_STOP();

STP_TMR_INIT();
STP_TMR_INT_DIS();
STP_TMR_INT_ENA();
STP_TMR_PERIOD_SET(val);
STP_TMR_PRESCALER_SET(val);
STP_TMR_PRESCALER_RESET();
*/

#include "samd21.h"

// ============================================================================
// ISR DEFINITIONS
// ============================================================================
#define ISR_STEP()          void TC3_Handler(void)
#define ISR_STEP_RESET()    void TC4_Handler(void)
#define ISR_STEP_DELAY()    void TC5_Handler(void)

// ============================================================================
// STEPPER TIMER (TC3 - 16-bit timer/counter)
// ============================================================================

// TC3 initialization for CTC mode
#define STP_TMR_INIT() \
  do { \
    PM->APBCMASK.reg |= PM_APBCMASK_TC3; \
    GCLK->CLKCTRL.reg = GCLK_CLKCTRL_ID_TCC2_TC3 | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS.bit.SYNCBUSY); \
    TC3->COUNT16.CTRLA.reg = TC_CTRLA_MODE_COUNT16; \
    TC3->COUNT16.CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ; \
    TC3->COUNT16.CTRLA.reg |= TC_CTRLA_PRESCALER_DIV1; \
    while (TC3->COUNT16.STATUS.bit.SYNCBUSY); \
  } while(0)

#define STP_TMR_INT_ENA()               (TC3->COUNT16.INTENSET.reg = TC_INTENSET_MC0)
#define STP_TMR_INT_DIS()               (TC3->COUNT16.INTENCLR.reg = TC_INTENCLR_MC0)
#define STP_TMR_PERIOD_SET(cycles)      (TC3->COUNT16.CC[0].reg = (cycles))
#define STP_TMR_PRESCALER_SET(prescaler) /* SAMD21: Prescaler set in INIT, dynamic change requires reconfiguration */
#define STP_TMR_PRESCALER_RESET()       /* Not needed on SAMD21 */

// ============================================================================
// PULSE RESET TIMER (TC4 - 16-bit timer/counter)
// ============================================================================

#define STP_PULSE_RESET_INIT() \
  do { \
    PM->APBCMASK.reg |= PM_APBCMASK_TC4; \
    GCLK->CLKCTRL.reg = GCLK_CLKCTRL_ID_TC4_TC5 | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS.bit.SYNCBUSY); \
    TC4->COUNT16.CTRLA.reg = TC_CTRLA_MODE_COUNT16; \
    TC4->COUNT16.INTENSET.reg = TC_INTENSET_OVF; \
    while (TC4->COUNT16.STATUS.bit.SYNCBUSY); \
  } while(0)

#define STP_PULSE_RESET_START()         (TC4->COUNT16.CTRLA.reg |= TC_CTRLA_ENABLE)
#define STP_PULSE_RESET_STOP()          (TC4->COUNT16.CTRLA.reg &= ~TC_CTRLA_ENABLE)
#define STP_PULSE_RESET_COUNT_SET(val)  (TC4->COUNT16.COUNT.reg = (val))
#define STP_PULSE_RESET_COMPARE_SET(val) (TC4->COUNT16.CC[0].reg = (val))

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_DELAY_INIT()        (TC5->COUNT16.INTENSET.reg = TC_INTENSET_MC0)
#endif

// ============================================================================
// PWM TIMER (TCC0 - Timer/Counter for Control)
// ============================================================================

#define PWM_INIT() \
  do { \
    PM->APBCMASK.reg |= PM_APBCMASK_TCC0; \
    GCLK->CLKCTRL.reg = GCLK_CLKCTRL_ID_TCC0_TCC1 | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS.bit.SYNCBUSY); \
    TCC0->CTRLA.reg = TCC_CTRLA_PRESCALER_DIV64; \
    TCC0->WAVE.reg = TCC_WAVE_WAVEGEN_NPWM; \
    TCC0->PER.reg = 0xFF; \
    while (TCC0->SYNCBUSY.bit.PER); \
  } while(0)

#define PWM_ENABLE()            (TCC0->CTRLA.reg |= TCC_CTRLA_ENABLE)
#define PWM_DISABLE()           (TCC0->CTRLA.reg &= ~TCC_CTRLA_ENABLE)
#define PWM_IS_ENABLED()        (TCC0->CTRLA.reg & TCC_CTRLA_ENABLE)
#define PWM_SET(duty_value) \
  do { \
    TCC0->CC[0].reg = (duty_value); \
    while (TCC0->SYNCBUSY.bit.CC0); \
  } while(0)
