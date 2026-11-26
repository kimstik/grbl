#!/usr/bin/env bash
# Build/run only four cases. Exact chords are a diagnostic latency control.
set -euo pipefail
arm=$1
mode=$2
stage=$3
mkdir -p raw build
raw=$(realpath raw)
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM'
case $arm in
  fixed16) extra='' ;;
  gauss) extra=-DBEZIER_Z_GAUSS ;;
  *) exit 2 ;;
esac
case $mode in
  g94) inverse='' ;;
  g93) inverse=-DBEZIER_EXACT_INVERSE_TIME ;;
  *) exit 2 ;;
esac
opts="$common $extra $inverse"
if [ "$stage" = build ]; then
avr-gcc --version > raw/compiler.txt
pacman -Q avr-gcc avr-binutils avr-libc > raw/toolchain-packages.txt
git rev-parse HEAD > raw/source.txt
printf '%s\n' "$opts" > raw/options.txt
cc=$(make -s --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
nice -n 19 make -s COMPILE="$cc $opts" > raw/production-build.txt 2>&1
cp build/main.elf raw/production.elf
avr-size raw/production.elf > raw/production-size.txt
avr-nm -n raw/production.elf > raw/production-symbols.txt
python3 -I tb/compare/render.py tb/compare/bounded.in raw/corpus.txt --mode "${mode^^}"
for image in bench dump; do
  target=all; [ "$image" != dump ] || target=dump
  dir="build/bounded-$arm-$mode-$image"
  nice -n 19 make -s -C tb/avr BUILD="$dir" LINES="$raw/corpus.txt" DEFS="$opts -DTB_ARC_TOLERANCE=.002f" "$target" > "raw/build-$image.txt" 2>&1
  cp "tb/avr/$dir/$image.elf" "raw/$image.elf"
  avr-nm -n "raw/$image.elf" > "raw/$image-symbols.txt"
  avr-size "raw/$image.elf" > "raw/$image-size.txt"
done
exit 0
fi
[ "$stage" = run ] || exit 2
dpkg-query -W simavr > raw/simulator-package.txt
for image in bench dump; do
  timeout 600 nice -n 19 simavr -m atmega328p -f 16000000 "raw/$image.elf" > "raw/$image-simavr.txt" 2>&1
  sed 's/\x1b\[[0-9;]*m//g; s/\.*$//' "raw/$image-simavr.txt" > "raw/$image.txt"
done
# Reuse the frozen comparison host's raw XY report; source stays this experiment.
source=$(realpath grbl)
git -C harness rev-parse HEAD > raw/harness.txt
dir="build/bounded-$arm-$mode"
nice -n 19 make -s -C harness/tb/host GRBL="$source" BUILD="$dir" OPT="$opts -DTB_ARC_TOLERANCE=.002f" > raw/host-build.txt 2>&1
timeout 180 nice -n 19 "harness/tb/host/$dir/tb" --dump-report raw/corpus.txt raw/dump.txt > raw/xy-report.txt
python3 -I tb/compare/bounded.py raw --mode "$mode" > raw/report.txt
cat raw/production-size.txt raw/xy-report.txt raw/report.txt >> "$GITHUB_STEP_SUMMARY"
