#!/usr/bin/env bash
# One bounded ordinary-workload observation; firmware sources stay frozen.
set -euo pipefail
root=$PWD
mkdir -p raw build
avr-gcc --version > raw/compiler.txt
git -C simulator rev-parse HEAD > raw/simulator.txt
test "$(<raw/simulator.txt)" = 13d4ed32433ad7a37bb757b7e0f7dbb5373396c0
sim=$root/simulator/simavr
make -s -C "$sim" CC=gcc obj config > raw/simulator-build.txt 2>&1
make -s -j2 -C "$sim" CC=gcc libsimavr >> raw/simulator-build.txt 2>&1
gcc -std=c99 -Wall -Wextra -O2 -I"$sim/sim" $(pkg-config --cflags libelf) \
  tb/avr/frontier.c "$sim/obj-$(gcc -dumpmachine)/libsimavr.a" $(pkg-config --libs libelf) -lm -o build/frontier > raw/observer-build.txt 2>&1
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DTB_ARC_TOLERANCE=.002f -DTB_DYN_SPLINES_ONLY'
for arm in baseline norm; do
  mkdir -p "raw/$arm"
  extra=''
  if [ "$arm" = norm ]; then
    extra='-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM'
  fi
  source=$root/$arm
  git -C "$source" rev-parse HEAD > "raw/$arm/source.txt"
  cc=$(make -s --no-print-directory -C "$source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
  make -s -C frozen-harness/tb/avr ROOT="$source" BUILD="build/frontier-$arm" DEFS="$common $extra" dyn > "raw/$arm/build.txt" 2>&1
  elf="frozen-harness/tb/avr/build/frontier-$arm/dyn.elf"
  cp "$elf" "raw/$arm/dyn.elf"
  # Compare allocated ELF contents; debug/link-path records are not executed.
  avr-objcopy -O ihex "$elf" "raw/$arm/fresh.hex"
  avr-objcopy -O ihex "retained/$arm/elf/g94/dyn.elf" "raw/$arm/retained.hex"
  cmp "raw/$arm/fresh.hex" "raw/$arm/retained.hex"
  sha256sum "$elf" "retained/$arm/elf/g94/dyn.elf" > "raw/$arm/elf-sha256.txt"
  python3 -I tb/compare/frontier_map.py "$elf" "raw/$arm/pc.txt" > "raw/$arm/map-check.txt"
  # Compile source layout assertions separately, never link them into dyn.elf.
  cp "$source/grbl/stepper.c" "raw/$arm/layout.c"
  cat >> "raw/$arm/layout.c" <<'C'
#include <stddef.h>
_Static_assert(sizeof(segment_t)==7,"segment layout");
_Static_assert(sizeof(st)==35,"stepper layout");
_Static_assert(offsetof(stepper_t,exec_segment)==33,"exec segment offset");
_Static_assert(sizeof(prep)==48,"prep layout");
_Static_assert(offsetof(st_prep_t,current_speed)==23,"published speed offset");
_Static_assert(offsetof(st_prep_t,exit_speed)==31,"block exit offset");
C
  (cd "$source"; $cc $common $extra -Igrbl -c "$root/raw/$arm/layout.c" -o "$root/raw/$arm/layout.o") > "raw/$arm/layout-check.txt" 2>&1
  timeout 1000 nice -n 19 build/frontier "$elf" "raw/$arm/pc.txt" "raw/$arm/observed.txt" "raw/$arm/observed-uart.txt" > "raw/$arm/observed-run.txt" 2>&1
  timeout 1000 nice -n 19 build/frontier "$elf" "raw/$arm/pc.txt" "raw/$arm/blind.txt" "raw/$arm/blind-uart.txt" --blind > "raw/$arm/blind-run.txt" 2>&1
  python3 -I tb/compare/frontier_check.py "raw/$arm" "distro/$arm/dyn.txt" > "raw/$arm/classify.txt"
done
