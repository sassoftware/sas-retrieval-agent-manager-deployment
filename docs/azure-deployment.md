# Azure Deployment Guide

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Configuration Setup](#configuration-setup)
- [Infrastructure Deployment](#infrastructure-deployment)
- [Application Deployment](#application-deployment)
- [Troubleshooting](#troubleshooting)

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

| File           | Purpose                                        |                                           |
|----------------|------------------------------------------------|-------------------------------------------|
| `terraform.tfvars` | PostgreSQL name, prefix, and location settings | [Example](../examples/azure/terraform.tfvars) |
| `azure.env`    | Azure credentials and environment variables    | [Example](../examples/azure/azure.env)    |

> **Tip:** If you need help obtaining Azure environemnt variables, contact your Azure Cloud Administrator or refer to our [Azure Help Guide](./user/AzureHelp.md)

## Infrastructure Deployment

### Docker (Recommended)

Use the provided Docker image to deploy the AKS cluster and PostgreSQL database with the [Example Terraform Values File](../examples/azure/terraform.tfvars). This method ensures a consistent environment and simplifies dependency management.

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
