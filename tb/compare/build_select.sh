#!/usr/bin/env bash
# Static production comparison only. No simulator or firmware execution.
set -euo pipefail
mode=$1
case "$mode" in g94|g93) ;; *) exit 2 ;; esac
family=${2:-selector}
case "$family" in
  selector) sources='baseline refill select'; variants='baseline macro-off refill selector-off select' ;;
  parser) sources='select frame'; variants='reference scratch-off scratch' ;;
  rms) sources='frame rms'; variants='reference rms-off rms' ;;
  chords) sources='frame chords'; variants='reference chords-off chords' ;;
  square) sources='chords square'; variants='reference square' ;;
  workspace) sources='square workspace'; variants='reference workspace-off workspace' ;;
  *) exit 2 ;;
esac
root=$PWD
out="$root/raw/$family-$mode"
mkdir -p "$out"
avr-gcc --version > "$out/compiler.txt"
avr-ld --version > "$out/linker.txt"
git rev-parse HEAD > "$out/harness.txt"
for arm in $sources; do
  git -C "$arm" rev-parse HEAD > "$out/source-$arm.txt"
done
compiler_source=select
case "$family" in rms|chords) compiler_source=frame ;; square) compiler_source=chords ;; workspace) compiler_source=square ;; esac
cc=$(make -s -C "$compiler_source" --eval 'print-compile: ; @echo $(COMPILE)' print-compile)
common='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 -DBEZIER_Z_LOOSE'
[ "$mode" != g93 ] || common="$common -DBEZIER_EXACT_INVERSE_TIME"
fixed='-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL'
printf '%s\n' "$cc $common" > "$out/compile.txt"
printf 'variant mode flash ram free_ram boot_margin full_margin normal_link\n' > "$out/sizes.txt"
for variant in $variants; do
  source=select; extra=''
  case "$variant" in
    baseline) source=baseline ;;
    refill) source=refill; extra=$fixed ;;
    selector-off) extra=$fixed ;;
    select|reference) extra="$fixed -DBEZIER_Z_SELECT" ;;
    scratch-off) source=frame; extra="$fixed -DBEZIER_Z_SELECT" ;;
    scratch) source=frame; extra="$fixed -DBEZIER_Z_SELECT -DBEZIER_PARSER_SCRATCH" ;;
    rms-off) source=rms; extra="$fixed -DBEZIER_Z_SELECT -DBEZIER_PARSER_SCRATCH" ;;
    rms) source=rms; extra="$fixed -DBEZIER_Z_SELECT -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_RMS" ;;
    chords-off) source=chords; extra="$fixed -DBEZIER_PARSER_SCRATCH" ;;
    chords) source=chords; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS" ;;
    square) source=square; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS" ;;
    workspace-off) source=workspace; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS" ;;
    workspace) source=workspace; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS -DBEZIER_PARSER_WORKSPACE" ;;
  esac
  if [ "$family" = rms ] && [ "$variant" = reference ]; then
    source=frame; extra="$fixed -DBEZIER_Z_SELECT -DBEZIER_PARSER_SCRATCH"
  elif [ "$family" = chords ] && [ "$variant" = reference ]; then
    source=frame; extra="$fixed -DBEZIER_PARSER_SCRATCH"
  elif [ "$family" = square ] && [ "$variant" = reference ]; then
    source=chords; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS"
  elif [ "$family" = workspace ] && [ "$variant" = reference ]; then
    source=square; extra="$fixed -DBEZIER_PARSER_SCRATCH -DBEZIER_Z_CHORDS"
  fi
  build="$root/build-$family/$mode/$variant"
  printf '%s\n' "$cc $common $extra" > "$out/$variant-compile.txt"
  # Never reuse artifacts from a different source or option set.
  test ! -e "$build"
  mkdir -p "$build"
  normal=yes
  if ! make -s -j1 -C "$source" BUILDDIR="$build" COMPILE="$cc $common $extra" \
      "$build/main.elf" > "$out/$variant-normal.log" 2>&1; then
    [ "$variant" = select ] || [ "$family" != selector ] || { cat "$out/$variant-normal.log"; exit 1; }
    normal=no
    # Link the same objects only to inspect size/disassembly; not a valid 328P image.
    make -s -j1 -C "$source" BUILDDIR="$build" \
      COMPILE="$cc $common $extra -Wl,--defsym=__TEXT_REGION_LENGTH__=65536" \
      "$build/main.elf" > "$out/$variant-inspection.log" 2>&1
  fi
  cp "$build/main.elf" "$out/$variant.elf"
  avr-size -B "$out/$variant.elf" > "$out/$variant-size.txt"
  avr-nm -n -S "$out/$variant.elf" > "$out/$variant-symbols.txt"
  if [ "$variant" = select ] || [ "$family" != selector ]; then
    avr-objdump -d "$out/$variant.elf" > "$out/$variant-disassembly.txt"
  else
    avr-objcopy -j .text -j .data -O ihex "$out/$variant.elf" "$out/$variant.hex"
  fi
  python3 -I - "$out" "$variant" "$mode" "$normal" <<'PY' >> "$out/sizes.txt"
from pathlib import Path
import sys
out, variant, mode, normal = Path(sys.argv[1]), *sys.argv[2:]
text, data, bss = map(int, (out / (variant + '-size.txt')).read_text().splitlines()[1].split()[:3])
flash, ram = text + data, data + bss
assert (flash <= 32768) == (normal == 'yes'), 'normal link and static size disagree'
if normal == 'no':
    log = (out / (variant + '-normal.log')).read_text()
    assert 'text' in log and ('will not fit' in log or 'overflowed by' in log), log
print(variant, mode, flash, ram, 2048 - ram, 32256 - flash, 32768 - flash, normal)
PY
done
if [ "$family" = selector ]; then
  cmp "$out/baseline.hex" "$out/macro-off.hex"
  printf '%s\n' 'macro-off: identical to frozen baseline' > "$out/identity.txt"
  cmp "$out/refill.hex" "$out/selector-off.hex"
  printf '%s\n' 'selector-off: identical to frozen refill' >> "$out/identity.txt"
elif [ "$family" = parser ]; then
  cmp "$out/reference.elf" "$out/scratch-off.elf"
  printf '%s\n' 'scratch-off: static ELF identical to frozen selector' > "$out/identity.txt"
elif [ "$family" = square ]; then
  printf '%s\n' 'square: arithmetic change; complete output identity is checked by the native job' > "$out/identity.txt"
elif [ "$family" = workspace ]; then
  cmp "$out/reference.elf" "$out/workspace-off.elf"
  printf '%s\n' 'workspace-off: static ELF identical to frozen square' > "$out/identity.txt"
else
  cmp "$out/reference.elf" "$out/$family-off.elf"
  printf '%s\n' "$family-off: static ELF identical to frozen parser scratch" > "$out/identity.txt"
fi
cat "$out/identity.txt" "$out/sizes.txt"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat "$out/identity.txt" "$out/sizes.txt" >> "$GITHUB_STEP_SUMMARY"
fi
