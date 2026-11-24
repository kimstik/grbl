#!/usr/bin/env bash
# Build one frozen arm with the shared harness. Run from the harness root.
set -euo pipefail
arm=$1
extra=${2-}
source=$(realpath source)
root=$PWD
mkdir -p raw elf build
avr-gcc --version > raw/compiler.txt
avr-ld --version > raw/linker.txt
git -C source rev-parse HEAD > raw/source.txt
git rev-parse HEAD > raw/harness.txt
cc=$(make -s --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE'
printf 'arm mode flash ram free_ram boot_margin fits_32k fits_boot\n' > raw/sizes.txt
failed=0
for mode in g94 g93; do
  inverse=''; [ "$mode" != g93 ] || inverse=-DBEZIER_EXACT_INVERSE_TIME
  opts="$common $inverse"
  mkdir -p "elf/$mode" "source/build"
  # With the experiment disabled, each arm must retain the baseline image.
  make -s clean > "raw/identity-base-$mode.log" 2>&1
  make -s COMPILE="$cc $opts" >> "raw/identity-base-$mode.log" 2>&1
  cp grbl.hex "raw/baseline-$mode.hex"
  make -s -C source clean > "raw/identity-arm-$mode.log" 2>&1
  make -s -C source COMPILE="$cc $opts" >> "raw/identity-arm-$mode.log" 2>&1
  cmp "raw/baseline-$mode.hex" source/grbl.hex
  printf '%s %s macro-off identical\n' "$arm" "$mode" >> raw/identity.txt

  if [ "$arm" = refill ]; then
    # The scheduling gate alone must leave the fixed policy's image unchanged.
    make -s -C source clean > "raw/refill-off-$mode.log" 2>&1
    make -s -C source COMPILE="$cc $opts -DBEZIER_Z_FIXED" >> "raw/refill-off-$mode.log" 2>&1
    cp source/grbl.hex "raw/refill-off-$mode.hex"
  fi

  make -s -C source clean > "raw/production-$mode.log" 2>&1
  if make -s -C source COMPILE="$cc $opts $extra" >> "raw/production-$mode.log" 2>&1; then
    cp source/build/main.elf "elf/$mode/firmware.elf"
    cp source/grbl.hex "raw/production-$mode.hex"
    avr-nm -n -S "elf/$mode/firmware.elf" > "raw/production-symbols-$mode.txt"
    avr-objdump -d "elf/$mode/firmware.elf" > "raw/production-disassembly-$mode.txt"
    set -- $(avr-size source/build/main.elf | tail -1)
    flash=$(($1+$2)); ram=$(($2+$3))
    fit=no; [ "$flash" -gt 32768 ] || fit=yes
    boot=no; [ "$flash" -gt 32256 ] || boot=yes
    printf '%s %s %s %s %s %s %s %s\n' "$arm" "$mode" "$flash" "$ram" "$((2048-ram))" "$((32256-flash))" "$fit" "$boot" >> raw/sizes.txt
    printf '%s\n' "$((2048-ram))" > "elf/$mode/free-ram.txt"
  else
    printf '%s %s link-failed\n' "$arm" "$mode" >> raw/sizes.txt
    failed=1
  fi

  python3 -I tb/compare/render.py tb/compare/loose.in "raw/corpus-$mode.txt" --mode "${mode^^}"
  defs="$opts $extra -DTB_ARC_TOLERANCE=.002f"
  for image in bench dump standard dyn observer; do
    target=all; lines="$root/raw/corpus-$mode.txt"; flags=$defs
    case $image in
      dump) target=dump ;;
      standard) lines="$root/tb/avr/lines.txt" ;;
      dyn) target=dyn; flags="$flags -DTB_DYN_SPLINES_ONLY" ;;
      observer) target=dyn; flags="$flags -DTB_DYN_SPLINES_ONLY -DTB_DYN_OBSERVE" ;;
    esac
    dir="build/loose-$arm-$mode-$image"
    if make -s -C tb/avr ROOT="$source" BUILD="$dir" LINES="$lines" DEFS="$flags" "$target" > "raw/build-$mode-$image.log" 2>&1; then
      built=$image; case $image in bench|standard) built=bench ;; observer) built=dyn ;; esac
      cp "tb/avr/$dir/$built.elf" "elf/$mode/$image.elf"
      avr-size "elf/$mode/$image.elf" >> raw/bench-sizes.txt
      if [ "$image" = observer ]; then
        avr-nm -n -S "elf/$mode/$image.elf" > "raw/observer-symbols-$mode.txt"
        avr-objdump -d "elf/$mode/$image.elf" > "raw/observer-disassembly-$mode.txt"
        sha256sum "elf/$mode/$image.elf" > "raw/observer-sha256-$mode.txt"
      fi
    else
      printf '%s %s unavailable\n' "$mode" "$image" >> raw/unavailable.txt
      failed=1
    fi
  done
done
cat raw/sizes.txt
cat raw/sizes.txt >> "$GITHUB_STEP_SUMMARY"
exit "$failed"
