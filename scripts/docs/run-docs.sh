#!/usr/bin/env bash
# Starts the RAM documentation site locally with the same Ruby version as GitHub Pages.
# Usage: ./scripts/docs/run-docs.sh [starting-port]

set -euo pipefail

IMAGE_NAME="ruby:3.3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STARTING_PORT="${1:-4000}"

is_port_in_use() {
  local port="$1"

  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
    return
  fi

  if command -v ss >/dev/null 2>&1; then
    ss -ltn "sport = :${port}" | grep -q ":${port}"
    return
  fi

  return 1
}

get_available_port() {
  local port="$1"

  while is_port_in_use "${port}"; do
    port=$((port + 1))
  done

  printf '%s\n' "${port}"
}

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "Downloading Docker image '${IMAGE_NAME}'..."
  docker pull "${IMAGE_NAME}"
fi

SITE_PORT="$(get_available_port "${STARTING_PORT}")"
LIVE_RELOAD_PORT="$(get_available_port 35729)"

echo "Starting the documentation site at http://localhost:${SITE_PORT}"
echo "Use Ctrl+C to stop the local server."

docker run --rm -it \
  -p "${SITE_PORT}:4000" \
  -p "${LIVE_RELOAD_PORT}:${LIVE_RELOAD_PORT}" \
  -v "${REPOSITORY_PATH}:/site" \
  -w /site \
  "${IMAGE_NAME}" \
  bash -lc "bundle install --quiet && bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload --livereload-port ${LIVE_RELOAD_PORT} --force_polling --baseurl ''"