#!/usr/bin/env bash
# Static-only, one-factor compiler experiments. Never execute these images.
set -euo pipefail
mkdir -p raw
avr-gcc --version > raw/compiler.txt
avr-ld --version > raw/linker.txt
pacman -Q avr-gcc avr-binutils avr-libc > raw/packages.txt
git rev-parse HEAD > raw/harness.txt
printf 'arm profile mode linked flash ram boot_margin\n' > raw/sizes.txt
for arm in baseline norm; do
  source="$PWD/$arm"
  git -C "$source" rev-parse HEAD > "raw/$arm-source.txt"
  original=$(make -s -C "$source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
  extra=''
  if [ "$arm" = norm ]; then
    extra='-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE -DBEZIER_POINT_CACHE -DBEZIER_Z_NORM'
  fi
  for profile in control oz inline wide scev; do
    cc="$original"
    case "$profile" in
      oz) cc=${cc/-Os/-Oz} ;;
      inline) cc=${cc/-fno-inline-small-functions/} ;;
      wide) cc=${cc/-fno-split-wide-types/} ;;
      scev) cc=${cc/-fno-tree-scev-cprop/} ;;
    esac
    for mode in g94 g93; do
      inverse=''; [ "$mode" != g93 ] || inverse=-DBEZIER_EXACT_INVERSE_TIME
      opts="-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE $extra $inverse"
      dir="$PWD/raw/$arm-$profile-$mode"
      mkdir -p "$dir/objects"
      printf '%s\n' "$cc $opts" > "$dir/command.txt"
      # Fresh object directory: Make does not track option changes.
      if make -s -C "$source" BUILDDIR="$dir/objects" COMPILE="$cc $opts" "$dir/objects/main.elf" > "$dir/build.txt" 2>&1; then
        avr-size "$dir/objects/main.elf" > "$dir/size.txt"
        avr-nm -S --size-sort "$dir/objects/main.elf" > "$dir/symbols.txt"
        avr-objdump -d "$dir/objects/main.elf" > "$dir/disassembly.txt"
        sha256sum "$dir/objects/main.elf" > "$dir/sha256.txt"
        read -r text data bss rest < <(tail -1 "$dir/size.txt")
        printf '%s %s %s yes %s %s %s\n' "$arm" "$profile" "$mode" "$((text+data))" "$((data+bss))" "$((32256-text-data))" >> raw/sizes.txt
      else
        printf '%s %s %s no - - -\n' "$arm" "$profile" "$mode" >> raw/sizes.txt
      fi
    done
  done
done
cat raw/sizes.txt
cat raw/sizes.txt >> "$GITHUB_STEP_SUMMARY"
python3 -I - <<'PY'
from pathlib import Path
rows = [r.split() for r in Path('raw/sizes.txt').read_text().splitlines()[1:]]
assert len(rows) == 20
expected = {('baseline','g94'):31850, ('baseline','g93'):31950,
            ('norm','g94'):32322, ('norm','g93'):32458}
for r in rows:
    if r[1] == 'control':
        assert r[3] == 'yes' and int(r[4]) == expected[r[0],r[2]] and int(r[5]) == 1670, r
assert all(r[3] == 'yes' for r in rows), 'Some profiles failed normal linking; inspect retained logs'
PY
