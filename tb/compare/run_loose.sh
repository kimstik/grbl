#!/usr/bin/env bash
# Execute one arm/mode with identical inputs and report accuracy without a policy waiver.
set -euo pipefail
arm=$1
mode=$2
extra=${3-}
mkdir -p raw
source=$(realpath source/grbl)
opts="-DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DTB_ARC_TOLERANCE=.002f $extra"
[ "$mode" != g93 ] || opts="$opts -DBEZIER_EXACT_INVERSE_TIME"
build="build/loose-$arm-$mode"
make -s -C tb/host GRBL="$source" BUILD="$build" OPT="$opts" > raw/host-build.txt 2>&1
tb="tb/host/$build/tb"
failed=0
for image in bench dump standard dyn; do
  if [ ! -f "input/elf/$mode/$image.elf" ]; then
    printf 'NOT VERIFIED: %s unavailable\n' "$image" >> raw/unavailable.txt
    failed=1
    continue
  fi
  if ! timeout 1200 nice -n 19 simavr -m atmega328p -f 16000000 "input/elf/$mode/$image.elf" > "raw/$image-simavr.txt" 2>&1; then
    printf 'FAIL: simulator %s\n' "$image" >> raw/failures.txt
    failed=1
    continue
  fi
  sed 's/\x1b\[[0-9;]*m//g; s/\.*$//' "raw/$image-simavr.txt" > "raw/$image.txt"
  if ! grep -qx done "raw/$image.txt"; then
    printf 'FAIL: incomplete %s\n' "$image" >> raw/failures.txt
    failed=1
  fi
done
cp "input/raw/corpus-$mode.txt" raw/corpus.txt
if [ -f raw/bench.txt ] && [ -f raw/dump.txt ]; then
  if ! python3 -I tb/compare/check_loose.py raw/corpus.txt raw/bench.txt --dump raw/dump.txt --output raw/metrics.json > raw/integrity.txt 2>&1; then failed=1; fi
  if ! timeout 600 nice -n 19 "$tb" --dump-report raw/corpus.txt raw/dump.txt > raw/accuracy.txt 2>&1; then failed=1; fi
  if [ "$mode" = g94 ]; then
    if ! timeout 180 nice -n 19 python3 -I tb/compare/check_loose_controls.py "$tb" raw/dump.txt > raw/controls.txt 2>&1; then failed=1; fi
  fi
fi
if [ -f raw/standard.txt ]; then
  if ! python3 -I tb/compare/check_loose.py tb/avr/lines.txt raw/standard.txt --hostile --output raw/standard-metrics.json > raw/standard-check.txt 2>&1; then failed=1; fi
fi
if [ -f raw/dyn.txt ]; then
  if ! python3 -I tb/avr/check_dyn.py raw/dyn.txt --steep > raw/dyn-check.txt 2>&1; then failed=1; fi
  if [ -f "input/elf/$mode/free-ram.txt" ]; then
    free=$(cat "input/elf/$mode/free-ram.txt")
    stack=$(awk '$1 == "stack" {print $2}' raw/dyn.txt)
    if [[ $stack =~ ^[0-9]+$ && $free =~ ^[0-9]+$ ]]; then
      printf 'stack %s free %s margin %s\n' "$stack" "$free" "$((free-stack))" > raw/stack-margin.txt
      if [ "$stack" -ge "$free" ]; then failed=1; fi
    else
      printf 'FAIL: missing production RAM or stack\n' >> raw/failures.txt
      failed=1
    fi
  else
    printf 'NOT VERIFIED: production RAM unavailable\n' >> raw/unavailable.txt
    failed=1
  fi
fi
for file in integrity accuracy controls standard-check dyn-check stack-margin failures unavailable; do
  if [ -f "raw/$file.txt" ]; then
    printf '\n%s\n' "$file"
    cat "raw/$file.txt"
    cat "raw/$file.txt" >> "$GITHUB_STEP_SUMMARY"
  fi
done
exit "$failed"
