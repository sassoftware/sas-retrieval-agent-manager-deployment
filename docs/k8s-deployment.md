---
layout: default
title: Kubernetes deployment
parent: Deployment
nav_order: 4
---

# Kubernetes deployment
{: .no_toc }

1. TOC
{:toc}

---

## Overview

This guide describes deploying an open-source Kubernetes infrastructure on which to deploy SAS
Retrieval Agent Manager.

Complete [Get started](./get-started.md) first. It covers the common prerequisites, tools, and
license retrieval for every platform.

## Prerequisites

In addition to the [common prerequisites](./get-started.md#prerequisites):

- A PostgreSQL database server with bidirectional connectivity to the Kubernetes cluster
- Administrative access to all target hosting machines with `sudo` level access
- SSH key pair for secure access to cluster nodes
- Ubuntu Linux LTS 20.04 or 22.04 on all nodes

**Network requirements:**

- Routable network connectivity between all cluster nodes
- Static IP addresses for control plane VIP and load balancer services
- DNS resolution for cluster FQDN

## Requirements

### Hardware Requirements

Cluster sizing is platform-independent. Small, Medium, and Large worker node requirements are the
same as on AKS and EKS. See [Cluster sizing](./sizing.md).

This example shows a Small cluster with a single, non-production control plane node:

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                                       |
|----------------------------------|-------|------|------|-------|-----------------------------------------------------------------------------|
| **Control Plane Node (tainted)** | 1     | 4    | 8GB  | 50GB  |                                                                             |
| **Worker Nodes**                 | 2     | 8    | 32GB | 200GB | Use 64GB for embedding or vectorization workloads                           |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Used if your storageClass is `nfs-client`, can also be an extra worker node |

For Medium and Large clusters, keep this control plane and NFS configuration and scale the worker
nodes to the [tier requirements](./sizing.md#step-2-tier-requirements).

#### Postgres Database Sizing

[Follow the PostgreSQL sizing recommendations here.](./database.md#sizing)

### Infrastructure Requirements

- Kubernetes version: 1.35+

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

> Note: While we do fully recommend following the viya4-iac-k8s repository, we do have some differences reguarding node labels. We have provided an example for the `ansible-vars` file [here](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/k8s/ansible-vars.yaml)

## Infrastructure Deployment

### Deploy the Kubernetes Cluster and PostgreSQL Database

#### Docker (Recommended)

Follow the viya4-iac-k8s [docker deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/DockerUsage.md) to deploy a Kubernetes cluster using Docker.

#### Bare Metal

Follow the viya4-iac-k8s [bare metal deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/ScriptUsage.md) to deploy a Kubernetes cluster on bare metal infrastructure.

## Next steps

1. [Configure the database](./database.md) — install and enable the `pgcrypto` and `vector`
   extensions.
2. [Install dependencies](./user/DependencyInstall.md).
3. [Install and upgrade](./install.md) — deploy the application.

## Troubleshooting

Please refer to the [troubleshooting section](https://github.com/sassoftware/viya4-iac-k8s) of the main documentation for common issues and resolutions related to viya4-iac-k8s Kubernetes deployments.

>For additional troubleshooting, refer to the main [troubleshooting section](./troubleshoot.md)
