/*
  platform.c - dsPIC33AK128MC102 platform implementation
  Part of Grbl
*/

#include <xc.h>
#include <stdint.h>

// DEVICE CONFIG WORDS
// Names/values from the DFP's own config docs (xc16/docs/config_docs/
// 33AK128MC102.html). Minimal safe set:
//   WDTEN = SW : watchdog controlled by software (i.e. OFF unless enabled
//                via WDTCON) - an unprogrammed FWDT can leave the hardware
//                WDT free-running and reset GRBL mid-job ("compiles but
//                dead" class).
//   JTAGEN = OFF : release the JTAG pins to GPIO.
#pragma config WDTEN = SW
#pragma config JTAGEN = OFF

// SYSTEM CLOCK - 200 MHz via PLL1 (runs pre-main via user_init, see banner)

void __attribute__((user_init)) hal_clock_config(void)
{
  // Step 1: enable PLL1 block, wait ready (source defaults to FRC).
  OSCCTRLbits.PLL1EN = 1;
  while (!OSCCTRLbits.PLL1RDY) { ; }

  PLL1CONbits.BOSC = 2;               // BFRC as backup clock source
  PLL1CONbits.FSCMEN = 1;             // fail-safe clock monitor

  PLL1DIVbits.PLLFBDIV = 200;         // feedback divider
  PLL1DIVbits.PLLPRE   = 1;           // reference divider (FRC 8 MHz / 1)
  PLL1DIVbits.POSTDIV1 = 4;           // post divider #1
  PLL1DIVbits.POSTDIV2 = 2;           // post divider #2 -> 200 MHz out

  PLL1CONbits.PLLSWEN = 1;            // latch input/feedback dividers
  while (PLL1CONbits.PLLSWEN) { ; }

  PLL1CONbits.FOUTSWEN = 1;           // latch post dividers
  while (PLL1CONbits.FOUTSWEN) { ; }

  PLL1CONbits.NOSC = 1;               // PLL1 reference = FRC
  PLL1CONbits.OSWEN = 1;
  while (PLL1CONbits.OSWEN) { ; }

  PLL1CONbits.ON = 1;                 // start PLL1, wait for lock
  while (!PLL1CONbits.CLKRDY) { ; }

  // Step 2: switch CLKGEN1 (CPU clock) to PLL1 Fout.
  CLK1CONbits.BOSC = 2;               // BFRC backup for the CPU clock
  CLK1CONbits.FSCMEN = 1;
  CLK1CONbits.NOSC = 5;               // clock source 5 = PLL1 Fout
  CLK1CONbits.OSWEN = 1;              // request the switch
  while (CLK1CONbits.OSWEN) { ; }
  while (!CLK1CONbits.CLKRDY) { ; }
}

// GPIO DIRECTION / PULL-UP HELPERS (init context only - CONTRACTS.md #1)
// Indexed by GPIO_PIDX (A=0..D=3, gpio.h). TRIS: 1 = input (inverted vs
// AVR DDR - why these are functions, see gpio.h header). ANSEL exists
// only for ports A and B on this device (grepped the DFP header: no
// ANSELC/ANSELD) - analog-capable pins RESET TO ANALOG and read 0 as
// digital inputs until ANSEL is cleared, so both direction helpers clear
// it unconditionally. CNPU is bit-per-pin pull-up enable (a real pull-up
// register - #1.4 satisfied by construction).
//
// No atomicity dance: all callers are init-context (stepper/limits/probe/
// system/spindle/coolant *_init), single-threaded before sei().

static volatile uint32_t* const gpio_tris[4]  = { &TRISA,  &TRISB,  &TRISC,  &TRISD  };
static volatile uint32_t* const gpio_ansel[4] = { &ANSELA, &ANSELB, 0,       0       };
static volatile uint32_t* const gpio_cnpu[4]  = { &CNPUA,  &CNPUB,  &CNPUC,  &CNPUD  };

void hal_gpio_set_output(uint32_t port_idx, uint32_t mask)
{
  if (gpio_ansel[port_idx]) { *gpio_ansel[port_idx] &= ~mask; }
  *gpio_tris[port_idx] &= ~mask;      // TRIS 0 = output
}

void hal_gpio_set_input(uint32_t port_idx, uint32_t mask)
{
  if (gpio_ansel[port_idx]) { *gpio_ansel[port_idx] &= ~mask; }
  *gpio_tris[port_idx] |= mask;       // TRIS 1 = input
}

void hal_gpio_pullup_enable(uint32_t port_idx, uint32_t mask)
{
  *gpio_cnpu[port_idx] |= mask;
}

