#!/usr/bin/env bash
set -euo pipefail
mkdir -p raw
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM -DTB_Z_FIXED_24'
avr-gcc --version > raw/compiler.txt
pacman -Q avr-gcc avr-binutils avr-libc > raw/toolchain-packages.txt
root=$PWD
for arm in control leaf; do
  source=$root
  [ "$arm" != control ] || source=$root/control
  for mode in g94 g93; do
    out="$root/raw/$arm-$mode"
    mkdir -p "$out/objects"
    inverse=''; [ "$mode" != g93 ] || inverse=-DBEZIER_EXACT_INVERSE_TIME
    cc=$(make -s --no-print-directory -C "$source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
    git -C "$source" rev-parse HEAD > "$out/source.txt"
    printf '%s\n' "$cc $common $inverse" > "$out/options.txt"
    make -s -C "$source" BUILDDIR="$out/objects" COMPILE="$cc $common $inverse" "$out/objects/main.elf" > "$out/build.txt" 2>&1
    cp "$out/objects/main.elf" "$out/production.elf"
    avr-size "$out/production.elf" > "$out/size.txt"
    avr-nm -S --size-sort "$out/production.elf" > "$out/symbols.txt"
    avr-objdump -d "$out/production.elf" > "$out/disassembly.txt"
  done
done
