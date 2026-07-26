#!/bin/sh
#  init_check.sh - post-link BOOT-INIT REACHABILITY check
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  WHY THIS EXISTS (BUG #23, CONTRACTS.md gap-log "boot-init-unreachable")
#  -----------------------------------------------------------------------
#  stm32f103, stm32f411, stm32h523 and hc32f460 each shipped a complete,
#  reviewed, documented hal_system_init() -> hal_clock_config() +
#  hal_gpio_init() chain that NO CALLER EVER REACHED. grbl/main.c is the
#  golden gate and never called it; no Reset_Handler called it either. LTO
#  saw an unreferenced subgraph and deleted it before codegen. The link
#  succeeded, --gc-sections was happy, `size` reported a plausible number,
#  boot_check.sh (BUG #21) passed because the vector table was fine - and
#  the chips booted on their reset-default clock with unconfigured GPIO.
#
#  Same failure CLASS as BUG #21, one level up: BUG #21 lost the vector
#  table (data the hardware reads), BUG #23 lost the init chain (code
#  nothing calls). boot_check.sh proves word0/word1 of the .bin are a real
#  reset record; it says nothing about whether anything downstream of
#  Reset_Handler actually configures the chip. This script closes that gap.
#
#  The signature that made BUG #23 hard to see: byte-invariance. Changing
#  SPINDLE_ENABLE_PIN 7 -> 3 in stm32f103/config.h produced a
#  BYTE-IDENTICAL RELEASE .bin. That looked like determinism. It was
#  actually proof that the only code consuming the pin map was not in the
#  image. BYTE-INVARIANCE IS A WEAK SIGNAL WHEN THE CODE UNDER TEST MAY BE
#  UNREACHABLE - it cannot distinguish "nothing changed" from "nothing is
#  there".
#
#  WHAT THIS CHECKS
#    Every symbol in the port's declared INIT_SYMBOLS list must be DEFINED
#    in the linked ELF (nm type != 'U'). Absence fails the build.
#
#  WHY THAT IS A REACHABILITY PROOF (and what it depends on)
#    After a -flto + --gc-sections link, a function survives only if
#    something reaches it. So "defined in the final ELF" == "reachable".
#    The one false negative is INLINING: a single-call-site init folded
#    into its caller is present-and-executed but has no symbol. The port
#    side removes that ambiguity by tagging every INIT_SYMBOLS function
#    GRBL_BOOT_INIT (== noinline, common/boot_init.h). Note carefully that
#    GRBL_BOOT_INIT is NOT `used`: `used` would force the symbol into the
#    image whether or not anything called it, which would have made this
#    check report all four broken ports GREEN. See boot_init.h.
#
#  Usage:
#    init_check.sh <nm-binary> <elf-file> <sym1,sym2,...>
#    init_check.sh --selftest
#  e.g.
#    init_check.sh arm-none-eabi-nm build/grbl_stm32f103.elf \
#        Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init
#
#  Symbol lists are PER PORT and declared in the port's own Makefile
#  (INIT_SYMBOLS) because ports name their init differently: the STM32/
#  HC32 family uses hal_system_init/hal_clock_config/hal_gpio_init, samd21
#  and the WCH RISC-V ports use SystemInit (+ SystemClock_Config), the
#  dsPIC uses a crt0 user_init hook with an underscore-prefixed assembler
#  name (_hal_clock_config), and atmega328p has no software clock/GPIO
#  bring-up at all (fuses + core macros) so its list names the core init
#  entry points instead.

set -eu

# --- shared matcher ---------------------------------------------------------
# One function used by BOTH the real check and the selftest, so the selftest
# cannot pass by agreeing with a private copy of the logic.
#
# Reads `nm` output on stdin ("value type name", or "         U name" for
# undefined). Prints, one per line, every symbol from $1 that is NOT defined
# in that output. $2 != "U" is the definedness test: 'T'/'t' (text),
# 'W'/'w' (weak - how the dsPIC toolchain emits user_init hooks), 'D'/'B'
# etc. all count as defined; a bare 'U' reference does not - a symbol merely
# CALLED by something the linker also dropped proves nothing.
missing_symbols() {
  awk -v want="$1" '
    BEGIN {
      n = split(want, a, ",");
      for (i = 1; i <= n; i++) if (a[i] != "") need[a[i]] = 1;
    }
    $2 != "U" && ($3 in need) { delete need[$3] }
    END { for (s in need) print s }
  ' | sort
}

run_check() {
  NM="$1"
  ELF="$2"
  SYMS="$3"

  if [ ! -f "$ELF" ]; then
    echo "BOOT INIT: FAIL - $ELF does not exist" >&2
    exit 1
  fi

  MISSING=$("$NM" "$ELF" | missing_symbols "$SYMS")

  if [ -n "$MISSING" ]; then
    echo "" >&2
    echo "=========================================================================" >&2
    echo "BOOT INIT: FAIL - $ELF is missing required init symbols" >&2
    echo "" >&2
    echo "  declared (INIT_SYMBOLS): $SYMS" >&2
    echo "  NOT DEFINED in the linked image:" >&2
    echo "$MISSING" | sed 's/^/    /' >&2
    echo "" >&2
    echo "  A boot-init function that survives a -flto + --gc-sections link is" >&2
    echo "  reachable; one that vanishes is not. Nothing else in the build fails" >&2
    echo "  on this: the link succeeds, --gc-sections is happy, size looks" >&2
    echo "  normal, boot_check.sh passes (the vector table is fine) - and the" >&2
    echo "  chip boots on its reset-default clock with unconfigured GPIO." >&2
    echo "" >&2
    echo "  Most likely causes:" >&2
    echo "    1. Nothing calls it. Core grbl/main.c is the golden gate and will" >&2
    echo "       NOT call platform init - the call must come from the platform" >&2
    echo "       side, in Reset_Handler, before main(). This is BUG #23." >&2
    echo "    2. It IS called but got inlined into its only caller. Tag the" >&2
    echo "       definition AND declaration GRBL_BOOT_INIT (common/boot_init.h)." >&2
    echo "    3. INIT_SYMBOLS names a symbol this port renamed or dropped." >&2
    echo "       Update the port Makefile - but only after confirming the" >&2
    echo "       replacement really runs before main()." >&2
    echo "" >&2
    echo "  See CONTRACTS.md gap-log #boot-init-unreachable / PLAN.md BUG #23." >&2
    echo "=========================================================================" >&2
    exit 1
  fi

  echo "BOOT INIT: OK  [$SYMS] all defined in $ELF"
}

# --- selftest ---------------------------------------------------------------
# Style matches tools/assert_no_double.sh --selftest and ci/warn_ratchet.py
# --selftest: POSITIVE cases (must be caught), NEGATIVE cases (must not be
# flagged), and an end-to-end run through the real entry point with a fake
# nm, including the exact BUG #23 symbol table.
selftest() {
  checks=0
  fail() { echo "selftest: FAIL - $1" >&2; exit 1; }
  pass_check() { checks=$((checks + 1)); }

  WANT='Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init'

  # --- NEGATIVE: a healthy post-fix image. Nothing may be reported. --------
  fixed='08000100 T Reset_Handler
08000200 T hal_system_init
08000300 T hal_clock_config
08000400 T hal_gpio_init
08000500 T main
         U memset'
  out=$(printf '%s\n' "$fixed" | missing_symbols "$WANT") || true
  [ -z "$out" ] || fail "healthy image flagged missing symbols: $out"
  pass_check

  # --- POSITIVE: THE ACTUAL BUG #23 SYMBOL TABLE --------------------------
  # Verbatim shape of the pre-fix RELEASE ELFs: Reset_Handler and main
  # present, all three init symbols deleted by LTO because nothing called
  # hal_system_init. This must be caught, or the ratchet is decorative.
  bug23='080041f8 T Reset_Handler
08005f0c T main'
  out=$(printf '%s\n' "$bug23" | missing_symbols "$WANT") || true
  [ -n "$out" ] || fail "the BUG #23 symbol table (init chain LTO-deleted) was NOT caught"
  for s in hal_system_init hal_clock_config hal_gpio_init; do
    case "$out" in *"$s"*) : ;; *) fail "$s missing from the reported set" ;; esac
  done
  case "$out" in *Reset_Handler*) fail "Reset_Handler wrongly reported missing" ;; *) : ;; esac
  pass_check

  # --- POSITIVE: partial loss (gpio dropped, clock kept) ------------------
  partial='08000100 T Reset_Handler
