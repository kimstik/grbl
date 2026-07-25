/*
  platform.c - dsPIC33AK128MC102 platform implementation (M1-M3 batch)
  Part of Grbl

  Contents: device config words, system clock to 200 MHz, GPIO
  direction/pull-up helpers. Timers/serial/nvmem/CN interrupts are
  Steps 3-6 (next batch) - their PORT_TODO_* symbols live in timer.h /
  serial.c / nvmem.c / handlers.c.

  ============================================================================
  STARTUP MODEL (deliberate departure from every ARM/RISC-V sibling port)
  ============================================================================
  There is NO startup.c and NO custom linker script in this port. The
  XC-DSC toolchain's own crt0 + the DFP's p33AK128MC102.gld are used
  as-is, because on dsPIC33A they already implement everything the ARM
  ports hand-wrote, and they are device-blessed:

    - Reset vector: the .gld places `LONG(ABSOLUTE(__reset))` at 0x800000
      (fixed reset location - NOT an ARM-style SP+PC fetch, NOT a RISC-V
      naked _start: the CPU jumps to the address stored there).
    - crt0 (__reset, DISASSEMBLY-VERIFIED this session): sets W15 (stack
      pointer) and SPLIM, programs IVTBASE = vector table base, runs
      __data_init over the .dinit template (the dsPIC equivalent of the
      .data-copy/.bss-zero loops every ARM startup.c writes by hand),
      calls any __attribute__((user_init)) functions, then _main.
    - IVT model: the TOOLCHAIN LINKER synthesizes the interrupt vector
      table (section __ivt_0 at 0x800004, 286 4-byte ADDRESS entries -
      dsPIC33A vectors are addresses, not instructions) directly from
      ISR symbol names (__attribute__((interrupt)) _T1Interrupt etc.);
      unused slots point at a weak __DefaultInterrupt. IVTBASE is a
      RUNTIME SFR (0x88) - the table is relocatable, and AIVT-style
      alternate tables from classic dsPIC are replaced by this
      IVTBASE indirection on dsPIC33A (no AIVT config-word dance).
      Consequence: a port-authored vector_table[] array would FIGHT the
      toolchain's own IVT emission - the correct move on this ISA is to
      define ISRs by their canonical names (handlers.c) and let the
      linker place them.
    - Clock config runs pre-main via __attribute__((user_init)) below -
      crt0 calls it after RAM init, before main (verified in the
      __reset disassembly: rcall __user_init between __data_init and
      the _main call).

  ============================================================================
  CLOCK (PORTING-CHECKLIST Step 1)
  ============================================================================
  Reset state: CLKGEN1 (CPU) runs from FRC 8 MHz. Target: 200 MHz via
  PLL1. Sequence and divider values below are taken VERBATIM from
  Microchip's own dsPIC33A clock documentation (developerhelp.microchip.com,
  "dsPIC33A Clock System"):

      Fpll = Fin * PLLFBDIV / (PLLPRE * POSTDIV1 * POSTDIV2)
           = 8 MHz * 200 / (1 * 4 * 2) = 200 MHz   (VCO = 1.6 GHz)

  Register/bitfield names cross-checked against the DFP header (OSCCTRL
  PLL1EN/PLL1RDY, PLL1CON NOSC/OSWEN/PLLSWEN/FOUTSWEN/ON/CLKRDY, PLL1DIV
  PLLPRE/PLLFBDIV/POSTDIV1/POSTDIV2, CLK1CON NOSC/OSWEN/CLKRDY).

  UNVERIFIED ON SILICON (no dsPIC33A emulator exists; hardware validation
  item): the whole sequence, plus two RM questions Step 3 must close
  before trusting timing math: (a) which clock generator feeds Timer1/
  SCCP/UART and at what ratio to the CPU clock; (b) whether any flash
  access-time configuration is required at 200 MHz (no wait-state
  register exists in the DFP SFR set - dsPIC33A flash appears to be
  handled by hardware prefetch, but the RM word is not vendored here).
*/

#include <xc.h>
#include <stdint.h>

// ============================================================================
// DEVICE CONFIG WORDS
// ============================================================================
// Names/values from the DFP's own config docs (xc16/docs/config_docs/
// 33AK128MC102.html). Minimal safe set:
//   WDTEN = SW : watchdog controlled by software (i.e. OFF unless enabled
//                via WDTCON) - an unprogrammed FWDT can leave the hardware
//                WDT free-running and reset GRBL mid-job ("compiles but
//                dead" class).
//   JTAGEN = OFF : release the JTAG pins to GPIO.
#pragma config WDTEN = SW
#pragma config JTAGEN = OFF

// ============================================================================
// SYSTEM CLOCK - 200 MHz via PLL1 (runs pre-main via user_init, see banner)
// ============================================================================

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

// ============================================================================
// GPIO DIRECTION / PULL-UP HELPERS (init context only - CONTRACTS.md #1)
// ============================================================================
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
