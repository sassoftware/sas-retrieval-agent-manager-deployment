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
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
    - [Clone the Project](#clone-the-project)
  - [Configuration Setup](#configuration-setup)
  - [Deploy the PostgreSQL Database](#deploy-the-postgresql-database)
  - [Deploy the Kubernetes Cluster](#deploy-the-kubernetes-cluster)
  - [Application Deployment](#application-deployment)
  - [Troubleshooting](#troubleshooting)
    - [Network Configuration](#network-configuration)

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

**Recommended Configuration:**

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                          |
|----------------------------------|-------|------|------|-------|----------------------------------------------------------------|
| **Control Plane Node (tainted)** | 1     | 4    | 8GB  | 50GB  |                                                                |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Optional if using CSI storage; can also serve as a worker node |

### Infrastructure Requirements

| Component         | Version           |
|-------------------|-------------------|
| Kubernetes        | 1.30.10           |
| Container Runtime | containerd 1.7.24 |
| CNI               | Calico 3.29.0     |
| Load Balancer     | kube-vip 0.7.1    |

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
  --volume=$HOME/.ssh:/.ssh
  --volume=$(pwd):/workspace
  viya4-iac-k8s \
  setup install
```

## Application Deployment

Return to the [Dependency Installation](../README.md#install-required-dependencies) and [Application Deployment](../README.md#install-sas-retrieval-agent-manager) sections of the documentation to continue the deployment.

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
