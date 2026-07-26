/*
  boot_init.h - GRBL_BOOT_INIT: the anchor attribute for pre-main boot init
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  WHY THIS EXISTS (BUG #23, CONTRACTS.md gap-log "boot-init-unreachable")
  ----------------------------------------------------------------------
  Four ports (stm32f103, stm32f411, stm32h523, hc32f460) shipped with a
  fully written hal_system_init() -> hal_clock_config() + hal_gpio_init()
  chain that NOTHING EVER CALLED. grbl/main.c is the golden gate and does
  not call it; no Reset_Handler called it either. Under -flto the whole
  chain was therefore unreachable, GCC's IPA deleted it before codegen,
  and the RELEASE image contained none of it: those chips booted on the
  reset-default clock with unconfigured GPIO. DEBUG (no LTO) kept the dead
  code, so `size` and a symbol dump of the DEBUG build both looked fine.

  The check that catches this is post-link: does the RELEASE image still
  DEFINE the port's boot-init symbols? (common/init_check.sh). For that
  question to be meaningful, presence in the linked image must mean
  "the linker kept it because something reaches it" - and absence must
  mean "nothing reaches it". Two attributes are in play, and only one of
  them is correct here:

    noinline  (what GRBL_BOOT_INIT uses)
        Kills the FALSE NEGATIVE. Without it, a one-call-site init
        (SystemInit() from Reset_Handler, the samd21/ch32v006/ch570
        shape) is inlined into its caller and the out-of-line symbol is
        dropped - present-and-executed code that nm reports as absent,
        indistinguishable from BUG #23. noinline does NOT keep anything
        alive: an init nobody calls is still deleted, exactly as it must
        be for the check to have teeth.

    used      (DELIBERATELY NOT USED HERE - it would defeat the check)
        `used` forces emission of a function EVEN IF UNREFERENCED. Slap
        it on hal_clock_config() and the symbol appears in every image
        whether or not a single instruction ever branches to it - the
        post-link check would have reported all four broken ports GREEN.
        `used` is the right tool for a DATA table the hardware reads
        behind the compiler's back (vector_table[], CONTRACTS.md S18 /
        BUG #21); it is precisely the wrong tool for a function whose
        reachability is the property under test.

  So: GRBL_BOOT_INIT == noinline, and the reachability proof is
  "the symbol survived a --gc-sections + -flto link".

  USAGE
    Apply to BOTH the declaration (platform.h) and the definition
    (platform.c/startup.c) of every function named in the port
    Makefile's INIT_SYMBOLS list:

      GRBL_BOOT_INIT void hal_clock_config(void);

    Then declare it in the port Makefile:

      INIT_SYMBOLS = Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init

  Ports whose init is reached by a mechanism other than a plain call -
  dspic33ak128mc102's __attribute__((user_init)), which puts the function
  ADDRESS in a crt0-walked table - need no anchor: an address-taken
  function is never inlined away, so its symbol is present by
  construction. Declare it in INIT_SYMBOLS anyway; the check is what
  proves the crt0 table still references it.
*/

#ifndef GRBL_PLATFORM_BOOT_INIT_H
#define GRBL_PLATFORM_BOOT_INIT_H

#define GRBL_BOOT_INIT __attribute__((noinline))

#endif // GRBL_PLATFORM_BOOT_INIT_H
