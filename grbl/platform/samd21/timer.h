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
// SAMD21 ISR wrappers that auto-clear interrupt flags
// ARM Cortex-M requires manual clearing of peripheral INTFLAG registers
//
// The actual TC3_Handler/TC4_Handler/TC5_Handler functions are defined in handlers.c
// They clear the INTFLAG bits then call the implementation functions below
// which are defined in stepper.c via these macros

#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (TC3 - 16-bit timer/counter)
// ============================================================================

// TC3 initialization for CTC mode
#define STP_TMR_INIT() \
  do { \
    PM->APBCMASK |= PM_APBCMASK_TC3; \
    GCLK->CLKCTRL = (GCLK_CLKCTRL_ID_TCC2_TC3 << GCLK_CLKCTRL_ID_Pos) | \
                     GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS & (1 << 7)); \
    TC3->CTRLA = TC_CTRLA_MODE_COUNT16 | TC_CTRLA_WAVEGEN_MFRQ | TC_CTRLA_PRESCALER_DIV1 | TC_CTRLA_ENABLE; \
    while (TC3->STATUS & (1 << 7)); \
    NVIC_EnableIRQ(TC3_IRQn); \
  } while(0)

#define STP_TMR_INT_ENA()               (TC3->INTENSET = TC_INTFLAG_MC0)
#define STP_TMR_INT_DIS()               (TC3->INTENCLR = TC_INTFLAG_MC0)
#define STP_TMR_PERIOD_SET(cycles)      do { TC3->CC[0] = (cycles); while (TC3->STATUS & (1 << 7)); } while(0)
#define STP_TMR_PRESCALER_SET(prescaler) /* SAMD21: Prescaler set in INIT, dynamic change requires reconfiguration */
#define STP_TMR_PRESCALER_RESET()       /* Not needed on SAMD21 */

// ============================================================================
// PULSE RESET TIMER (TC4 - 16-bit timer/counter)
// ============================================================================

#define STP_PULSE_RESET_INIT() \
  do { \
    PM->APBCMASK |= PM_APBCMASK_TC4; \
    GCLK->CLKCTRL = (GCLK_CLKCTRL_ID_TC4_TC5 << GCLK_CLKCTRL_ID_Pos) | \
                     GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS & (1 << 7)); \
    TC4->CTRLA = TC_CTRLA_MODE_COUNT16; \
    while (TC4->STATUS & (1 << 7)); \
    TC4->INTENSET = TC_INTFLAG_OVF; \
    NVIC_EnableIRQ(TC4_IRQn); \
  } while(0)

#define STP_PULSE_RESET_START()         do { TC4->CTRLA |= TC_CTRLA_ENABLE; while (TC4->STATUS & (1 << 7)); } while(0)
#define STP_PULSE_RESET_STOP()          do { TC4->CTRLA &= ~TC_CTRLA_ENABLE; while (TC4->STATUS & (1 << 7)); } while(0)
#define STP_PULSE_RESET_COUNT_SET(val)  do { TC4->COUNT = (val); while (TC4->STATUS & (1 << 7)); } while(0)
#define STP_PULSE_RESET_COMPARE_SET(val) do { TC4->CC[0] = (val); while (TC4->STATUS & (1 << 7)); } while(0)

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_DELAY_INIT()        (TC5->INTENSET = TC_INTFLAG_MC0)
#endif

// ============================================================================
// PWM TIMER (TCC0 - Timer/Counter for Control)
// ============================================================================

#define PWM_INIT() \
  do { \
    PM->APBCMASK |= PM_APBCMASK_TCC0; \
    GCLK->CLKCTRL = (GCLK_CLKCTRL_ID_TCC0_TCC1 << GCLK_CLKCTRL_ID_Pos) | \
                     GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS & (1 << 7)); \
    TCC0->CTRLA = TCC_CTRLA_PRESCALER_DIV64; \
    while (TCC0->SYNCBUSY & (1 << 3)); \
    TCC0->WAVE = TCC_WAVE_WAVEGEN_NPWM; \
    TCC0->PER = 0xFF; \
    while (TCC0->SYNCBUSY & ((1 << 6) | (1 << 7))); \
  } while(0)

#define PWM_ENABLE()            do { TCC0->CTRLA |= TCC_CTRLA_ENABLE; while (TCC0->SYNCBUSY & (1 << 1)); } while(0)
#define PWM_DISABLE()           do { TCC0->CTRLA &= ~TCC_CTRLA_ENABLE; while (TCC0->SYNCBUSY & (1 << 1)); } while(0)
#define PWM_IS_ENABLED()        (TCC0->CTRLA & TCC_CTRLA_ENABLE)
#define PWM_SET(duty_value) \
  do { \
    TCC0->CC[0] = (duty_value); \
    while (TCC0->SYNCBUSY & (1 << 8)); \
  } while(0)
