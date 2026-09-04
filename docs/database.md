---
layout: default
title: Configure the database
parent: Deployment
nav_order: 5
---

# Configure the database
{: .no_toc }

1. TOC
{:toc}

---

SAS Retrieval Agent Manager requires a PostgreSQL 15 database for application data, vector
embeddings, and more. The database can run on any platform as long as the Kubernetes cluster can
reach it.

Complete this page after you provision infrastructure with your platform deployment guide and
before you [install the application](./install.md).

## Sizing

Size the database for your expected usage:

| Deployment size | Total vCPU (min) | Total RAM (Gb) | Storage (Gb) | Queries per day | Agents/Custom sources/MCP servers |
|-----------------|------------------|----------------|--------------|-----------------|-----------------------------------|
| Small           | 4                | 16             | 128          | 4000            | 6                                 |
| Medium          | 4                | 16             | 128          | 8000            | 20                                |
| Large           | 8                | 32             | 128          | 8000+           | 20+                               |

## Required extensions

| Extension    | Required/Recommended | Description                                                                    |
|--------------|----------------------|--------------------------------------------------------------------------------|
| **pgcrypto** | Required             | Database encryption of application data                                        |
| **vector**   | Recommended          | Storing vector embeddings in the PostgreSQL database (alternative is Weaviate) |

Making an extension available differs per platform. Follow the section for your platform, then
enable the extensions.

### Azure Database for PostgreSQL Flexible Server

Azure requires extensions to be allow-listed at the server level before they can be activated in a
database.

```bash
# Allow pgcrypto and vector on the Flexible Server
az postgres flexible-server parameter set \
  --resource-group <resource_group> \
  --server-name <server_name> \
  --name azure.extensions \
  --value pgcrypto,vector
```

> **Note:** If the `azure.extensions` parameter already has values, append the new ones as a
> comma-separated list rather than replacing them. You can check the current value with:
>
> ```bash
> az postgres flexible-server parameter show \
>   --resource-group <resource_group> \
>   --server-name <server_name> \
>   --name azure.extensions
> ```

Alternatively, allow-list the extensions in the **Azure Portal** by navigating to your Flexible
Server → **Server parameters** → search for `azure.extensions` → add `PGCRYPTO` and `VECTOR` to the
value list → **Save**.

### Amazon RDS for PostgreSQL

Amazon RDS ships `pgcrypto` and `pgvector` as pre-built extensions. No system package installation
is required.

> **Note:** `pgvector` is available on RDS PostgreSQL 15.2 and later. Verify your RDS instance meets
> this requirement before proceeding.

### Self-managed PostgreSQL

Install the system packages first. The required packages depend on your PostgreSQL version.

**Ubuntu (PostgreSQL 15):**

```bash
# Update package index
sudo apt-get update

# Install pgcrypto (ships with the postgresql-15 package)
sudo apt-get install -y postgresql-15

# Install pgvector
sudo apt-get install -y postgresql-15-pgvector
```

**RHEL 8/9 (PostgreSQL 15):**

```bash
# Install the PostgreSQL repository (if not already configured)
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module to avoid conflicts (RHEL 8/9)
sudo dnf -qy module disable postgresql

# Install pgcrypto (ships with the postgresql-contrib package)
sudo dnf install -y postgresql15-contrib

# Install pgvector build dependencies
sudo dnf install -y gcc make git postgresql15-devel

# Clone and build pgvector
git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
cd ..
rm -rf pgvector
```

