#!/usr/bin/env bash
# =============================================================================
# run-bootstrap-gpg.sh  —  Linux / macOS wrapper
#
# Builds (if needed) and runs the bootstrap-gpg container.
# All arguments are passed through to bootstrap-gpg.sh inside the container.
#
# Usage:
#   ./run-bootstrap-gpg.sh --release <release>
#
# The kubeconfig at ~/.kube/config is mounted read-only into the container.
# To use a different kubeconfig, set KUBECONFIG_PATH before running:
#   KUBECONFIG_PATH=/path/to/kubeconfig ./run-bootstrap-gpg.sh ...
# =============================================================================

set -euo pipefail

IMAGE_NAME="ram-bootstrap-gpg"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KUBECONFIG_PATH="${KUBECONFIG_PATH:-${HOME}/.kube/config}"

# ── build image if not present ────────────────────────────────────────────────

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "Image '${IMAGE_NAME}' not found — building..."
  docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
  echo "Image built."
fi

# ── run ───────────────────────────────────────────────────────────────────────

if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
  echo "❌ Kubeconfig not found at: ${KUBECONFIG_PATH}" >&2
  echo "   Set KUBECONFIG_PATH to the correct path and re-run." >&2
  exit 1
fi

mkdir -p "${SCRIPT_DIR}/output"

docker run --rm -it \
  -v "${KUBECONFIG_PATH}:/root/.kube/config:ro" \
  -v "${SCRIPT_DIR}/output:/output" \
  "${IMAGE_NAME}" \
  "$@"
