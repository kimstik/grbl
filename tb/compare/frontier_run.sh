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
make -s -j1 -C "$sim" CC=gcc libsimavr >> raw/simulator-build.txt 2>&1
gcc -std=c99 -Wall -Wextra -O2 -I"$sim/sim" $(pkg-config --cflags libelf) \
  tb/avr/frontier.c "$sim/obj-$(gcc -dumpmachine)/libsimavr.a" $(pkg-config --libs libelf) -lm -o build/frontier > raw/observer-build.txt 2>&1
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE -DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM'
pacman -Q avr-gcc avr-binutils avr-libc > raw/toolchain-packages.txt
git rev-parse HEAD > raw/harness.txt
for arm in fixed24 fixed32; do
  mkdir -p "raw/$arm"
  extra=-DTB_Z_FIXED_24
  source=$root/source
  expected=d93935e3905e921e08fbcba16539ae062564e1b0a9e44ae97e7e1c7fa84d9278
  if [ "$arm" = fixed32 ]; then
    source=$root/fixed32
    extra=-DTB_Z_FIXED_32
    expected=2b46172047ba4089144fd90e905c15e01c4b948210f0ffe62b4a98fdbb8554f2
  fi
  git -C "$source" rev-parse HEAD > "raw/$arm/source.txt"
  cc=$(make -s --no-print-directory -C "$source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
  mkdir -p "$source/build/$arm"
  printf '%s\n' "$common $extra" > "raw/$arm/options.txt"
  make -s -C "$source" BUILDDIR="build/$arm" COMPILE="$cc $common $extra" "build/$arm/main.elf" > "raw/$arm/production-build.txt" 2>&1
  cp "$source/build/$arm/main.elf" "raw/$arm/production.elf"
  avr-size "raw/$arm/production.elf" > "raw/$arm/production-size.txt"
  set -- $(avr-size "raw/$arm/production.elf" | tail -1)
  test $(($1 + $2)) -le 32768
  printf 'flash %s boot_margin %s\n' "$(($1 + $2))" "$((32256 - $1 - $2))" > "raw/$arm/flash-gate.txt"
  # Exact bytes from the saved bounded production image, checked before simulation.
  printf '%s  %s\n' "$expected" "raw/$arm/production.elf" | sha256sum --check > "raw/$arm/production-identity.txt"
  make -s -C tb/avr ROOT="$source" BUILD="build/frontier-$arm" DEFS="$common $extra -DTB_ARC_TOLERANCE=.002f -DTB_DYN_SPLINES_ONLY -DTB_DYN_FRONTIER_ONLY" dyn > "raw/$arm/build.txt" 2>&1
  elf="tb/avr/build/frontier-$arm/dyn.elf"
  cp "$elf" "raw/$arm/dyn.elf"
  avr-size "$elf" > "raw/$arm/dyn-size.txt"
  avr-objdump -d "$elf" > "raw/$arm/disassembly.txt"
  avr-nm -n "$elf" > "raw/$arm/symbols.txt"
  sha256sum "$elf" > "raw/$arm/elf-sha256.txt"
  python3 -I tb/compare/frontier_map.py "$elf" "raw/$arm/pc.txt" > "raw/$arm/map-check.txt"
  # Compile source layout assertions separately, never link them into dyn.elf.
  cp "$source/grbl/stepper.c" "raw/$arm/layout.c"
  cat >> "raw/$arm/layout.c" <<'C'
#include <stddef.h>
_Static_assert(offsetof(settings_t,stepper_idle_lock_time)==0x33,"idle setting offset");
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
  python3 -I tb/compare/frontier_check.py "raw/$arm" > "raw/$arm/classify.txt"
done
