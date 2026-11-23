#!/bin/sh
# mutate.sh - mutation testing of the G5/G5.1 code.
#
# Applies each mutant from mutants.txt to a copy of the firmware sources,
# rebuilds the bench and runs vectors plus random curves. A mutant the bench
# does not notice is reported as SURVIVED and the script fails, and so does one
# that runs out of time: slow is not wrong. A line "OPT<tab>flags" builds the
# mutants after it with these options (see Makefile).
# Usage: mutate.sh [MUTANT-ID]
set -u
cd "$(dirname "$0")"
GRBL=../../grbl
W=build/mut
survived=0 killed=0 opt=
tab=$(printf '\t') cr=$(printf '\r')
while IFS="$tab" read -r id file from to; do
  to=${to%"$cr"}  # mutants.txt may be checked out with CRLF
  case "$id" in ''|'#'*) continue ;; OPT) opt=${file%"$cr"}; continue ;; esac
  [ $# -gt 0 ] && [ "$1" != "$id" ] && continue
  rm -rf "$W/src" "$W/obj"; mkdir -p "$W"; cp -r "$GRBL" "$W/src"
  FROM="$from" TO="$to" perl -pi -e 's/\Q$ENV{FROM}\E/$ENV{TO}/g' "$W/src/$file"
  if cmp -s "$GRBL/$file" "$W/src/$file"; then
    echo "mutant $id: text not found in $file"; exit 2
  fi
  if ! make -s GRBL="$W/src" BUILD="$W/obj" OPT="$opt" > "$W/build.log" 2>&1; then
    echo "mutant $id: does not compile"; cat "$W/build.log"; exit 2
  fi
  timeout 600 "$W/obj/tb" vectors/*.vec > /dev/null 2>&1 &&
    timeout 600 "$W/obj/tb" --random 1000 1 > /dev/null 2>&1
  case $? in
    0) echo "mutant $id: SURVIVED"; survived=$((survived + 1)) ;;
    124) echo "mutant $id: out of time"; exit 2 ;;
    *) echo "mutant $id: killed"; killed=$((killed + 1)) ;;
  esac
done < mutants.txt
echo "mutants: $killed killed, $survived survived"
[ "$survived" -eq 0 ]
