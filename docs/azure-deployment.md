# Azure Deployment Guide

## Table of Contents

- [Azure Deployment Guide](#azure-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Infrastructure Prerequisites](#infrastructure-prerequisites)
    - [Technical Prerequisites](#technical-prerequisites)
  - [Requirements](#requirements)
    - [Hardware Requirements](#hardware-requirements)
      - [AKS Cluster Sizing](#aks-cluster-sizing)
      - [Postgres Database Sizing](#postgres-database-sizing)
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
    - [Clone the Project](#clone-the-project)
  - [Configuration Setup](#configuration-setup)
  - [Deploy the Kubernetes Cluster and PostgreSQL Database](#deploy-the-kubernetes-cluster-and-postgresql-database)
    - [Docker (Recommended)](#docker-recommended)
  - [Application Deployment](#application-deployment)
  - [Troubleshooting](#troubleshooting)
    - [Azure Authentication](#azure-authentication)
    - [Cluster Deployment](#cluster-deployment)
    - [Helm Deployment Issues](#helm-deployment-issues)
  - [Post-Install: Required PostgreSQL Extensions](#post-install-required-postgresql-extensions)
    - [Allow-list the Extensions on the Flexible Server](#allow-list-the-extensions-on-the-flexible-server)
    - [Enable the Extensions in PostgreSQL](#enable-the-extensions-in-postgresql)
    - [One-liner for Scripted Deployments](#one-liner-for-scripted-deployments)

---

## Overview

This guide describes deploying an Azure infrastructure on which to deploy SAS Retrieval Agent Manager.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to Kubernetes cluster

### Technical Prerequisites

**Required Access and Tools:**

- Ability to create resources in Azure

## Requirements

### Hardware Requirements

#### AKS Cluster Sizing

|       Node Size      | Minimum Nodes | Maximum Nodes |   Deployment Size  |
|----------------------|---------------|---------------|--------------------|
| **Standard_d8s_v5**  |       1       |       3       |      Small         |
| **Standard_d8s_v5**  |       2       |       6       |      Medium        |
| **Standard_d16s_v5** |       2       |       8       |      Large         |

#### Postgres Database Sizing

[Follow the PostgreSQL sizing recommendations here.](../README.md#database)

### Infrastructure Requirements

- AKS version: 1.33+

## Getting Started

### Clone the Project

```bash
# Clone the repository
git clone https://github.com/sassoftware/viya4-iac-azure

# Navigate to project directory
cd viya4-iac-azure
```

## Configuration Setup

Before deploying, you'll need to create and edit two configuration files with your custom values and place them inside of `viya4-iac-azure` repository directory:

| File           | Purpose                                        |                                           |
|----------------|------------------------------------------------|-------------------------------------------|
| `terraform.tfvars` | PostgreSQL name, prefix, and location settings | [Example](../examples/azure/terraform.tfvars) |
| `azure.env`    | Azure credentials and environment variables    | [Example](../examples/azure/azure.env)    |

> **Tip:** If you need help obtaining Azure environemnt variables, contact your Azure Cloud Administrator or refer to our [Azure Help Guide](./user/AzureHelp.md)

## Deploy the Kubernetes Cluster and PostgreSQL Database

### Docker (Recommended)

```bash
# Build the Docker image
docker build -t viya4-iac-azure .

# Deploy the cluster
docker run --rm --group-add root \
    --user "$(id -u):$(id -g)" \
    --env-file=azure.env \
    --volume=$HOME/.ssh:/.ssh \
    --volume=$(pwd):/workspace \
    viya4-iac-azure \
    apply -auto-approve \
    -var-file=/workspace/terraform.tfvars
```

> [Example Terraform Values File](../examples/azure/terraform.tfvars)

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.

## Troubleshooting

### Azure Authentication

If you are experiencing authentication errors, ensure the following requirements are met:

- All values in `azure.env` are correct and up-to-date
- Azure service principal has sufficient permissions
- Subscription ID is valid and accessible
- Resource group exists and you have contributor access

For debugging authentication issues:

```bash
# Test Azure CLI authentication
az account show

# Verify service principal permissions
az role assignment list --assignee <client-id>
```

### Cluster Deployment

If AKS cluster creation fails, consider:

- Checking Azure region availability for Standard_D16ds_v4 or Standard_D8ds_v4 nodes
- Verifying sufficient quota in your Azure subscription
- Ensuring no naming conflicts with existing resources
- Confirming network configuration allows cluster communication

### Helm Deployment Issues

If the SAS Retrieval Agent Manager deployment fails, ensure the following requirements are met:

- `ram-values.yaml` is properly configured for your environment
- Ingress-Nginx and Kueue dependencies are successfully installed
- Sufficient resources are available on worker nodes
- Namespace does not have conflicting resources

For debugging deployment issues:

```bash
# Check pod status and logs
kubectl get pods -n retagentmgr
kubectl logs -l app=sas-retrieval-agent-manager -n retagentmgr

# Verify Helm release status
helm status sas-retrieval-agent-manager -n retagentmgr
```

> For additional troubleshooting, refer to the main [troubleshooting section](../README.md#troubleshooting)

## Post-Install: Required PostgreSQL Extensions

Azure Database for PostgreSQL Flexible Server requires extensions to be explicitly allow-listed at the server level before they can be activated in a database. These are required (or strongly recommended) by SAS Retrieval Agent Manager — see [Necessary PostgreSQL Extensions](../README.md#necessary-postgresql-extensions).

### Allow-list the Extensions on the Flexible Server

Run the following Azure CLI commands to add `pgcrypto` and `vector` to the server's allowed extensions. Replace the placeholder values with your resource group, server name, and subscription as appropriate.

```bash
# Allow pgcrypto and vector on the Flexible Server
az postgres flexible-server parameter set \
  --resource-group <resource_group> \
  --server-name <server_name> \
  --name azure.extensions \
  --value pgcrypto,vector
```

> **Note:** If the `azure.extensions` parameter already has values, append the new ones as a comma-separated list rather than replacing them. You can check the current value with:
>
> ```bash
> az postgres flexible-server parameter show \
>   --resource-group <resource_group> \
>   --server-name <server_name> \
>   --name azure.extensions
> ```

Alternatively, you can allow-list the extensions in the **Azure Portal** by navigating to your Flexible Server → **Server parameters** → search for `azure.extensions` → add `PGCRYPTO` and `VECTOR` to the value list → **Save**.

### Enable the Extensions in PostgreSQL

Once allow-listed, connect to your PostgreSQL instance as a superuser and activate the extensions in the target database (replace `<your_database>` with the actual database name):

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
  -h <server_name>.postgres.database.azure.com \
  -U <admin_user> \
  -d <your_database> \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS vector;"
```

> **Note:** The allow-list step must be completed before running the above command, otherwise `CREATE EXTENSION` will fail with a permission error.
