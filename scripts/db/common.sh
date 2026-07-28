#!/usr/bin/env bash
set -euo pipefail

# Connection settings are deliberately supplied by the caller. Do not put
# passwords in this file or in a checked-in environment file.
: "${DB_HOST:?Set DB_HOST to the PostgreSQL host}"
: "${DB_PORT:=5432}"
: "${DB_SSL_MODE:=require}"
: "${DB_ADMIN_USER:?Set DB_ADMIN_USER to a PostgreSQL administrator}"
: "${DB_ADMIN_PASSWORD:?Set DB_ADMIN_PASSWORD without putting it in source control}"

export PGHOST="$DB_HOST"
export PGPORT="$DB_PORT"
export PGUSER="$DB_ADMIN_USER"
export PGPASSWORD="$DB_ADMIN_PASSWORD"
export PGSSLMODE="$DB_SSL_MODE"

psql_admin() {
  psql -v ON_ERROR_STOP=1 "$@"
}

database_exists() {
  local database="$1"
  [[ "$(psql_admin -d postgres -Atqc 'SELECT 1 FROM pg_database WHERE datname = :'"'"'db'"'"'' -v "db=$database")" == "1" ]]
}

create_database_if_missing() {
  local database="$1"
  if database_exists "$database"; then
    printf 'Database %s already exists.\n' "$database"
    return
  fi

  printf 'Creating database %s.\n' "$database"
  psql_admin -d postgres -v db="$database" <<'SQL'
SELECT format('CREATE DATABASE %I', :'db')\gexec
SQL
}

ensure_role() {
  local database="$1"
  local role="$2"
  local password="$3"
  ROLE_PASSWORD="$password" psql_admin -d "$database" -v role="$role" <<'SQL'
\getenv role_password ROLE_PASSWORD
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = :'role') THEN
    EXECUTE format(
      'CREATE ROLE %I LOGIN NOINHERIT CREATEDB NOCREATEROLE NOSUPERUSER PASSWORD %L',
      :'role', :'role_password');
  ELSE
    EXECUTE format('ALTER ROLE %I WITH PASSWORD %L', :'role', :'role_password');
  END IF;
END
$$;
SQL
}

ensure_schema() {
  local database="$1"
  local schema="$2"
  local extension="${3:-}"
  psql_admin -d "$database" -v schema="$schema" -v extension="$extension" <<'SQL'
SELECT format('CREATE SCHEMA IF NOT EXISTS %I', :'schema')\gexec
DO $$
BEGIN
  IF :'extension' <> '' THEN
    EXECUTE format('CREATE EXTENSION IF NOT EXISTS %I SCHEMA %I', :'extension', :'schema');
  END IF;
END
$$;
SQL
}

grant_schema() {
  local database="$1"
  local schema="$2"
  local privilege="$3"
  local role="$4"
  psql_admin -d "$database" -v schema="$schema" -v privilege="$privilege" -v role="$role" <<'SQL'
SELECT format('GRANT %s ON SCHEMA %I TO %I', :'privilege', :'schema', :'role')\gexec
SQL
}

ensure_postgrest_role() {
  local database="$1"
  local schema="$2"
  local managed_user="$3"
  local role="$4"
  psql_admin -d "$database" -v schema="$schema" -v managed_user="$managed_user" -v role="$role" <<'SQL'
SELECT format('CREATE ROLE %I NOLOGIN', :'role')
WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = :'role')\gexec
SELECT format('GRANT USAGE ON SCHEMA %I TO %I', :'schema', :'role')\gexec
SELECT format('GRANT %I TO %I', :'role', :'managed_user')\gexec
SQL
}
