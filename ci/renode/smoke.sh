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
#
# Exit code: 0 on success (banner + settings), non-zero otherwise.

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

RENODE="${RENODE:-renode}"
ELF="${ELF:-build/grbl_samd21_dbg.elf}"
UART_PORT="${UART_PORT:-3456}"
MON_PORT="${MON_PORT:-3457}"
BANNER_TIMEOUT="${BANNER_TIMEOUT:-90}"
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
  --transcript "$LOG_DIR/uart_transcript.txt" \
  $BANNER_ONLY_FLAG
RC=$?

if [ "$RC" -ne 0 ]; then
  echo "--- last 60 lines of renode.log ---"
  tail -n 60 "$LOG_DIR/renode.log"
fi

echo "smoke.sh: exit $RC"
exit "$RC"
