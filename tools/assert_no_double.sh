#!/bin/sh
#  assert_no_double.sh - post-link FP=SINGLE enforcement (grbl/platform)
#  Part of Grbl
#
#  Usage: assert_no_double.sh <nm-binary> <elf-file>
#         assert_no_double.sh --selftest
#
#  Why this exists (CONTRACTS "FP precision is a declared port property"):
#  GRBL core was written against avr-gcc, where double==float (32-bit) -
#  every unsuffixed double literal and libm call in core has been single
#  precision since 2009. On targets where double is a real 64-bit type,
#  any missed promotion silently drags in kilobytes of DP soft-float and
#  DP libm (measured ~10KB on ch32v006). Compile flags request SP; only
#  the linked ELF proves it. This script is the truth check: it fails the
#  build, listing offenders, if any double-precision COMPUTATION machinery
#  was linked in.
#
#  Denied (defined symbols in the ELF) - TWO symbol families, both required:
#    - GENERIC libgcc names: __adddf3/__subdf3/__muldf3/__divdf3, the
#      __*df2 compares, __powidf2. What a hosted (non-EABI) libgcc emits.
#    - __aeabi_* AAPCS names: what arm-none-eabi-gcc's libgcc ACTUALLY
#      emits for soft-float double ops (GCC's ARM EABI support renames
#      every soft-float libcall to __aeabi_*). Every target this project
#      ships is ARM, so THIS is the family that actually appears on a
#      link. Checking only the generic family is blind by construction on
#      every platform in this repo: an object doing plain `double`
#      arithmetic links __aeabi_dadd/dsub/dmul/ddiv and never touches
#      __adddf3 et al - the generic-only denylist reported "PASSED: no DP
#      machinery" on such a binary (exit 0). Also covered: __aeabi_drsub
#      (reverse subtract), __aeabi_dneg, the __aeabi_dcmp*/__aeabi_cdcmp*/
#      __aeabi_cdrcmple compare family, and __muldc3/__divdc3 (complex
#      double multiply/divide - genuine DP computation behind libgcc's
#      complex-arithmetic helpers; same mangled name in both families, no
#      __aeabi_ variant exists to add separately).
#    - DP libm entry points (the unsuffixed names): sqrt, atan2, sin, ...
#      plus their internal helpers (__rem_pio2, __kernel_rem_pio2, ...).
#      Naming is ABI-independent - no __aeabi_ split to worry about here.
#
#  Deliberately ALLOWED: pure format conversions - a conversion cannot
#  compute:
#    - widening: __extendsfdf2/__aeabi_f2d (float->double),
#      __floatsidf/__aeabi_i2d/__aeabi_ui2d (32-bit int->double)
#    - narrowing: __truncdfsf2/__aeabi_d2f (double->float),
#      __fixdfsi/__fixunsdfsi/__aeabi_d2iz/__aeabi_d2uiz (double->int)
#  These survive only at legacy double-typed ABI boundaries (e.g. the AVR
#  util/delay.h `_delay_ms(double)` contract, which narrows at entry) and
#  cost ~0.5KB total. Any actual DP arithmetic behind such a boundary
#  still links real __aeabi_d*/__*df3 ops feeding it, and trips the
#  denylist same as anywhere else. As of this writing exactly ONE
#  tolerated conversion survives in the landed samd21 FP=SINGLE ELF:
#  __aeabi_d2f, at that same _delay_*(double) boundary in
#  grbl/platform/samd21/platform.c - verified live with nm, not assumed.
#
#  NOTE: __floatdidf (64-bit long long -> double) is intentionally NOT in
#  the tolerated set above, unlike its 32-bit sibling __floatsidf. Nothing
#  in GRBL core or any platform's port code has a legitimate reason to
#  widen a 64-bit integer into a double; its presence signals an
#  unintended path rather than a narrow ABI boundary, so it is denied.
#
#  This denylist has failed silently before (that is the whole reason the
#  __aeabi_* family above was added) - see the --selftest mode, which
#  builds a synthetic "pure __aeabi_* arithmetic, zero generic names"
#  symbol table (the exact shape of the demonstrated exploit) and asserts
#  it is caught, so this class of blindness cannot regress unnoticed.

