# Kubernetes Deployment Guide

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

## Infrastructure Deployment

### Deploy the Kubernetes Cluster and PostgreSQL Database

#### Docker (Recommended)

Follow the viya4-iac-k8s [docker deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/DockerUsage.md) to deploy a Kubernetes cluster using Docker.

#### Bare Metal

Follow the viya4-iac-k8s [bare metal deployment guide](https://github.com/sassoftware/viya4-iac-k8s/blob/main/docs/user/ScriptUsage.md) to deploy a Kubernetes cluster on bare metal infrastructure.

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
