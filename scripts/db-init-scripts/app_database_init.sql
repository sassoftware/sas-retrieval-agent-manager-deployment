-- +goose Up
-- +goose StatementBegin

/*
Preform tasks that require superuser privileges.
This script is used to create the initial database roles, users, extensions.
This script should be also executed manually by system administrators

Please note this script is intended to be run with envsustion and for this reason $$ are excaped with $$$
*/

-- START Create Users
-- Create db Migration user
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${MIGRATE_DB_USERNAME}') THEN
            CREATE ROLE "${MIGRATE_DB_USERNAME}" LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${MIGRATE_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${MIGRATE_DB_USERNAME}" PASSWORD '${MIGRATE_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;


-- Create keycloak user
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${KC_DB_USERNAME}') THEN
            CREATE ROLE "${KC_DB_USERNAME}" LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${KC_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${KC_DB_USERNAME}" PASSWORD '${KC_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;


-- Create PostgRest authenticated user (autenticator role)
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${PGREST_DB_USERNAME}') THEN
            CREATE ROLE "${PGREST_DB_USERNAME}" LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${PGREST_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${PGREST_DB_USERNAME}" PASSWORD '${PGREST_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;


-- Create esp vectorization hub user
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${VJOB_DB_USERNAME}') THEN
            CREATE ROLE "${VJOB_DB_USERNAME}" LOGIN NOINHERIT CREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${VJOB_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${VJOB_DB_USERNAME}" PASSWORD '${VJOB_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;

-- Create embedding model user
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${EMBEDDING_DB_USERNAME}') THEN
            CREATE ROLE "${EMBEDDING_DB_USERNAME}" LOGIN NOINHERIT CREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${EMBEDDING_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${EMBEDDING_DB_USERNAME}" PASSWORD '${EMBEDDING_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;
-- END Create Users

-- START Create Roles
-- create db role for super administrators
DO $$
BEGIN
-- +goose ENVSUB ON
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${DB_AUTH_ROLE_ADMINS}') THEN
        CREATE ROLE "${DB_AUTH_ROLE_ADMINS}" NOLOGIN;
    END IF;
-- +goose ENVSUB OFF
END
$$;

-- create db role for user
DO $$
BEGIN
-- +goose ENVSUB ON
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${DB_AUTH_ROLE_USERS}') THEN
        CREATE ROLE "${DB_AUTH_ROLE_USERS}" NOLOGIN;
    END IF;
-- +goose ENVSUB OFF
END
$$;
-- END Create Roles


-- START Create Application Objects
-- Create the application database
\set ON_ERROR_STOP off
CREATE DATABASE "${APP_DB_NAME}";
\set ON_ERROR_STOP on

-- Now switch context to that database
\connect "${APP_DB_NAME}"

-- Create the application  schema
CREATE SCHEMA IF NOT EXISTS "${APP_DB_SCHEMA}";
GRANT ALL ON SCHEMA "${APP_DB_SCHEMA}" TO "${MIGRATE_DB_USERNAME}";

-- Create Extension on application schema
CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA "${APP_DB_SCHEMA}";

-- ASSIGN PERMISSIONS TO SCHEMAS
-- +goose ENVSUB ON
GRANT USAGE ON SCHEMA "${APP_DB_SCHEMA}" TO "${VJOB_DB_USERNAME}";
-- +goose ENVSUB OFF

-- +goose ENVSUB ON
GRANT USAGE ON SCHEMA "${APP_DB_SCHEMA}" TO "${EMBEDDING_DB_USERNAME}";
-- +goose ENVSUB OFF

-- +goose ENVSUB ON
GRANT "${DB_AUTH_ROLE_ADMINS}" to "${PGREST_DB_USERNAME}";
GRANT USAGE ON SCHEMA "${APP_DB_SCHEMA}" TO "${DB_AUTH_ROLE_ADMINS}";
-- +goose ENVSUB OFF

-- +goose ENVSUB ON
GRANT "${DB_AUTH_ROLE_USERS}" to "${PGREST_DB_USERNAME}";
GRANT USAGE ON SCHEMA "${APP_DB_SCHEMA}" TO "${DB_AUTH_ROLE_USERS}";


-- Create the application database
\set ON_ERROR_STOP off
CREATE DATABASE "${KC_DB_NAME}";
\set ON_ERROR_STOP on

-- Now switch context to that database
\connect "${KC_DB_NAME}"

-- Create the keycloak schema
CREATE SCHEMA IF NOT EXISTS "${KC_DB_SCHEMA}";
GRANT ALL ON SCHEMA "${KC_DB_SCHEMA}" TO "${KC_DB_USERNAME}";

-- +goose ENVSUB OFF

-- +goose StatementEnd