08000200 T hal_system_init
08000300 T hal_clock_config'
  out=$(printf '%s\n' "$partial" | missing_symbols "$WANT") || true
  [ "$out" = "hal_gpio_init" ] || fail "partial loss: expected exactly hal_gpio_init, got '$out'"
  pass_check

  # --- POSITIVE: an UNDEFINED reference must not count as present ---------
  # A symbol merely CALLED by code the linker also dropped is still absent
  # from the image. This is the difference between this check and grepping
  # the whole nm dump.
  undef='08000100 T Reset_Handler
08000200 T hal_system_init
08000300 T hal_clock_config
         U hal_gpio_init'
  out=$(printf '%s\n' "$undef" | missing_symbols "$WANT") || true
  [ "$out" = "hal_gpio_init" ] || fail "undefined (U) reference wrongly accepted as defined, got '$out'"
  pass_check

  # --- NEGATIVE: weak definitions count (dsPIC user_init hooks are 'W') ---
  weakdef='0080055c W __user_init
0080979c W _hal_clock_config
00800480 W __reset'
  out=$(printf '%s\n' "$weakdef" | missing_symbols '__reset,_hal_clock_config') || true
  [ -z "$out" ] || fail "weak ('W') definitions wrongly reported missing: $out"
  pass_check

  # --- NEGATIVE: substring lookalikes must not satisfy a requirement ------
  # hal_gpio_init_late is a DIFFERENT function; requiring hal_gpio_init must
  # not be satisfied by it (a grep-based implementation would pass here).
  lookalike='08000100 T Reset_Handler
