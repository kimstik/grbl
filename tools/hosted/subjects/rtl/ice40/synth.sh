#!/bin/sh
# synth.sh - measure the executor on real iCE40 silicon models.
#
# Part of Grbl / Intelligence assisted / License: MIT
#
# Not part of any gate. It answers one question that cannot be answered by
# reading the RTL: does a 3-axis 32-bit Bresenham step in ONE clock cycle close
# timing at 48 MHz on an iCE40, and on which part. SEGMENT-RUNTIME-PLAN §4
# stage 5 flags that answer as something that must be known before the goldens
# freeze, because an HX8K fallback at a divided clock changes cycle bookkeeping.
#
#   ./synth.sh [up5k|hx8k|both] [target-MHz]     (default: both 48)
#
# Needs yosys and nextpnr-ice40. Prints the utilisation and Fmax lines from
# each and nothing else; the full logs land in build/hosted/rtl/synth/.

set -e
here=$(cd "$(dirname "$0")" && pwd)
out=$here/../../../../../build/hosted/rtl/synth
mkdir -p "$out"

which yosys >/dev/null 2>&1 || { echo "synth.sh: yosys not installed"; exit 77; }
which nextpnr-ice40 >/dev/null 2>&1 || { echo "synth.sh: nextpnr-ice40 not installed"; exit 77; }

want=${1:-both}
freq=${2:-48}

run_one() {
  part=$1; pkg=$2
  echo "=== iCE40$part ($pkg) at ${freq} MHz ================================"
  yosys -q -p "read_verilog $here/segx_ice40.v $here/../segx_top.v \
                            $here/../segx_exec.v $here/../segx_rx.v \
                            $here/../segx_slot.v $here/../segx_crc8.v; \
               synth_ice40 -top segx_ice40 -json $out/segx_$part.json" \
        -l "$out/yosys_$part.log"
  grep -A40 'Printing statistics' "$out/yosys_$part.log" | \
    grep -E 'SB_LUT4|SB_CARRY|SB_DFF|SB_RAM|Number of cells' || true

  nextpnr-ice40 --$part --package "$pkg" --freq "$freq" \
      --json "$out/segx_$part.json" --asc "$out/segx_${part}_${freq}.asc" \
      --placer heap --seed 1 > "$out/nextpnr_${part}_${freq}.log" 2>&1 || {
        echo "  nextpnr failed or missed timing; see $out/nextpnr_${part}_${freq}.log"; }
  grep -E 'Info: Device utilisation|ICESTORM_LC|ICESTORM_RAM|Max frequency for clock|Info: Max delay' \
    "$out/nextpnr_${part}_${freq}.log" || true
  echo
}

case $want in
  up5k) run_one up5k sg48 ;;
  hx8k) run_one hx8k ct256 ;;
  both) run_one up5k sg48; run_one hx8k ct256 ;;
  *) echo "usage: synth.sh [up5k|hx8k|both]"; exit 2 ;;
esac
