---
layout: default
title: Azure deployment
parent: Deployment
nav_order: 1
has_children: true
---

# Azure deployment
{: .no_toc }

1. TOC
{:toc}

---

## Overview

This guide describes deploying an Azure infrastructure on which to deploy SAS Retrieval Agent
Manager.

Complete [Get started](./get-started.md) first. It covers the common prerequisites, tools, and
license retrieval for every platform.

## Prerequisites

In addition to the [common prerequisites](./get-started.md#prerequisites):

- Ability to create resources in Azure
- A PostgreSQL database server with bidirectional connectivity to the Kubernetes cluster

## Requirements

### Hardware Requirements

#### AKS Cluster Sizing

|       Node Size      | Minimum Nodes | Maximum Nodes |   Deployment Size  |
|----------------------|---------------|---------------|--------------------|
| **Standard_d8s_v5**  |       1       |       3       |      Small         |
| **Standard_d8s_v5**  |       2       |       6       |      Medium        |
| **Standard_d16s_v5** |       2       |       8       |      Large         |

#### Postgres Database Sizing

[Follow the PostgreSQL sizing recommendations here.](./database.md#sizing)

### Infrastructure Requirements

- AKS version: 1.35+

## Getting Started

### Clone the Viya IAC Project

```bash
# Clone the Viya IAC repository
git clone https://github.com/sassoftware/viya4-iac-azure

# Navigate to project directory
cd viya4-iac-azure
```

> **Note:** While we use the viya-iac repository, a viya license or deployment is not required to use SAS Retrieval Agent Manager. This is a standalone application that can be deployed independently of a Viya environment.

## Configuration Setup

Before deploying, you'll need to create and edit two configuration files with your custom values and place them inside of `viya4-iac-azure` repository directory:

| File               | Purpose                                        |                                               |
|--------------------|------------------------------------------------|-----------------------------------------------|
| `terraform.tfvars` | PostgreSQL name, prefix, and location settings | [Example](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/azure/terraform.tfvars) |
| `azure.env`        | Azure credentials and environment variables    | [Example](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/azure/azure.env)        |

> **Tip:** If you need help obtaining Azure environemnt variables, contact your Azure Cloud Administrator or refer to our [Azure Help Guide](./user/AzureHelp.md)

## Infrastructure Deployment

### Docker (Recommended)

Use the provided Docker image to deploy the AKS cluster and PostgreSQL database with the [Example Terraform Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/azure/terraform.tfvars). This method ensures a consistent environment and simplifies dependency management.

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

## Deploy PostgreSQL SSL Certificate

If your Azure Database for PostgreSQL Flexible Server requires SSL, you must provide the SSL
certificate bundle as a Kubernetes secret. Download the required root CA certificates from
Microsoft:

- [DigiCert Global Root G2 (pem file)](https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem)
- [Microsoft RSA Root Certificate Authority 2017 (crt file)](https://www.microsoft.com/pkiops/certs/Microsoft%20RSA%20Root%20Certificate%20Authority%202017.crt)

[For more details on Azure PostgreSQL TLS configuration, refer to the Microsoft documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-connect-tls-ssl).

Then follow [Secure the database connection](./database.md#secure-the-database-connection) to
convert the certificates, build the `cert.pem` bundle, and create the Kubernetes secret.

## Next steps

1. [Configure the database](./database.md) — enable the `pgcrypto` and `vector` extensions on the
   Flexible Server.
2. [Install dependencies](./user/DependencyInstall.md).
3. [Install and upgrade](./install.md) — deploy the application.

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

> For additional troubleshooting, refer to the main [troubleshooting section](./troubleshoot.md)
