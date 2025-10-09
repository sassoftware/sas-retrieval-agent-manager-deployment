-- +goose Up
-- +goose StatementBegin

/*
Preform tasks that require superuser privileges.
This script is used to create the initial database roles, users, extensions.
This script should be also executed manually by system administrators
*/


-- +goose ENVSUB ON
\set ON_ERROR_STOP off
DROP DATABASE "${APP_DB_NAME}";
DROP DATABASE "${KC_DB_NAME}";
DROP ROLE "${MIGRATE_DB_USERNAME}";
DROP ROLE "${KC_DB_USERNAME}";
DROP ROLE "${PGREST_DB_USERNAME}";
DROP ROLE "${VJOB_DB_USERNAME}";
DROP ROLE "${EMBEDDING_DB_USERNAME}";
DROP ROLE "${DB_AUTH_ROLE_ADMINS}";
DROP ROLE "${DB_AUTH_ROLE_USERS}";

-- Drop Vector Store objects
DROP DATABASE "${VECTOR_DB_NAME}";
DROP ROLE "${VECTOR_DB_USERNAME}";
\set ON_ERROR_STOP on
-- +goose ENVSUB OFF

-- +goose StatementEnd
