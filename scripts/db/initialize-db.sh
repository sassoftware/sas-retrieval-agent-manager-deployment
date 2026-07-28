#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

printf 'Running database initialization in template order.\n'
"$SCRIPT_DIR/01-application-initialization.sh"
"$SCRIPT_DIR/02-monitoring-initialization.sh"
"$SCRIPT_DIR/03-keycloak-initialization.sh"

if [[ "${ENABLE_VECTOR_STORE:=true}" == true ]]; then
  "$SCRIPT_DIR/04-vector-store-initialization.sh"
else
  printf 'Vector store initialization disabled.\n'
fi

printf 'Database initialization completed.\n'