08000200 T hal_system_init
08000300 T hal_clock_config
08000400 T hal_gpio_init_late'
  out=$(printf '%s\n' "$lookalike" | missing_symbols "$WANT") || true
  [ "$out" = "hal_gpio_init" ] || fail "substring lookalike accepted as the required symbol, got '$out'"
  pass_check

  # --- NEGATIVE: single-symbol list, present ------------------------------
  out=$(printf '%s\n' "$fixed" | missing_symbols 'main') || true
  [ -z "$out" ] || fail "single-symbol present case flagged: $out"
  pass_check

  # --- end-to-end through the real entry point, with a fake nm ------------
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  fakenm="$tmpdir/nm"
  cat > "$fakenm" <<'FAKENM'
#!/bin/sh
cat "$1.nmout"
FAKENM
  chmod +x "$fakenm"

  : > "$tmpdir/good.elf"
  printf '%s\n' "$fixed" > "$tmpdir/good.elf.nmout"
  : > "$tmpdir/bad.elf"
  printf '%s\n' "$bug23" > "$tmpdir/bad.elf.nmout"

  if "$0" "$fakenm" "$tmpdir/good.elf" "$WANT" >"$tmpdir/out_good" 2>&1; then
    :
  else
    fail "end-to-end PASS case exited nonzero: $(cat "$tmpdir/out_good")"
  fi
  pass_check

  if "$0" "$fakenm" "$tmpdir/bad.elf" "$WANT" >"$tmpdir/out_bad" 2>&1; then
    fail "end-to-end FAIL case (the BUG #23 table) exited 0 - the exact regression this selftest guards against"
  fi
  grep -q 'BOOT INIT: FAIL' "$tmpdir/out_bad" || fail "end-to-end FAIL case did not print the BOOT INIT banner"
  pass_check

  # A nonexistent ELF must fail, not silently pass.
  if "$0" "$fakenm" "$tmpdir/nope.elf" "$WANT" >/dev/null 2>&1; then
    fail "missing ELF exited 0"
  fi
  pass_check

  echo "selftest: PASS ($checks checks)"
}

# --- entry point ------------------------------------------------------------
if [ "${1:-}" = "--selftest" ]; then
  selftest
  exit 0
fi

if [ $# -ne 3 ]; then
  echo "usage: $0 <nm-binary> <elf-file> <sym1,sym2,...>" >&2
  echo "       $0 --selftest" >&2
  exit 2
fi

run_check "$1" "$2" "$3"
