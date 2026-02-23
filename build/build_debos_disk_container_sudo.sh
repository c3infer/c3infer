#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OPENCCA_DOCKER_DIR="${OPENCCA_DOCKER_DIR:-${ROOT_DIR}/opencca-build/docker}"

if [[ ! -f "${OPENCCA_DOCKER_DIR}/Makefile" ]]; then
  echo "ERROR: opencca-build docker Makefile not found: ${OPENCCA_DOCKER_DIR}/Makefile" >&2
  echo "Set OPENCCA_DOCKER_DIR to your opencca-build/docker path." >&2
  exit 1
fi

make -C "${OPENCCA_DOCKER_DIR}" pull
make -C "${OPENCCA_DOCKER_DIR}" start
make -C "${OPENCCA_DOCKER_DIR}" run CMD="sudo bash -lc 'cd /opencca/debos-fs && ./buildfs.sh'"
