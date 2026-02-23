#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEBOS_DIR="${ROOT_DIR}/debos-fs"
OPENCCA_DOCKER_DIR="${OPENCCA_DOCKER_DIR:-${ROOT_DIR}/opencca-build/docker}"
DEBOS_MODE="${DEBOS_MODE:-auto}" # auto | local | container

MODEL_URL="${MODEL_URL:-https://huggingface.co/Mungert/gpt2-GGUF/resolve/main/gpt2-q8_0.gguf}"
EXPECTED_SHA256="${MODEL_SHA256:-6029c84fa164349d9babfef32ed1c19ee1a912ea5c22bf37eeb7cbbf42cb98b8}"

MODEL_DST="${DEBOS_DIR}/overlay/root/usecases/rg_rf_ri/model.gguf"
OUT_IMG="${DEBOS_DIR}/out/rootfs.img"

if [[ ! -d "${DEBOS_DIR}" ]]; then
  echo "ERROR: debos-fs directory not found: ${DEBOS_DIR}" >&2
  echo "Make sure your manifest includes the debos-fs project." >&2
  exit 1
fi

mkdir -p "$(dirname "${MODEL_DST}")"

need_download=1
if [[ -f "${MODEL_DST}" ]]; then
  current_sha="$(sha256sum "${MODEL_DST}" | awk '{print $1}')"
  if [[ "${current_sha}" == "${EXPECTED_SHA256}" ]]; then
    need_download=0
    echo "model.gguf already present with expected checksum"
  else
    echo "model.gguf checksum mismatch, re-downloading"
    echo "  expected: ${EXPECTED_SHA256}"
    echo "  found:    ${current_sha}"
  fi
fi

if [[ "${need_download}" -eq 1 ]]; then
  tmp_file="$(mktemp /tmp/model.gguf.XXXXXX)"
  trap 'rm -f "${tmp_file}"' EXIT

  echo "Downloading model from: ${MODEL_URL}"
  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --retry 3 --output "${tmp_file}" "${MODEL_URL}"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "${tmp_file}" "${MODEL_URL}"
  else
    echo "ERROR: neither curl nor wget is installed" >&2
    exit 1
  fi

  downloaded_sha="$(sha256sum "${tmp_file}" | awk '{print $1}')"
  if [[ "${downloaded_sha}" != "${EXPECTED_SHA256}" ]]; then
    echo "ERROR: downloaded model checksum mismatch" >&2
    echo "  expected: ${EXPECTED_SHA256}" >&2
    echo "  found:    ${downloaded_sha}" >&2
    echo "Set MODEL_URL/MODEL_SHA256 to the exact model you want." >&2
    exit 1
  fi

  mv -f "${tmp_file}" "${MODEL_DST}"
  chmod 0644 "${MODEL_DST}"
  trap - EXIT
  echo "Saved model to ${MODEL_DST}"
fi

if [[ "${FORCE_REBUILD_DISK:-0}" == "1" || ! -f "${OUT_IMG}" ]]; then
  echo "Building disk image with debos-fs..."

  run_local_build() {
    (
      cd "${DEBOS_DIR}"
      ./build.sh \
        --py-enable 1 \
        --reqs-file "${DEBOS_DIR}/requirements.txt" \
        --format ext4 \
        --imgsize 2300MB \
        --console hvc0 \
        --overlay-dest / \
        --custom-script ./script.sh
    )
  }

  run_container_build() {
    if [[ ! -f "${OPENCCA_DOCKER_DIR}/Makefile" ]]; then
      echo "ERROR: opencca-build docker Makefile not found: ${OPENCCA_DOCKER_DIR}/Makefile" >&2
      echo "Set OPENCCA_DOCKER_DIR to your opencca-build/docker path." >&2
      exit 1
    fi

    make -C "${OPENCCA_DOCKER_DIR}" pull
    make -C "${OPENCCA_DOCKER_DIR}" start
    make -C "${OPENCCA_DOCKER_DIR}" run CMD="bash -lc 'cd /opencca/debos-fs && ./buildfs.sh'"
  }

  case "${DEBOS_MODE}" in
    local)
      if ! command -v debos >/dev/null 2>&1; then
        echo "ERROR: DEBOS_MODE=local but debos is not installed on host." >&2
        exit 1
      fi
      run_local_build
      ;;
    container)
      run_container_build
      ;;
    auto)
      if command -v debos >/dev/null 2>&1; then
        run_local_build
      else
        run_container_build
      fi
      ;;
    *)
      echo "ERROR: invalid DEBOS_MODE='${DEBOS_MODE}' (use auto|local|container)" >&2
      exit 1
      ;;
  esac

  echo "Disk image ready at ${OUT_IMG}"
else
  echo "Disk image already present at ${OUT_IMG}"
  echo "Set FORCE_REBUILD_DISK=1 to rebuild it."
fi