set -eu

# --- shared denylist --------------------------------------------------------
# One dynamic-regex string so the real check and the selftest exercise
# EXACTLY the same matching logic - a hand-duplicated copy in the selftest
# would only prove the selftest agrees with itself.
DENY_REGEX='^(__adddf3|__subdf3|__muldf3|__divdf3|__negdf2|__eqdf2|__nedf2|__gtdf2|__gedf2|__ltdf2|__ledf2|__unorddf2|__powidf2|__aeabi_dadd|__aeabi_dsub|__aeabi_drsub|__aeabi_dmul|__aeabi_ddiv|__aeabi_dneg|__aeabi_dcmpeq|__aeabi_dcmplt|__aeabi_dcmple|__aeabi_dcmpge|__aeabi_dcmpgt|__aeabi_dcmpun|__aeabi_cdcmpeq|__aeabi_cdcmple|__aeabi_cdrcmple|__floatdidf|__muldc3|__divdc3|__rem_pio2|__kernel_rem_pio2|__kernel_sin|__kernel_cos|__kernel_tan|acos|asin|atan|atan2|cbrt|ceil|copysign|cos|cosh|exp|exp2|expm1|fabs|fdim|floor|fma|fmax|fmin|fmod|frexp|hypot|ldexp|lgamma|log|log10|log1p|log2|lrint|lround|modf|nearbyint|pow|remainder|remquo|rint|round|scalbn|scalbln|sin|sincos|sinh|sqrt|tan|tanh|tgamma|trunc)$'

# scan_offenders: reads `nm` output ("value type name" lines) on stdin,
# prints one offending DEFINED symbol per line (deduped, sorted). $2 != "U"
# excludes undefined references (symbols merely called, not linked in) -
# only a symbol the linker actually resolved into this image counts.
scan_offenders() {
  awk -v deny="$DENY_REGEX" '$2 != "U" && $3 ~ deny { print "  " $3 }' | sort -u
}

run_assert() {
  NM="$1"
  ELF="$2"
  OFFENDERS=$("$NM" "$ELF" | scan_offenders)

  if [ -n "$OFFENDERS" ]; then
    echo "" >&2
    echo "FP=SINGLE POST-LINK ASSERT FAILED for $ELF" >&2
    echo "double-precision machinery linked into the image:" >&2
    echo "$OFFENDERS" >&2
    echo "" >&2
    echo "Every one of these is 64-bit double code GRBL core never had on" >&2
    echo "the origin AVR (double==float there). Find the call site with:" >&2
    echo "  <prefix>nm -u -A build/<platform>/<BUILD>/*.o | grep <symbol>" >&2
    echo "then fix the platform-side promotion (prelude SP libm mapping /" >&2
    echo "-fsingle-precision-constant / platform code narrowing), or build" >&2
    echo "with FP=DOUBLE if this port DECLARES double precision as a port" >&2
    echo "property (see grbl/platform/CONTRACTS.md)." >&2
    exit 1
  fi

  echo "FP=SINGLE post-link assert PASSED: no DP machinery in $ELF"
}

