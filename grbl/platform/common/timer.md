# Timer macro name mapping (HAL_TIMER_* -> STP_*/PWM_*/ISR_*)

This file is the historical name-mapping record only. The binding interface
contracts for every macro below — signatures, pre/post-conditions, ISR/timing
context, atomicity and memory-ordering obligations, no-op legality — live in
`../CONTRACTS.md` (§3 stepper timer, §4 pulse-reset timer, §5 ISR definition
macros, §6 spindle PWM). Porting order and definition of done:
`../PORTING-CHECKLIST.md`.

(There is no sibling `timer.h` in this directory - a stale, contentless
placeholder of that name was removed as a dead orphan during the
cross-port consistency audit. This `.md` is the only artifact; nothing
in the tree ever included the `.h`.)

/* usage map
spindle_control.c:	HAL_TIMER_SPINDLE_PWM_INIT();
spindle_control.c:	  if (HAL_TIMER_SPINDLE_PWM_IS_ENABLED()) {
spindle_control.c:	HAL_TIMER_SPINDLE_PWM_DISABLE();
spindle_control.c:	HAL_TIMER_SPINDLE_PWM_SET_DUTY(pwm_value);
spindle_control.c:		HAL_TIMER_SPINDLE_PWM_ENABLE();
spindle_control.c:		HAL_TIMER_SPINDLE_PWM_DISABLE();
spindle_control.c:		HAL_TIMER_SPINDLE_PWM_ENABLE();
stepper.c:	HAL_TIMER_PULSE_RESET_SET_COMPARE(-(((settings.pulse_microseconds)*TICKS_PER_MICROSECOND) >> 3));
stepper.c:  HAL_TIMER_STEPPER_INTERRUPT_ENABLE();
stepper.c:  HAL_TIMER_STEPPER_INTERRUPT_DISABLE();
stepper.c:  HAL_TIMER_STEPPER_RESET_PRESCALER();
stepper.c:HAL_TIMER_STEPPER_ISR()
stepper.c:  HAL_TIMER_PULSE_RESET_SET_COUNT(st.step_pulse_time);
stepper.c:  HAL_TIMER_PULSE_RESET_START();
stepper.c:		HAL_TIMER_STEPPER_SET_PRESCALER(st.exec_segment->prescaler);
stepper.c:	  HAL_TIMER_STEPPER_SET_PERIOD(st.exec_segment->cycles_per_tick);
stepper.c:HAL_TIMER_PULSE_RESET_ISR()
stepper.c:  HAL_TIMER_PULSE_RESET_STOP();
stepper.c:  HAL_TIMER_PULSE_DELAY_ISR()
stepper.c:  HAL_TIMER_STEPPER_INIT();
stepper.c:  HAL_TIMER_PULSE_RESET_INIT();
stepper.c:	HAL_TIMER_PULSE_DELAY_INIT();
*/

// -- name mappinng to get rig of HAL --
//spindle_control.c
HAL_TIMER_SPINDLE_PWM_INIT();				-> PWM_INIT();
HAL_TIMER_SPINDLE_PWM_DISABLE();			-> PWM_DISABLE();
HAL_TIMER_SPINDLE_PWM_ENABLE();				-> PWM_ENABLE();
HAL_TIMER_SPINDLE_PWM_IS_ENABLED()			-> PWM_IS_ENABLED()
HAL_TIMER_SPINDLE_PWM_SET_DUTY(pwm_value);	-> PWM_SET(duty_value);

//stepper.c
HAL_TIMER_PULSE_DELAY_ISR()					-> ISR_STEP_DELAY()
HAL_TIMER_PULSE_RESET_ISR()					-> ISR_STEP_RESET()
HAL_TIMER_STEPPER_ISR()						-> ISR_STEP()

HAL_TIMER_PULSE_DELAY_INIT();				-> STP_PULSE_DELAY_INIT()

HAL_TIMER_PULSE_RESET_INIT();				-> STP_PULSE_RESET_INIT()
HAL_TIMER_PULSE_RESET_SET_COMPARE(val);		-> STP_PULSE_RESET_COMPARE_SET(val);
HAL_TIMER_PULSE_RESET_SET_COUNT(val);  		-> STP_PULSE_RESET_COUNT_SET(val);
HAL_TIMER_PULSE_RESET_START();		 		-> STP_PULSE_RESET_START();
HAL_TIMER_PULSE_RESET_STOP();		  		-> STP_PULSE_RESET_STOP();

HAL_TIMER_STEPPER_INIT();			  		-> STP_TMR_INIT();
HAL_TIMER_STEPPER_INTERRUPT_DISABLE(); 		-> STP_TMR_INT_DIS();
HAL_TIMER_STEPPER_INTERRUPT_ENABLE();  		-> STP_TMR_INT_ENA();
HAL_TIMER_STEPPER_SET_PERIOD(val);			-> STP_TMR_PERIOD_SET(val);
HAL_TIMER_STEPPER_SET_PRESCALER(val);		-> STP_TMR_PRESCALER_SET(val);
HAL_TIMER_STEPPER_RESET_PRESCALER();   		-> STP_TMR_PRESCALER_RESET();
