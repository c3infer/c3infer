#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/build_debos_disk_with_remote_gguf.sh"
exec "${SCRIPT_DIR}/start_cca_multiregion_pty_with_disk_cp.sh"
