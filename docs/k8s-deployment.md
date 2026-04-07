# Kubernetes Deployment Guide

## Table of Contents

- [Kubernetes Deployment Guide](#kubernetes-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Infrastructure Prerequisites](#infrastructure-prerequisites)
    - [Technical Prerequisites](#technical-prerequisites)
  - [Requirements](#requirements)
    - [Hardware Requirements](#hardware-requirements)
      - [Kubernetes Cluster Sizing](#kubernetes-cluster-sizing)
      - [Postgres Database Sizing](#postgres-database-sizing)
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
    - [Clone the Project](#clone-the-project)
  - [Configuration Setup](#configuration-setup)
  - [Deploy the PostgreSQL Database](#deploy-the-postgresql-database)
  - [Deploy the Kubernetes Cluster](#deploy-the-kubernetes-cluster)
    - [Docker (Recommended)](#docker-recommended)
  - [Application Deployment](#application-deployment)
  - [Troubleshooting](#troubleshooting)
    - [Network Configuration](#network-configuration)
  - [Post-Install: Required PostgreSQL Extensions](#post-install-required-postgresql-extensions)
    - [Install System Packages](#install-system-packages)
    - [Enable the Extensions in PostgreSQL](#enable-the-extensions-in-postgresql)
    - [One-liner for Scripted Deployments](#one-liner-for-scripted-deployments)

---

## Overview

This guide describes deploying an open-source Kubernetes infrastructure on which to deploy SAS Retrieval Agent Manager.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to Kubernetes cluster

- **Network Requirements:**
  - Routable network connectivity between all cluster nodes
  - Static IP addresses for control plane VIP and load balancer services
  - DNS resolution for cluster FQDN

### Technical Prerequisites

**Required Access and Tools:**

- Administrative access to all target hosting machines with `sudo` level access
- SSH key pair for secure access to cluster nodes
- Database admin privileges for PostgreSQL initialization unless done manually

**Supported Operating Systems:**

- Ubuntu Linux LTS 20.04 or 22.04

## Requirements

### Hardware Requirements

#### Kubernetes Cluster Sizing

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                          |
|----------------------------------|-------|------|------|-------|----------------------------------------------------------------|
| **Control Plane Node (tainted)** | 1     | 4    | 8GB  | 50GB  |                                                                |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Optional if using CSI storage; can also serve as a worker node |

#### Postgres Database Sizing

[Follow the PostgreSQL sizing recommendations here.](../README.md#database)

### Infrastructure Requirements

- AKS version: 1.33+

>Note: These should all be deployed automatically via the SAS Viya 4 Infrastructure as Code scripts

## Getting Started

### Clone the Project

```bash
# Clone the repository
git clone https://github.com/sassoftware/viya4-iac-k8s

# Navigate to project directory
cd viya4-iac-k8s
```

## Configuration Setup

Before deploying, you'll need to create and edit three configuration files with your custom values:

| File                    | Purpose                       |                                                  |
|-------------------------|-------------------------------|--------------------------------------------------|
| `ansible-vars.yaml`     | Environment-specific settings | [Example](../examples/k8s/ansible-vars.yaml)     |
| `ansible-inventory.ini` | Target machine definitions    | [Example](../examples/k8s/ansible-inventory.ini) |
| `ansible-creds.env`     | Ansible access credentials    | [Example](../examples/k8s/ansible-creds.env)     |

> **Tip:** All example files can be found in the `examples/` directory for easy reference

## Deploy the PostgreSQL Database

Follow [these steps](../README.md#database) to deploy a database that SAS Retrieval Agent Manager can connect to.

## Deploy the Kubernetes Cluster

### Docker (Recommended)

```bash
# Build the Docker image
docker build -t viya4-iac-k8s .

# Deploy the cluster
sudo docker run --rm -it \
  --env-file $(pwd)/.bare_metal_creds.env \
  --volume=$HOME/.ssh:/.ssh \
  --volume=$(pwd):/workspace \
  viya4-iac-k8s \
  setup install
```

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.

## Troubleshooting

### Network Configuration

If you are experiencing network errors, ensure the following requirements are met:

- All cluster nodes can communicate with eachother on required ports
- Load balancer VIP is accessible from client networks
- DNS resolution works for the cluster FQDN
- Database connectivity is available from all worker nodes

For debugging load balancer issues:

```bash
# Check kube-vip status
kubectl get pods -n kube-system | grep vip

# Verify VIP assignment
kubectl get svc -A | grep LoadBalancer
```

If you are experiencing poor performance, consider:

- Adjusting resource requests and limits based on available hardware
- Configuring node affinity for workload placement
- Implementing resource quotas and limits

>For additional troubleshooting, refer to the main [troubleshooting section](../README.md#troubleshooting)

## Post-Install: Required PostgreSQL Extensions

After the PostgreSQL server is running, you must install the `pgcrypto` and `pgvector` extensions. These are required (or strongly recommended) by SAS Retrieval Agent Manager — see [Necessary PostgreSQL Extensions](../README.md#necessary-postgresql-extensions).

### Install System Packages

The required packages depend on your PostgreSQL version. The example below uses PostgreSQL 15 on Ubuntu.

```bash
# Update package index
sudo apt-get update

# Install pgcrypto (ships with the postgresql-contrib package)
sudo apt-get install -y postgresql-contrib

# Install pgvector build dependencies
sudo apt-get install -y build-essential postgresql-server-dev-15 git

# Clone and build pgvector
git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
cd ..
rm -rf pgvector
```

> **Note:** Replace `15` with your actual PostgreSQL major version (e.g. `16`) in the package names and `--branch` tag above. Check the [pgvector releases page](https://github.com/pgvector/pgvector/releases) for the latest stable version.

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
