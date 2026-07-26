#!/usr/bin/env bash
# smoke.sh - CI smoke test for the GRBL SAMD21 port under Renode.
#
# Boots build/grbl_samd21_dbg.elf on an emulated ATSAMD21G18A
# (ci/renode/samd21_grbl.repl), asserts the "Grbl 1.1h" banner on the
# SERCOM3 UART, then sends "$$" and asserts the settings dump.
#
# Environment overrides:
#   RENODE           renode launcher (default: "renode" on PATH)
#   ELF              elf to boot (default: build/grbl_samd21_dbg.elf; built
#                    automatically when missing)
#   UART_PORT        TCP port for the UART socket terminal (default: 3456)
#   MON_PORT         TCP port for the Renode monitor (default: 3457)
#   BANNER_TIMEOUT   seconds to wait for the banner (default: 90)
#   SMOKE_BANNER_ONLY=1  skip the "$$" settings check
#   SMOKE_MOTION=1   (or pass --motion) also run the motion stage:
#                    G91 + G0 X1, '?' polling, assert MPos X reaches 1.000
#   SMOKE_ARC=1      (or pass --arc; implies --motion) also run the FP
#                    precision arbiter stage: G2 X2 I1 F200 semicircle +
#                    G4 P0.5 dwell. This is the runtime proof behind
#                    CONTRACTS #17 FP=SINGLE - arcs are the only core path
#                    that calls atan2/sqrt/cos/sin.
#   SMOKE_SPINDLE=1  (or pass --spindle) also run the BUG #22
#                    register-observability stage: M3 S-words strictly
#                    inside the $30/$31 linear rpm range, TCC0 CC[0] read
#                    back over the Renode monitor and checked against
#                    spindle_control.c's own RPM->PWM formula.
#   BOARD            samd21 board whose config.h supplies
#                    SPINDLE_PWM_MAX_VALUE/MIN_VALUE for the spindle stage
#                    (default: megarm, matching grbl/platform/samd21/Makefile)
#
# Exit code: 0 on success (banner + settings [+ motion] [+ arc] [+ spindle]),
# non-zero otherwise.

set -u

for arg in "$@"; do
  case "$arg" in
    --motion) SMOKE_MOTION=1 ;;
    --arc) SMOKE_ARC=1; SMOKE_MOTION=1 ;;
    --spindle) SMOKE_SPINDLE=1 ;;
    *) echo "smoke.sh: unknown argument '$arg'" >&2; exit 3 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

RENODE="${RENODE:-renode}"
ELF="${ELF:-build/grbl_samd21_dbg.elf}"
UART_PORT="${UART_PORT:-3456}"
MON_PORT="${MON_PORT:-3457}"
BANNER_TIMEOUT="${BANNER_TIMEOUT:-90}"
BOARD="${BOARD:-megarm}"
LOG_DIR="${LOG_DIR:-build/smoke}"
mkdir -p "$LOG_DIR"

if ! command -v "$RENODE" >/dev/null 2>&1 && [ ! -x "$RENODE" ]; then
  echo "smoke.sh: renode not found ('$RENODE'); set RENODE=/path/to/renode" >&2
  exit 3
fi

if [ ! -f "$ELF" ]; then
  echo "smoke.sh: $ELF missing; building it" >&2
  make -C grbl/platform/samd21 BUILD=DEBUG || exit 3
fi

BANNER_ONLY_FLAG=""
if [ "${SMOKE_BANNER_ONLY:-0}" = "1" ]; then
  BANNER_ONLY_FLAG="--banner-only"
fi
MOTION_FLAG=""
if [ "${SMOKE_MOTION:-0}" = "1" ]; then
  MOTION_FLAG="--motion"
fi
ARC_FLAG=""
if [ "${SMOKE_ARC:-0}" = "1" ]; then
  ARC_FLAG="--arc"
  SMOKE_MOTION=1
fi
SPINDLE_FLAG=""
if [ "${SMOKE_SPINDLE:-0}" = "1" ]; then
  SPINDLE_FLAG="--spindle"
fi

echo "smoke.sh: starting renode (uart=$UART_PORT monitor=$MON_PORT)"
"$RENODE" --disable-gui --plain -P "$MON_PORT" \
  -e "\$elf=@$ELF; \$uart_port=$UART_PORT; i @ci/renode/samd21_smoke.resc; start" \
  > "$LOG_DIR/renode.log" 2>&1 &
RENODE_PID=$!

cleanup() {
  kill "$RENODE_PID" 2>/dev/null
  wait "$RENODE_PID" 2>/dev/null
}
trap cleanup EXIT

python3 ci/renode/uart_probe.py \
  --uart-port "$UART_PORT" \
  --monitor-port "$MON_PORT" \
  --banner-timeout "$BANNER_TIMEOUT" \
  --board "$BOARD" \
  --transcript "$LOG_DIR/uart_transcript.txt" \
  $BANNER_ONLY_FLAG $MOTION_FLAG $ARC_FLAG $SPINDLE_FLAG
RC=$?

# Motion mode: MPos reaching 1.000 proves the TC3 stepper ISR ran, but NOT
# that step pins moved - sys_position increments even when the step-bit OR
# truncates (BUG #17 phantom motion). Require physical X STEP (PA25) writes,
# logged as XSTEP_HIGH by the PORT write hook in samd21_smoke.resc.
if [ "$RC" -eq 0 ] && [ "${SMOKE_MOTION:-0}" = "1" ]; then
  XSTEP_COUNT=$(grep -c 'XSTEP_HIGH' "$LOG_DIR/renode.log" 2>/dev/null || true)
  if [ "${XSTEP_COUNT:-0}" -gt 0 ]; then
    echo "PASS: X STEP pin (PA25) driven high $XSTEP_COUNT times during motion"
  else
    echo "FAIL: MPos advanced but X STEP pin (PA25) never went high - phantom motion (BUG #17 class)"
    RC=4
  fi
fi

if [ "$RC" -ne 0 ]; then
  echo "--- last 60 lines of renode.log ---"
  tail -n 60 "$LOG_DIR/renode.log"
fi

echo "smoke.sh: exit $RC"
exit "$RC"
