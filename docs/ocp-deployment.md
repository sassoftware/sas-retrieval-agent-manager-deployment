# OpenShift Deployment Guide

## Table of Contents

- [OpenShift Deployment Guide](#openshift-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Infrastructure Prerequisites](#infrastructure-prerequisites)
    - [Technical Prerequisites](#technical-prerequisites)
  - [Requirements](#requirements)
    - [Hardware Requirements](#hardware-requirements)
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
  - [Configuration Setup](#configuration-setup)
  - [Application Deployment](#application-deployment)
  - [Post-Install: Required PostgreSQL Extensions](#post-install-required-postgresql-extensions)
    - [Install System Packages](#install-system-packages)
    - [Enable the Extensions in PostgreSQL](#enable-the-extensions-in-postgresql)
    - [One-liner for Scripted Deployments](#one-liner-for-scripted-deployments)

---

## Overview

This guide describes deploying SAS Retrieval Agent Manager on an OpenShift cluster.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to both the Kubernetes cluster

### Technical Prerequisites

**Required Access and Tools:**

- Ability to create resources in the OpenShift environment for the SAS Retrieval Agent Manager project

## Requirements

### Hardware Requirements

**Recommended Configuration:**

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                          |
|----------------------------------|-------|------|------|-------|----------------------------------------------------------------|
| **Control Plane Node (tainted)** | 3     | 4    | 8GB  | 50GB  |                                                                |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Optional if using CSI storage; can also serve as a worker node |

### Infrastructure Requirements

- OpenShift version: 4.19.1

## Getting Started

We do not support the entire infrastructure deployment process for OpenShift like we do with AWS, Azure, and Open Source Kubernetes. You will need an already functioning OpenShift cluster. If you're interested in deploying an OpenShift cluster, [please refer to Red Hat documentation here](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/installation_overview/ocp-installation-overview).

## Configuration Setup

For the OpenShift deployment, all of the necessary deployment changes will occur if you set the `platform` key in the Values file to `openshift` as seen here:

```yaml

# @schema
# enum:
#   - "azure"
#   - "aws"
#   - "kubernetes"
#   - "openshift"
# required: true
# default: "azure"
# @schema
# -- Platform we are deploying on. (azure, aws, kubernetes, openshift)
platform: openshift

```

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.

## Post-Install: Required PostgreSQL Extensions

After the PostgreSQL server is running, you must install the `pgcrypto` and `pgvector` extensions. These are required (or strongly recommended) by SAS Retrieval Agent Manager — see [Necessary PostgreSQL Extensions](../README.md#necessary-postgresql-extensions).

### Install System Packages

The required packages depend on your PostgreSQL version. The example below uses PostgreSQL 15 on RHEL 8/9.

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

> **Note:** Replace `15` with your actual PostgreSQL major version (e.g. `16`) in the package names and `--branch` tag above. Adjust the `pgdg-redhat-repo` URL for your RHEL version (`EL-8` vs `EL-9`) and architecture. Check the [pgvector releases page](https://github.com/pgvector/pgvector/releases) for the latest stable version.

### Enable the Extensions in PostgreSQL

Connect to your PostgreSQL instance as a superuser and run the following SQL commands against the target database (replace `<your_database>` with the actual database name):

```sql
-- Connect to the target database first
\c <your_database>

-- Required: encryption support used by SAS Retrieval Agent Manager
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Recommended: vector similarity search for embedding storage
CREATE EXTENSION IF NOT EXISTS vector;
```

You can verify the extensions are active with:

```sql
SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name IN ('pgcrypto', 'vector');
```

Both extensions should show a value in `installed_version`.

### One-liner for Scripted Deployments

If you prefer a non-interactive approach (e.g. from a shell script or CI pipeline):

```bash
PGPASSWORD=<admin_password> psql \
  -h <db_host> \
  -U <admin_user> \
  -d <your_database> \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS vector;"
```
