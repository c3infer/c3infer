#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_IMG="${OPENCCA_OUT_IMG:-${ROOT_DIR}/opencca-build/out/rootfs.img}"
IMAGES_DIR="${ROOT_DIR}/out-br/images"

if [[ ! -f "${SRC_IMG}" ]]; then
  echo "ERROR: source disk image not found: ${SRC_IMG}" >&2
  echo "Build disk first (e.g. opencca-build/debos flow), then rerun." >&2
  exit 1
fi

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

exec "${SCRIPT_DIR}/start_cca_multiregion_pty.sh"
