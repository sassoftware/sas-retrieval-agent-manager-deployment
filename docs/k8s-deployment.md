---
layout: default
title: Kubernetes deployment
parent: Deployment
nav_order: 3
---

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
    - [Clone the Viya IAC Project](#clone-the-viya-iac-project)
  - [Configuration Setup](#configuration-setup)
  - [Infrastructure Deployment](#infrastructure-deployment)
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

#### Kubernetes Cluster Sizing Example (Small Size)

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                                       |
|----------------------------------|-------|------|------|-------|-----------------------------------------------------------------------------|
| **Control Plane Node (tainted)** | 1     | 4    | 8GB  | 50GB  |                                                                             |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                             |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Used if your storageClass is `nfs-client`, can also be an extra worker node |

#### Postgres Database Sizing

[Follow the PostgreSQL sizing recommendations here.](../README.md#database)

### Infrastructure Requirements

- AKS version: 1.35+

> Note: These should all be deployed automatically via the SAS Viya 4 Infrastructure as Code scripts

## Getting Started

### Clone the Viya IAC Project

```bash
# Clone the Viya IAC repository
git clone https://github.com/sassoftware/viya4-iac-k8s

# Navigate to project directory
cd viya4-iac-k8s
```

> **Note:** While we use the viya-iac deployment repository, a viya license or deployment is not required to use SAS Retrieval Agent Manager. This is a standalone application that can be deployed independently of a Viya environment.

## Configuration Setup

Before deploying, you'll need to create and edit three configuration files with your custom values:

| File                    | Purpose                       | Official Documentation Example                                                                                     |
|-------------------------|-------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `ansible-vars`          | Environment-specific settings | [Example](https://github.com/sassoftware/viya4-iac-k8s/blob/main/examples/bare-metal/sample-ansible-vars.yaml)     |
| `ansible-inventory`     | Target machine definitions    | [Example](https://github.com/sassoftware/viya4-iac-k8s/blob/main/examples/bare-metal/sample-inventory)             |
| `ansible-creds`         | Ansible access credentials    | [Example](https://github.com/sassoftware/viya4-iac-k8s/blob/main/examples/bare-metal/.bare_metal_creds.env)        |

> Note: While we do fully recommend following the viya4-iac-k8s repository, we do have some differences reguarding node labels. We have provided an example for the `ansible-vars` file [here](../examples/k8s/ansible-vars.yaml)

## Infrastructure Deployment

### Deploy the Kubernetes Cluster and PostgreSQL Database

#### Docker (Recommended)

Follow the viya4-iac-k8s [docker deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/DockerUsage.md) to deploy a Kubernetes cluster using Docker.

#### Bare Metal

Follow the viya4-iac-k8s [bare metal deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/ScriptUsage.md) to deploy a Kubernetes cluster on bare metal infrastructure.

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.

## Troubleshooting

Please refer to the [troubleshooting section](https://github.com/sassoftware/viya4-iac-k8s) of the main documentation for common issues and resolutions related to viya4-iac-k8s Kubernetes deployments.

>For additional troubleshooting, refer to the main [troubleshooting section](../README.md#troubleshooting)

## Post-Install: Required PostgreSQL Extensions

After the PostgreSQL server is running, you must install the `pgcrypto` and `pgvector` extensions. These are required (or strongly recommended) by SAS Retrieval Agent Manager — see [Necessary PostgreSQL Extensions](../README.md#necessary-postgresql-extensions).

### Install System Packages

The required packages depend on your PostgreSQL version. The example below uses PostgreSQL 15 on Ubuntu.

```bash
# Update package index
sudo apt-get update

# Install pgcrypto (ships with the postgresql-15 package)
sudo apt-get install -y postgresql-15

# Install pgvector
sudo apt-get install -y postgresql-15-pgvector
```

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
