#!/bin/sh
# One bounded, reproducible Wang/adaptive comparison. Run from the repository root.
# Usage: sh tb/compare/adaptive.sh .002 .004 [xy|zl|g93] [core|stress|cap|invalid]
# SIMRUN may name a local simavr wrapper taking ELF OUTPUT; otherwise simavr is used.
set -u
TOL=${1:-.002}
SIGMA=${2:-.004}
MODE=${3:-xy}
CORPUS=${4:-core}
TAG=$(printf '%s-%s-%s' "$TOL" "$MODE" "$CORPUS" | tr '.' '_')
OUT=tb/compare/build/$TAG
mkdir -p "$OUT"
case $MODE in
  xy) zopt=''; render='' ;;
  zl) zopt='-DBEZIER_Z_LINEAR=2'; render='--z' ;;
  g93) zopt='-DBEZIER_Z_LINEAR=2 -DBEZIER_EXACT_INVERSE_TIME'; render='--z --mode G93' ;;
  *) printf 'unknown mode: %s\n' "$MODE" >&2; exit 2 ;;
esac
python tb/compare/render.py "tb/compare/$CORPUS.in" "$OUT/lines.txt" $render || exit
CCLINE=${CCLINE:-$(make -s --no-print-directory --eval 'print-compile: ; @echo $(COMPILE)' print-compile)}
status=0
run_sim() {
  if [ -n "${SIMRUN:-}" ]; then
    timeout 300 nice -n 19 sh "$SIMRUN" "$1" "$2"
  else
    timeout 300 nice -n 19 simavr -m atmega328p -f 16000000 "$1" > "$2" 2>&1
  fi
  # Preserve raw output and remove only simavr's terminal colour and trailing dots.
  python -c 'import re,sys; from pathlib import Path; s=Path(sys.argv[1]).read_text(errors="replace"); s=re.sub(r"\x1b\[[0-9;]*m", "", s); Path(sys.argv[2]).write_text("\n".join(x.rstrip(".") for x in s.splitlines())+"\n")' "$2" "$2.clean"
  if ! python -c 'import sys; from pathlib import Path; sys.exit("done" not in Path(sys.argv[1]).read_text().splitlines())' "$2.clean"; then
    printf 'simulation did not reach done: %s\n' "$2" >&2; return 1
  fi
}
for kind in wang adaptive; do
  extra=''
  [ "$kind" = adaptive ] && extra='-DBEZIER_ADAPTIVE_LINES -DBEZIER_ADAPTIVE_TRACE'
  defs="-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=${SIGMA}f -DTB_ARC_TOLERANCE=${TOL}f -DTB_XY_BUDGET=${SIGMA}f $zopt $extra"
  build=build/compare-$TAG-$kind
  printf '%s\n' "$CCLINE $defs" > "$OUT/$kind.flags"
  timeout 300 nice -n 19 make -s -C tb/host BUILD="$build" OPT="$defs" > "$OUT/$kind.host-build" 2>&1 || { status=1; continue; }
  timeout 300 nice -n 19 make -s -C tb/avr BUILD="$build" COMPILE="$CCLINE" LINES="../../$OUT/lines.txt" DEFS="$defs" all dump > "$OUT/$kind.avr-build" 2>&1
  built=$?
  # A link/fit failure is data, not a reason to run a stale ELF or hide an overflow.
  if [ $built -ne 0 ]; then
    printf '%s: AVR build does not complete/fit; see %s\n' "$kind" "$OUT/$kind.avr-build"
    status=1
    continue
  fi
  run_sim "tb/avr/$build/bench.elf" "$OUT/$kind.cycles" || { status=1; continue; }
  run_sim "tb/avr/$build/dump.elf" "$OUT/$kind.dump" || { status=1; continue; }
  timeout 300 nice -n 19 "tb/host/$build/tb" --hash "$OUT/lines.txt" > "$OUT/$kind.host-hash"
  timeout 300 nice -n 19 "tb/host/$build/tb" --dump-strict "$OUT/lines.txt" "$OUT/$kind.dump.clean" > "$OUT/$kind.strict" 2>&1 || status=1
  printf '%s: %s\n' "$kind" "$OUT/$kind.strict"
done
exit $status
