-- Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
-- SPDX-License-Identifier: Apache-2.0

-- +goose Up
-- +goose StatementBegin

/*
Preform tasks that require superuser privileges.
This script is used to create the initial database roles, users, extensions.
This script should be also executed manually by system administrators
*/


-- START Create User
-- Create Vector store Schema user credentials
DO $$
    BEGIN
-- +goose ENVSUB ON
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${VECTOR_DB_USERNAME}') THEN
            CREATE ROLE "${VECTOR_DB_USERNAME}" LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD '${VECTOR_DB_PASSWORD}';
        ELSE
            ALTER ROLE "${VECTOR_DB_USERNAME}" PASSWORD '${VECTOR_DB_PASSWORD}';
        END IF;
-- +goose ENVSUB OFF
    END
$$;


-- START Create Vector Store Objects
-- Create the Vector Store database
\set ON_ERROR_STOP off
CREATE DATABASE "${VECTOR_DB_NAME}";
\set ON_ERROR_STOP on

-- Now switch context to that database
\connect "${VECTOR_DB_NAME}"

-- Create the application  schema
CREATE SCHEMA IF NOT EXISTS "${VECTOR_DB_SCHEMA}";
CREATE EXTENSION IF NOT EXISTS "vector" SCHEMA "${VECTOR_DB_SCHEMA}";
GRANT ALL ON SCHEMA "${VECTOR_DB_SCHEMA}" TO "${VECTOR_DB_USERNAME}";
