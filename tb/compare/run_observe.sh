#!/usr/bin/env bash
# Read-only live observation and a blind control of the same AVR images.
set -euo pipefail
mode=$1
shift
arms=("$@")
[ "${#arms[@]}" -gt 0 ] || arms=(baseline prefetch compact)
[ "${arms[0]}" = baseline ]
root=$PWD
out="$root/raw/observe-$mode"
sim=$(realpath simulator/simavr)
mkdir -p "$out" build

git -C simulator rev-parse HEAD > "$out/simulator.txt"
test "$(cat "$out/simulator.txt")" = 13d4ed32433ad7a37bb757b7e0f7dbb5373396c0
gcc --version > "$out/host-compiler.txt"
make -s -C "$sim" CC=gcc obj config > "$out/simulator-build.txt" 2>&1
make -s -j2 -C "$sim" CC=gcc libsimavr >> "$out/simulator-build.txt" 2>&1
gcc -std=c99 -O2 -Wall -Wextra -Werror -I"$sim/sim" \
  tb/avr/observe.c "$sim/obj-$(gcc -dumpmachine)/libsimavr.a" \
  $(pkg-config --libs libelf) -lm -o build/observe > "$out/observer-build.txt" 2>&1
sha256sum tb/avr/observe.c build/observe > "$out/observer-sha256.txt"

for arm in "${arms[@]}"; do
  dir="$out/$arm"
  input="$root/input/$arm"
  elf="$input/elf/$mode/observer.elf"
  mkdir -p "$dir"
  test -f "$elf"
  cp "$input/raw/source.txt" "$input/raw/compiler.txt" "$dir/"
  cp "$input/raw/observer-disassembly-$mode.txt" "$dir/disassembly.txt"
  cp "$input/raw/observer-symbols-$mode.txt" "$dir/symbols.txt"
  sha256sum "$elf" > "$dir/elf-sha256.txt"
  for control in observed blind; do
    args=()
    case $arm in square|workspace) args+=(--net-abi) ;; esac
    [ "$control" != blind ] || args+=(--blind)
    timeout 360 nice -n 19 build/observe "$elf" "$dir/$control.txt" \
      "$dir/$control-uart.txt" 600000000 "${args[@]}" > "$dir/$control-run.txt" 2>&1
  done
  baseline=()
  if [ "$arm" != baseline ]; then
    reference=baseline
    if [ "$arm" = refill ]; then
      reference=fixed
      cmp "$root/input/refill/raw/refill-off-$mode.hex" "$root/input/fixed/raw/production-$mode.hex"
      printf 'REFILL-off image identical to fixed %s\n' "$mode" > "$dir/refill-identity.txt"
    fi
    if [ "$arm" = seed ]; then
      reference=refill
      cmp "$root/input/seed/raw/seed-off-$mode.hex" "$root/input/refill/raw/production-$mode.hex"
      printf 'SEED-off image identical to refill %s\n' "$mode" > "$dir/seed-identity.txt"
    fi
    if [ "$arm" = workspace ]; then
      reference=square
      cmp "$root/input/workspace/raw/workspace-off-$mode.hex" "$root/input/square/raw/production-$mode.hex"
      printf 'WORKSPACE-off image identical to square %s\n' "$mode" > "$dir/workspace-identity.txt"
    fi
    baseline=(--baseline "$out/$reference/observed.txt" \
      --baseline-uart "$out/$reference/observed-uart.txt")
    case $arm in
      quadrature|fixed|seed|square) baseline+=(--xy-only) ;;
      refill|workspace) ;; # Scheduling/storage only: require full target identity.
      *) baseline+=(--require-prefetch) ;;
    esac
  fi
  python3 -I tb/compare/check_observe.py "$dir/observed.txt" "$dir/observed-uart.txt" \
    --blind "$dir/blind.txt" --blind-uart "$dir/blind-uart.txt" \
    "${baseline[@]}" --output "$dir/metrics.json" > "$dir/check.txt" 2>&1
  cat "$dir/check.txt"
  cat "$dir/check.txt" >> "$GITHUB_STEP_SUMMARY"
  if [ "$arm" = baseline ]; then
    python3 -I tb/compare/check_observe_controls.py "$dir" > "$dir/controls.txt" 2>&1
    cat "$dir/controls.txt"
  fi
done
