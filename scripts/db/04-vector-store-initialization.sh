#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

: "${VECTOR_STORE_DB:=SASRetrievalAgentManagerVector}"
: "${VECTOR_STORE_SCHEMA:=vectorstore}"
: "${VECTOR_STORE_USER:?Set VECTOR_STORE_USER}"
: "${VECTOR_STORE_PASSWORD:?Set VECTOR_STORE_PASSWORD}"

create_database_if_missing "$VECTOR_STORE_DB"
ensure_role "$VECTOR_STORE_DB" "$VECTOR_STORE_USER" "$VECTOR_STORE_PASSWORD"
ensure_schema "$VECTOR_STORE_DB" "$VECTOR_STORE_SCHEMA" vector
grant_schema "$VECTOR_STORE_DB" "$VECTOR_STORE_SCHEMA" ALL "$VECTOR_STORE_USER"

printf 'Vector store database initialization completed.\n'
