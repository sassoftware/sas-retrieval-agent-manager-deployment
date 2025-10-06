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
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
    - [Clone the Project](#clone-the-project)
  - [Configuration Setup](#configuration-setup)
  - [Deploy the Kubernetes Cluster and PostgreSQL Database](#deploy-the-kubernetes-cluster-and-postgresql-database)
  - [Application Deployment](#application-deployment)
  - [Troubleshooting](#troubleshooting)
    - [Azure Authentication](#azure-authentication)
    - [Cluster Deployment](#cluster-deployment)
    - [Helm Deployment Issues](#helm-deployment-issues)

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

|       Node Size      | Minimum Nodes | Maximum Nodes |   Deployment Size  |
|----------------------|---------------|---------------|--------------------|
| **Standard_E8s_v5**  |       1       |       3       |      Small         |
| **Standard_E8s_v5**  |       2       |       6       |      Medium        |
| **Standard_E16s_v5** |       2       |       8       |      Large         |

### Infrastructure Requirements

- AKS version: 1.32

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
sudo docker run --rm \
    --env-file=azure.env \
    --volume=$HOME/.ssh:/.ssh \
    --volume=$(pwd):/workspace \
    viya4-iac-azure \
    apply -auto-approve \
    -var-file=/workspace/terraform.tfvars
```

> [Example Terraform Values File](../examples/azure/terraform.tfvars)

## Application Deployment

Return to the [Dependency Installation](../README.md#install-required-dependencies) and [Application Deployment](../README.md#install-sas-retrieval-agent-manager) sections of the documentation to continue the deployment.

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

If RAM deployment fails, ensure the following requirements are met:

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
