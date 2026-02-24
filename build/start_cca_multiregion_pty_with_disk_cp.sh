#!/usr/bin/env bash
set -euo pipefail

SESSION="tcp_session"
PORTS=(54319 54320 54321 54322 54323 54324 54325)
NAMES=("firmware" "secure_payload" "host" "realm A" "realm B" "realm C" "realm D")
PTYS=(/tmp/firmware_pty /tmp/secure_payload_pty /tmp/host_pty /tmp/realm1_pty /tmp/realm2_pty /tmp/realm3_pty /tmp/realm4_pty)

# screen raw logs (in /tmp) + timestamped mirrors (in cwd)
# SCREEN_LOGS=(/tmp/firmware_screen.log /tmp/secure_payload_screen.log)
SCREEN_LOGS=(firmware.log secure_payload.log)

cleanup() {
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  pkill -P $$ 2>/dev/null || true
  rm -f "${PTYS[@]}"
}
trap cleanup INT TERM EXIT

# kill old session + free ports
tmux kill-session -t "$SESSION" 2>/dev/null || true
for p in "${PORTS[@]}"; do fuser -k -n tcp "$p" >/dev/null 2>&1 || true; done
rm -f "${PTYS[@]}" "${SCREEN_LOGS[@]}"

# Sync latest debos disk image into out-br/images if changed.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_IMG="${DEBOS_OUT_IMG:-${SCRIPT_DIR}/../debos-fs/out/rootfs.img}"
if [[ -f "${SRC_IMG}" ]]; then
  IMAGES_DIR="${SCRIPT_DIR}/../out-br/images"
  mkdir -p "${IMAGES_DIR}"

  for name in rootfs1.img rootfs2.img rootfs3.img; do
    dst="${IMAGES_DIR}/${name}"
    if [[ -f "${dst}" ]] && cmp -s "${SRC_IMG}" "${dst}"; then
      echo "${name} unchanged; keeping ${dst}"
    else
      cp -f "${SRC_IMG}" "${dst}"
      echo "${name} updated from ${SRC_IMG} -> ${dst}"
    fi
  done
else
  echo "WARN: source disk image not found: ${SRC_IMG}"
fi

# start socat listeners (respawn); bind to IPv4 loopback
for i in "${!PORTS[@]}"; do
  (
    while true; do
      socat \
        PTY,link="${PTYS[$i]}",raw,echo=0 \
        TCP-LISTEN:${PORTS[$i]},reuseaddr,bind=127.0.0.1 \
        >/dev/null 2>&1
      sleep 0.2
    done
  ) &
done

# wait for PTYs
for p in "${PTYS[@]}"; do
  for _ in {1..100}; do [[ -e "$p" ]] && break; sleep 0.1; done
  [[ -e "$p" ]] || { echo "ERROR: PTY $p not created"; exit 1; }
  chmod 666 "$p" 2>/dev/null || true
done

# tmux + screen
tmux new-session -d -s "$SESSION" -n "${NAMES[0]}" \
  "screen -L -Logfile ${SCREEN_LOGS[0]} ${PTYS[0]}"
tmux new-window -t "$SESSION" -n "${NAMES[1]}" \
  "screen -L -Logfile ${SCREEN_LOGS[1]} ${PTYS[1]}"

for i in 2 3 4 5 6; do
  tmux new-window -t "$SESSION" -n "${NAMES[$i]}" "screen ${PTYS[$i]}"
done

tmux attach -t "$SESSION"
