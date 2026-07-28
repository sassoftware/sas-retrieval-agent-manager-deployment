#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

: "${MONITORING_DB:=SASRetrievalAgentManagerMonitoring}"
: "${MONITORING_SCHEMA:=monitoring}"
: "${MONITORING_USER:?Set MONITORING_USER}"
: "${MONITORING_PASSWORD:?Set MONITORING_PASSWORD}"
: "${MIGRATION_USER:?Set MIGRATION_USER}"
: "${MIGRATION_PASSWORD:?Set MIGRATION_PASSWORD}"
: "${EMBEDDING_USER:?Set EMBEDDING_USER}"
: "${OTEL_USER:?Set OTEL_USER}"
: "${OTEL_PASSWORD:?Set OTEL_PASSWORD}"
: "${MONITORING_USER_ROLE:=sas_ram_user_role}"
: "${MONITORING_ADMIN_ROLE:=sas_ram_admin_role}"

create_database_if_missing "$MONITORING_DB"
ensure_role "$MONITORING_DB" "$MONITORING_USER" "$MONITORING_PASSWORD"
ensure_role "$MONITORING_DB" "$MIGRATION_USER" "$MIGRATION_PASSWORD"
ensure_role "$MONITORING_DB" "$OTEL_USER" "$OTEL_PASSWORD"
ensure_schema "$MONITORING_DB" "$MONITORING_SCHEMA"

for role in "$MONITORING_USER" "$MIGRATION_USER"; do
  grant_schema "$MONITORING_DB" "$MONITORING_SCHEMA" ALL "$role"
done
for role in "$EMBEDDING_USER" "$OTEL_USER"; do
  grant_schema "$MONITORING_DB" "$MONITORING_SCHEMA" USAGE "$role"
done
ensure_postgrest_role "$MONITORING_DB" "$MONITORING_SCHEMA" "$MONITORING_USER" "$MONITORING_USER_ROLE"
ensure_postgrest_role "$MONITORING_DB" "$MONITORING_SCHEMA" "$MONITORING_USER" "$MONITORING_ADMIN_ROLE"

printf 'Monitoring database initialization completed.\n'
