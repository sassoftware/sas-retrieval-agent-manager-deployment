# Manual Database Initialization

These scripts perform the database work from
`helm/sas-retrieval-agent-manager/templates/db/init/scripts-configmap.yaml`
before the RAM Helm installation. Run them with a PostgreSQL administrator so
the application does not need database-admin credentials.

## Requirements

- Bash and PostgreSQL client tools (`psql`)
- Network access to the PostgreSQL server
- A PostgreSQL administrator that can create databases, roles, schemas, and extensions
- `pgcrypto` available for the application database
- `vector` available when vector store is enabled

Set the connection and application values in the shell or through a secure
environment mechanism. Do not put passwords in this directory or commit them.
The following variables are required:

```bash
export DB_HOST='postgres.example.com'
export DB_PORT='5432'
export DB_SSL_MODE='require'
export DB_ADMIN_USER='postgres-admin'
export DB_ADMIN_PASSWORD='enter-this-locally'

export POSTGREST_USER='sas_ram_pgrest_user'
export POSTGREST_PASSWORD='enter-this-locally'
export MIGRATION_USER='sas_ram_migration_user'
export MIGRATION_PASSWORD='enter-this-locally'
export VECTORIZATION_USER='sas_ram_vectorization_user'
export VECTORIZATION_PASSWORD='enter-this-locally'
export EMBEDDING_USER='sas_ram_embedding_user'
export EMBEDDING_PASSWORD='enter-this-locally'
export MONITORING_USER='sas_ram_mon_pgrest_user'
export MONITORING_PASSWORD='enter-this-locally'
export OTEL_USER='sas_ram_otel_user'
export OTEL_PASSWORD='enter-this-locally'
export KEYCLOAK_USER='sas_ram_keycloak_user'
export KEYCLOAK_PASSWORD='enter-this-locally'
export VECTOR_STORE_USER='sas_ram_vector_store_user'
export VECTOR_STORE_PASSWORD='enter-this-locally'
```

The database, schema, PostgREST role, and feature settings have defaults that
match the Helm values. Override them with environment variables when the RAM
values file uses different names. The relevant variables are
`APPLICATION_DB`, `APPLICATION_SCHEMA`, `MONITORING_DB`, `MONITORING_SCHEMA`,
`KEYCLOAK_DB`, `KEYCLOAK_SCHEMA`, `VECTOR_STORE_DB`, `VECTOR_STORE_SCHEMA`,
`APPLICATION_USER_ROLE`, `APPLICATION_ADMIN_ROLE`, `MONITORING_USER_ROLE`,
`MONITORING_ADMIN_ROLE`, and `ENABLE_VECTOR_STORE`.

## Run

Review the values that will be used, then make the scripts executable and run
the orchestrator:

```bash
chmod +x scripts/db/*.sh
scripts/db/initialize-db.sh
```

The stages run in this order, matching the ConfigMap: application, monitoring,
Keycloak, and vector store. Each stage is idempotent and can also be run on its
own when troubleshooting. The scripts do not create Kubernetes resources or
modify the Helm values file. Use the same database names, schemas, usernames,
and passwords in the RAM values file, and disable the chart's database
initialization for the deployment so it does not attempt to repeat this work.