# --- selftest ---------------------------------------------------------------
# Style matches ci/warn_ratchet.py --selftest: construct both a POSITIVE
# (must be caught) and a NEGATIVE (must not be flagged) case, plus an
# end-to-end run through the real entry point with a fake nm, so the
# script can't silently regress to checking the wrong symbol family again.
selftest() {
  checks=0
  fail() { echo "selftest: FAIL - $1" >&2; exit 1; }
  pass_check() { checks=$((checks + 1)); }

  # Clean image: only tolerated conversions + ordinary code. Must produce
  # zero offenders.
  clean='00000000 T Reset_Handler
00000010 T main
00000020 T __aeabi_fadd
00000030 T __aeabi_f2d
00000040 T __aeabi_d2f
00000050 T __floatsidf
00000060 T __fixdfsi
00000070 T __fixunsdfsi
00000080 T __extendsfdf2
00000090 T __truncdfsf2'

  out=$(printf '%s\n' "$clean" | scan_offenders) || true
  [ -z "$out" ] || fail "clean/tolerated-conversions symbol table flagged offenders: $out"
  pass_check

  # THE DEMONSTRATED EXPLOIT: pure __aeabi_* DP arithmetic, zero generic
  # __*df3 names - what a real ARM double-arithmetic object actually
  # links. The pre-fix (generic-only) denylist reported this clean; that
  # was DEFECT 1.
  poisoned='00000000 T Reset_Handler
00000010 T main
00000020 T __aeabi_dadd
00000030 T __aeabi_dsub
00000040 T __aeabi_dmul
00000050 T __aeabi_ddiv'

  out=$(printf '%s\n' "$poisoned" | scan_offenders) || true
  [ -n "$out" ] || fail "pure __aeabi_* DP arithmetic (the demonstrated exploit) was NOT caught"
  case "$out" in *__aeabi_dadd*) : ;; *) fail "__aeabi_dadd missing from offenders" ;; esac
  case "$out" in *__aeabi_ddiv*) : ;; *) fail "__aeabi_ddiv missing from offenders" ;; esac
  pass_check

  # Generic family must still work (backward compatible with the
  # original, non-ARM-blind part of the denylist).
  generic='00000000 T __adddf3
00000010 T __divdf3'
  out=$(printf '%s\n' "$generic" | scan_offenders) || true
  [ -n "$out" ] || fail "generic __*df3 family regressed"
  pass_check

  # Undefined (U) references must not be flagged - only symbols the
  # linker actually resolved into the image count.
  undef='         U __aeabi_dadd
00000000 T main'
  out=$(printf '%s\n' "$undef" | scan_offenders) || true
  [ -z "$out" ] || fail "undefined (U) reference wrongly flagged as linked-in: $out"
  pass_check

  # Complex-double helpers (genuine computation, no __aeabi_ split).
  complexd='00000000 T __muldc3
00000010 T __divdc3'
  out=$(printf '%s\n' "$complexd" | scan_offenders) || true
  [ -n "$out" ] || fail "__muldc3/__divdc3 (complex double) not caught"
  pass_check

  # 64-bit int->double widening is denied, unlike its 32-bit sibling.
  floatdidf='00000000 T __floatdidf'
  out=$(printf '%s\n' "$floatdidf" | scan_offenders) || true
  [ -n "$out" ] || fail "__floatdidf not caught"
  pass_check

  # --- end-to-end through the real entry point, with a fake nm -------------
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  fakenm="$tmpdir/nm"
  cat > "$fakenm" <<'FAKENM'
#!/bin/sh
cat "$1.nmout"
FAKENM
  chmod +x "$fakenm"

  : > "$tmpdir/good.elf"
  printf '%s\n' "$clean" > "$tmpdir/good.elf.nmout"
  : > "$tmpdir/bad.elf"
  printf '%s\n' "$poisoned" > "$tmpdir/bad.elf.nmout"

  if "$0" "$fakenm" "$tmpdir/good.elf" >"$tmpdir/out_good" 2>&1; then
    :
  else
    fail "end-to-end PASS case exited nonzero: $(cat "$tmpdir/out_good")"
  fi
  pass_check

  if "$0" "$fakenm" "$tmpdir/bad.elf" >"$tmpdir/out_bad" 2>&1; then
    fail "end-to-end FAIL case (pure __aeabi_* DP arith) exited 0 - the exact regression this selftest guards against"
  fi
  pass_check

  echo "selftest: PASS ($checks checks)"
}

# --- entry point -------------------------------------------------------------
if [ "${1:-}" = "--selftest" ]; then
  selftest
  exit 0
fi

if [ $# -ne 2 ]; then
  echo "usage: $0 <nm-binary> <elf-file>" >&2
  echo "       $0 --selftest" >&2
  exit 2
fi

run_assert "$1" "$2"
