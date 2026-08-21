#!/usr/bin/env bash
# =============================================================================
# run-initialize-db.sh - Linux / macOS wrapper
#
# Builds (if needed) and runs the database initialization container. Variables
# already exported in the host shell are passed through to the container.
# No credential values are written into the Docker command line.
#
# Usage:
#   export DB_HOST=postgres.example.com
#   export DB_ADMIN_PASSWORD='enter-this-locally'
#   ./run-initialize-db.sh
#
# Set ENABLE_VECTOR_STORE=false to skip vector-store initialization. Additional
# arguments are passed to initialize-db.sh inside the container.
# =============================================================================

set -euo pipefail

IMAGE_NAME="ram-initialize-db"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "Image '${IMAGE_NAME}' not found - building..."
  docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
  echo "Image built."
fi

ENV_ARGS=()
for variable in \
  DB_HOST DB_PORT DB_SSL_MODE DB_ADMIN_USER DB_ADMIN_PASSWORD \
  POSTGREST_USER POSTGREST_PASSWORD MIGRATION_USER MIGRATION_PASSWORD \
  VECTORIZATION_USER VECTORIZATION_PASSWORD EMBEDDING_USER EMBEDDING_PASSWORD \
  MONITORING_USER MONITORING_PASSWORD OTEL_USER OTEL_PASSWORD \
  KEYCLOAK_USER KEYCLOAK_PASSWORD VECTOR_STORE_USER VECTOR_STORE_PASSWORD \
  APPLICATION_DB APPLICATION_SCHEMA MONITORING_DB MONITORING_SCHEMA \
  KEYCLOAK_DB KEYCLOAK_SCHEMA VECTOR_STORE_DB VECTOR_STORE_SCHEMA \
  APPLICATION_USER_ROLE APPLICATION_ADMIN_ROLE MONITORING_USER_ROLE \
  MONITORING_ADMIN_ROLE ENABLE_VECTOR_STORE; do
  if [[ -v "${variable}" ]]; then
    ENV_ARGS+=(--env "${variable}")
  fi
done

docker run --rm -it \
  "${ENV_ARGS[@]}" \
  "${IMAGE_NAME}" \
  "$@"