void hal_gpio_pullup_disable(uint32_t port_idx, uint32_t mask)
{
  *gpio_cnpu[port_idx] &= ~mask;
}

// GPIO CHANGE-NOTIFICATION ARM/DISARM (CONTRACTS.md #2, Step 6)
// Per-port CN register tables (DFP-verified: CNEN0x/CNEN1x/CNCONx/CNFx all
// exist for ports A-D, p33AK128MC102.h). Edge-style CN (CNCONx.CNSTYLE=1)
// is ASSUMED (not in the vendored DFP/.atdf - RM-only semantics, but this
// is the well-established enhanced-CN model used across the PIC24/dsPIC33
// family for over a decade): CNEN0x = per-pin rising-edge enable,
// CNEN1x = per-pin falling-edge enable. Both are armed together so ANY
// change triggers (contract #2.6 - core treats any edge as a trigger).
// This is called REPEATEDLY at runtime (limits_init/limits_disable,
// system_init - #2.1): only per-pin enable bits are touched, module ON
// and the port-level interrupt-enable bit are idempotent one-time
// side effects of the first arm call.
static volatile uint32_t* const gpio_cnen0[4] = { &CNEN0A, &CNEN0B, &CNEN0C, &CNEN0D };
static volatile uint32_t* const gpio_cnen1[4] = { &CNEN1A, &CNEN1B, &CNEN1C, &CNEN1D };
static volatile uint32_t* const gpio_cncon[4] = { &CNCONA, &CNCONB, &CNCONC, &CNCOND };
static volatile uint32_t* const gpio_cnf[4]   = { &CNFA,   &CNFB,   &CNFC,   &CNFD   };

// Port-level CN interrupt enable (IEC3 CNAIE/CNDIE - the two groups this
// board uses; extend if a future board puts LIMIT/CONTROL on B/C).
static void hal_gpio_cn_port_irq_enable(uint32_t port_idx)
{
  switch (port_idx) {
    case 0: _CNAIE = 1; break;   // port A - CONTROL group (boards/generic/config.h)
    case 3: _CNDIE = 1; break;   // port D - LIMIT group
    default: break;              // B/C unused by this board
  }
}

void hal_gpio_cn_enable(uint32_t port_idx, uint32_t mask)
{
  // Clear any stale per-pin flags for this mask BEFORE arming, so a pin
  // that changed while disarmed doesn't fire an immediate spurious IRQ
  // the instant it's re-armed.
  *gpio_cnf[port_idx] &= ~mask;
  *gpio_cnen0[port_idx] |= mask;   // rising edge
  *gpio_cnen1[port_idx] |= mask;   // falling edge -> any-change (#2.6)
  // CNCONx bit layout (p33AK128MC102.h CNCONxBITS, identical per port):
  // bit11 = CNSTYLE (1 = edge-select style, using CNEN0/CNEN1 above),
  // bit15 = ON. Both set unconditionally - idempotent.
  *gpio_cncon[port_idx] |= (1UL << 11) | (1UL << 15);
  hal_gpio_cn_port_irq_enable(port_idx);
}

void hal_gpio_cn_disable(uint32_t port_idx, uint32_t mask)
{
  *gpio_cnen0[port_idx] &= ~mask;
  *gpio_cnen1[port_idx] &= ~mask;
  // Module (CNCONx.ON) and the port-level IEC bit are left set: on this
  // board LIMIT and CONTROL each own a whole dedicated port (D and A),
  // so disarming this group's pins is sufficient - no other CN user
  // shares the port to disturb.
}

// STEPPER TIMER INIT - Timer1 (CONTRACTS.md #3, Step 3)
// INIT+RESET together yield: running, /1, interrupt masked (contract's
// INIT row). PR1 gets a safe non-zero default; STP_TMR_PERIOD_SET
// (timer.h) overwrites it before the first real segment loads.
void hal_timer_stepper_init(void)
{
  T1CON = 0;                 // module off while configuring
  TMR1  = 0;
  PR1   = 0xFFFFUL;           // safe default period, overwritten before use
  T1CONbits.TCS   = 0;        // internal peripheral clock (not external)
  T1CONbits.TGATE = 0;
  T1CONbits.TCKPS = 0;        // /1 (STP_TMR_PRESCALER_RESET() state)
  _T1IF = 0;
  _T1IE = 0;                  // interrupt masked (contract INIT row)
  _T1IP = 4;                  // mid priority - pulse-reset (CCT1) set higher, see hal_timer_pulse_reset_init
  T1CONbits.ON = 1;           // counter running (samd21 TC3 precedent)
}

