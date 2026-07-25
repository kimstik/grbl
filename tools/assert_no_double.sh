#!/bin/sh
#  assert_no_double.sh - post-link FP=SINGLE enforcement (grbl/platform)
#  Part of Grbl
#
#  Usage: assert_no_double.sh <nm-binary> <elf-file>
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
#  Denied (defined symbols in the ELF):
#    - DP soft-float arithmetic/compare: __adddf3..__divdf3, __*df2
#      compares, __powidf2
#    - DP libm entry points (the unsuffixed names): sqrt, atan2, sin, ...
#      plus their internal helpers (__rem_pio2, __kernel_rem_pio2, ...)
#
#  Deliberately ALLOWED: pure format conversions (__extendsfdf2,
#  __truncdfsf2, __fixdfsi, __fixunsdfsi, __floatsidf, ...). A conversion
#  cannot compute; these survive only at legacy double-typed ABI
#  boundaries (e.g. the AVR util/delay.h `_delay_ms(double)` contract,
#  which narrows at entry) and cost ~0.5KB total. Any actual DP
#  arithmetic behind such a boundary would still trip the denylist.

set -eu

if [ $# -ne 2 ]; then
  echo "usage: $0 <nm-binary> <elf-file>" >&2
  exit 2
fi

NM="$1"
ELF="$2"

OFFENDERS=$("$NM" "$ELF" | awk '
  $2 != "U" && $3 ~ /^(__adddf3|__subdf3|__muldf3|__divdf3|__negdf2|__eqdf2|__nedf2|__gtdf2|__gedf2|__ltdf2|__ledf2|__unorddf2|__powidf2|__rem_pio2|__kernel_rem_pio2|__kernel_sin|__kernel_cos|__kernel_tan|acos|asin|atan|atan2|cbrt|ceil|copysign|cos|cosh|exp|exp2|expm1|fabs|fdim|floor|fma|fmax|fmin|fmod|frexp|hypot|ldexp|lgamma|log|log10|log1p|log2|lrint|lround|modf|nearbyint|pow|remainder|remquo|rint|round|scalbn|scalbln|sin|sincos|sinh|sqrt|tan|tanh|tgamma|trunc)$/ { print "  " $3 }
' | sort -u)

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
