#!/usr/bin/env bash
# One cached local candidate, one frozen control, two actual feed modes.
set -euo pipefail
mode=$1
stage=$2
root=$PWD
opts='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM -DTB_Z_FIXED_24'
case $mode in
  g94) ;;
  g93) opts="$opts -DBEZIER_EXACT_INVERSE_TIME" ;;
  *) exit 2 ;;
esac
if [ "$stage" = build ]; then
  mkdir -p raw
  avr-gcc --version > raw/compiler.txt
  pacman -Q avr-gcc avr-binutils avr-libc > raw/packages.txt
  python3 -I tb/compare/render.py tb/compare/local.in raw/corpus.txt --mode "${mode^^}"
  for arm in control candidate; do
    source=$root; extra=-DBEZIER_LOCAL_LENGTH
    if [ "$arm" = control ]; then source=$root/control; extra=''; fi
    out=$root/raw/$arm
    mkdir -p "$out/production"
    git -C "$source" rev-parse HEAD > "$out/source.txt"
    printf '%s\n' "$opts $extra" > "$out/options.txt"
    cc=$(make -s -C "$source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
    nice -n 19 make -s -C "$source" BUILDDIR="$out/production" COMPILE="$cc $opts $extra" > "$out/production-build.txt" 2>&1
    cp "$out/production/main.elf" "$out/production.elf"
    avr-size "$out/production.elf" > "$out/size.txt"
    avr-nm -S --size-sort "$out/production.elf" > "$out/symbols.txt"
    avr-objdump -d "$out/production.elf" > "$out/disassembly.txt"
    for image in bench dump; do
      target=all; [ "$image" != dump ] || target=dump
      nice -n 19 make -s -C "$source/tb/avr" BUILD="$out/$image-build" LINES="$root/raw/corpus.txt" DEFS="$opts $extra -DTB_ARC_TOLERANCE=.002f" "$target" > "$out/$image-build.txt" 2>&1
      cp "$out/$image-build/$image.elf" "$out/$image.elf"
      avr-size "$out/$image.elf" > "$out/$image-size.txt"
    done
  done
  # The default-off firmware must remain byte-identical to the frozen control.
  mkdir -p "build/local-off-$mode"
  cc=$(make -s --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
  nice -n 19 make -s BUILDDIR="$root/build/local-off-$mode" COMPILE="$cc $opts" > raw/off-build.txt 2>&1
  cmp "build/local-off-$mode/main.elf" raw/control/production.elf
  printf 'default-off ELF identical\n' > raw/off-identity.txt
  exit 0
fi
[ "$stage" = run ] || exit 2
for arm in control candidate; do
  for image in bench dump; do
    timeout 600 nice -n 19 simavr -m atmega328p -f 16000000 "raw/$arm/$image.elf" > "raw/$arm/$image-simavr.txt" 2>&1
  done
done
python3 -I tb/compare/local.py raw "$mode" > raw/comparison.json
cat raw/comparison.json >> "$GITHUB_STEP_SUMMARY"
