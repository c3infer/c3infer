#!/usr/bin/env bash
set -euo pipefail

SESSION="tcp_session"
PORTS=(54320 54321 54322 54323 54324 54325 54326)
NAMES=("firmware" "secure_payload" "host" "realm A" "realm B" "realm C" "realm D")
PTYS=(/tmp/firmware_pty /tmp/secure_payload_pty /tmp/host_pty /tmp/realm1_pty /tmp/realm2_pty /tmp/realm3_pty /tmp/realm4_pty)

# logs
SCREEN_LOGS=(/tmp/firmware_screen.log /tmp/secure_payload_screen.log)
TIMESTAMPED_LOGS=(firmware.log secure_payload.log)

# clean up old stuff
pkill -f "socat .* TCP-LISTEN" 2>/dev/null || true
rm -f "${PTYS[@]}" "${SCREEN_LOGS[@]}" "${TIMESTAMPED_LOGS[@]}"

# start one socat per port: PTY exists immediately; TCP side waits for QEMU
# NOTE: no 'fork' here; one PTY per port, stable link path
SOCAT_PIDS=()
for i in "${!PORTS[@]}"; do
  socat -d -d \
    PTY,link="${PTYS[$i]}",raw,echo=0,waitslave \
    TCP-LISTEN:${PORTS[$i]},reuseaddr &>/dev/null &
  SOCAT_PIDS+=($!)
done

# wait for PTY nodes to appear so 'screen' won't race
timeout_s=5
for p in "${PTYS[@]}"; do
  for ((t=0; t<timeout_s*10; t++)); do
    [[ -e "$p" ]] && break
    sleep 0.1
  done
  if [[ ! -e "$p" ]]; then
    echo "ERROR: PTY $p not created in time."
    exit 1
  fi
  chmod 666 "$p" 2>/dev/null || true
done

# ensure we clean socat on exit (optional—remove if you want them to persist)
cleanup() {
  for pid in "${SOCAT_PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
}
trap cleanup EXIT

# tmux session
tmux start-server
tmux kill-session -t "$SESSION" 2>/dev/null || true

# window 0: firmware (logged)
tmux new-session -d -s "$SESSION" -n "${NAMES[0]}" \
  "screen -L -Logfile ${SCREEN_LOGS[0]} ${PTYS[0]}"

# window 1: secure_payload (logged)
tmux new-window -t "$SESSION" -n "${NAMES[1]}" \
  "screen -L -Logfile ${SCREEN_LOGS[1]} ${PTYS[1]}"

# remaining windows: interactive
for i in 2 3 4 5 6; do
  tmux new-window -t "$SESSION" -n "${NAMES[$i]}" \
    "screen ${PTYS[$i]}"
done

# timestamped mirrors of the first two logs
: > "${TIMESTAMPED_LOGS[0]}"; : > "${TIMESTAMPED_LOGS[1]}"
( tail -F -n +0 "${SCREEN_LOGS[0]}" | ts '[%F %T]' >> "${TIMESTAMPED_LOGS[0]}" ) >/dev/null 2>&1 &
( tail -F -n +0 "${SCREEN_LOGS[1]}" | ts '[%F %T]' >> "${TIMESTAMPED_LOGS[1]}" ) >/dev/null 2>&1 &

tmux attach -t "$SESSION"