// PULSE-RESET TIMER INIT - SCCP1 in 16-bit Timer mode (CONTRACTS.md #4)
// CCPxCON1.MOD encoding is NOT in the vendored DFP/.atdf (no value-group -
// grepped, confirmed absent for every CCPxCON1 field). 0b0001 is used
// here as "16-bit Timer mode" based on the well-established Microchip
// SCCP/MCCP module family convention (reused across dsPIC33CK/CH and now
// dsPIC33A) - UNVERIFIED against this specific device's RM (not vendored,
// no emulator exists). CLKSEL=0 assumes the peripheral clock (Fp); TMRPS=0
// (/1) - the software x8 rescale in timer.h's hal_timer_pulse_count_set()
// does not depend on getting a hardware /8 prescale right, only on
// CLKSEL actually selecting Fp (flagged, platform.h Fp-vs-F_CPU note).
void hal_timer_pulse_reset_init(void)
{
  CCP1CON1 = 0;                 // module off while configuring
  CCP1CON1bits.MOD    = 0x1;    // UNVERIFIED: assumed 16-bit Timer mode
  CCP1CON1bits.CCSEL  = 0;
  CCP1CON1bits.T32    = 0;      // 16-bit, not paired into a 32-bit timer
  CCP1CON1bits.TMRPS  = 0;      // /1 (software x8 rescale instead - timer.h)
  CCP1CON1bits.CLKSEL = 0;      // UNVERIFIED: assumed peripheral clock (Fp)
  CCP1TMR = 0;
  CCP1PR  = 0xFFFFUL;           // safe default, overwritten by COUNT_SET before every pulse
  _CCT1IF = 0;
  _CCT1IE = 1;                  // interrupt source enabled, timer STOPPED (contract INIT row)
  _CCT1IP = 5;                  // HIGHER than stepper (T1IP=4): pulse-reset preempts stepper
                                 // (#5.2 - dsPIC33A nests by priority natively, INTCON1.NSTDIS=0
                                 // at reset - the first port that can honor this AVR sei()-nesting
                                 // semantic for real instead of the M0+ "defer, don't nest" posture)
  CCP1CON1bits.ON = 0;           // STOPPED (contract: "overflow interrupt source enabled, timer STOPPED")
}

// SPINDLE PWM INIT - SCCP2 (CONTRACTS.md #6, Step 3)
// MOD=0b1001 is used here as "Edge-Aligned PWM mode" on the same
// UNVERIFIED-family-convention basis as CCP1's MOD above. TMRPS=0b11
// (assumed /64, same 2-bit encoding family) gives a base PWM frequency
// of ~200MHz/64/256 = 12.2 kHz (a plausible spindle-driver frequency;
// TMRPS=0 would give ~781 kHz, implausibly fast for a real ESC/VFD).
// The RPn PPS output remap (route RB4/RP21 to CCP2's PWM output) uses an
// UNVERIFIED function-select code (platform.h PPS_RPOR_FN_CCP2_UNVERIFIED)
// - the .atdf has NO value-group for any RPORx field at all (RM-only
// table). GPIO_DIR_OUT(SPINDLE_PWM) already ran before PWM_INIT()
// (spindle_control.c ordering) so RB4 is a valid digital output pin
// before this remaps it to the peripheral.
void hal_timer_spindle_pwm_init(void)
{
  CCP2CON1 = 0;                  // module off while configuring
  CCP2CON1bits.MOD    = 0x9;     // UNVERIFIED: assumed Edge-Aligned PWM mode
  CCP2CON1bits.CCSEL  = 0;
  CCP2CON1bits.T32    = 0;
  CCP2CON1bits.TMRPS  = 0x3;     // UNVERIFIED: assumed /64 -> ~12.2kHz PWM base freq
  CCP2CON1bits.CLKSEL = 0;       // UNVERIFIED: assumed peripheral clock (Fp)
  CCP2TMR = 0;
  CCP2PR  = SPINDLE_PWM_MAX_VALUE;   // 255: full 8-bit duty resolution end-to-end (#6.2)
  CCP2RA  = 0;
  CCP2CON2bits.OCAEN = 0;        // output NOT yet routed/enabled (contract PWM_INIT semantics)

  RPOR5bits.RP21R = PPS_RPOR_FN_CCP2_UNVERIFIED;   // RB4/RP21 -> CCP2 PWM out (UNVERIFIED code)

  CCP2CON1bits.ON = 1;            // free-running once initialized; OCAEN gates the pin (PWM_ENABLE/DISABLE)
}