> **Note:** Replace `15` with your actual PostgreSQL major version (for example `16`) in the package
> names and `--branch` tag above. Adjust the `pgdg-redhat-repo` URL for your RHEL version (`EL-8` vs
> `EL-9`) and architecture. Check the
> [pgvector releases page](https://github.com/pgvector/pgvector/releases) for the latest stable
> version.

### Enable the extensions

Connect to your PostgreSQL instance as a superuser and activate the extensions in the target
database. Replace `<your_database>` with the actual database name.

```sql
-- Connect to the target database first
\c <your_database>

-- Required: encryption support used by SAS Retrieval Agent Manager
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Recommended: vector similarity search for embedding storage
CREATE EXTENSION IF NOT EXISTS vector;
```

Verify that the extensions are active:

```sql
SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name IN ('pgcrypto', 'vector');
```

Both extensions should show a value in `installed_version`.

For a non-interactive approach, such as a shell script or CI pipeline:

```bash
PGPASSWORD=<admin_password> psql \
  -h <db_host> \
  -U <admin_user> \
  -d <your_database> \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS vector;"
```

## Secure the database connection

If your database requires SSL, provide the SSL certificate bundle as a Kubernetes secret in the same
namespace as your SAS Retrieval Agent Manager deployment.

### Obtain the root certificates

| Platform | Source |
|----------|--------|
| **Azure** | [DigiCert Global Root G2 (pem)](https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem) and [Microsoft RSA Root Certificate Authority 2017 (crt)](https://www.microsoft.com/pkiops/certs/Microsoft%20RSA%20Root%20Certificate%20Authority%202017.crt). See the [Azure PostgreSQL TLS documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-connect-tls-ssl). |
| **AWS**   | [Download the bundle for your RDS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html). |
| **OpenShift (Crunchy Postgres Operator)** | Extract from the `<clusterName>-cluster-cert` secret. See the [OpenShift deployment guide](./ocp-deployment.md). |

If an Azure `.crt` file is in DER format, convert it to PEM first:

```bash
openssl x509 -inform DER -in "Microsoft RSA Root Certificate Authority 2017.crt" -out msrsa2017.pem -outform PEM
```

To find which RDS region certificate you need:

```bash
# Find the region you need the RDS SSL bundle for
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,AvailabilityZone]' --output table
```

### Construct the certificate bundle

The `cert.pem` secret key must contain a single PEM file that concatenates **four components in the
following order**:

1. **Chain certificate** (`trustedcerts.pem`)
2. **Intermediate certificate** (`ca.crt`)
3. **Server certificate** (`tls.crt`)
4. **Private key** (`tls.key`)

The resulting file structure should look like this:

```text
-----BEGIN CERTIFICATE-----
<trustedcerts.pem contents>
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
<ca.crt contents>
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
<tls.crt contents>
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
<tls.key contents>
-----END RSA PRIVATE KEY-----
```

Build the bundle with the following command:

```bash
cat trustedcerts.pem ca.crt tls.crt tls.key > combined-cert.pem
```

### Create the Kubernetes secret

Upload the bundle as a secret with the key `cert.pem`:

```bash
# The correct namespace to store all SAS Retrieval Agent Manager Resources
kubectl create ns retagentmgr

# Create a secret with the PostgreSQL SSL bundle
kubectl create secret generic <your-secret-name> --from-file=cert.pem=combined-cert.pem -n retagentmgr
```

> **Note:** It is critical to enter the name of the secret in the `postgreSQLCertSecret` key in the
> values file under `global.configuration.vhub`. For example, with this secret name, it would be:
> `postgreSQLCertSecret: '<your-secret-name>'`

## Database initialization

SAS Retrieval Agent Manager automatically initializes the required databases during deployment
unless specified otherwise. This requires database admin credentials in your values file.

### Manual initialization

If you do not want to give SAS Retrieval Agent Manager database-admin-level access, set database
initialization to `false` in your values file and initialize the databases separately before you
install:

```yaml
db:
  init:
    config:
      database:
        initializeDb: "False"
```

The manual initialization scripts require a PostgreSQL administrator only while the databases,
roles, schemas, and required extensions are prepared. After they complete, SAS Retrieval Agent
Manager can connect using its application-specific database credentials.

Follow the
[Manual Database Initialization](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/tree/main/scripts/db)
guide for the required environment variables and Docker or bare-metal commands.

## Next step

Continue to [Install dependencies](./user/DependencyInstall.md).
