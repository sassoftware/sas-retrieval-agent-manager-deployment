#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

: "${KEYCLOAK_DB:=SASRetrievalAgentManagerIAM}"
: "${KEYCLOAK_SCHEMA:=keycloak}"
: "${KEYCLOAK_USER:?Set KEYCLOAK_USER}"
: "${KEYCLOAK_PASSWORD:?Set KEYCLOAK_PASSWORD}"

create_database_if_missing "$KEYCLOAK_DB"
ensure_role "$KEYCLOAK_DB" "$KEYCLOAK_USER" "$KEYCLOAK_PASSWORD"
ensure_schema "$KEYCLOAK_DB" "$KEYCLOAK_SCHEMA"
grant_schema "$KEYCLOAK_DB" "$KEYCLOAK_SCHEMA" ALL "$KEYCLOAK_USER"

printf 'Keycloak database initialization completed.\n'
