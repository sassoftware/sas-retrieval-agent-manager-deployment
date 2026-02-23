# Openshift Deployment Guide

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

---

## Overview

This guide describes deploying an AWS infrastructure on which to deploy SAS Retrieval Agent Manager.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to both the Kubernetes cluster

### Technical Prerequisites

**Required Access and Tools:**

- Ability to create resources in the Openshift environment for the SAS Retrieval Agent Manager project

## Requirements

### Hardware Requirements

**Recommended Configuration:**

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                          |
|----------------------------------|-------|------|------|-------|----------------------------------------------------------------|
| **Control Plane Node (tainted)** | 3     | 4    | 8GB  | 50GB  |                                                                |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Optional if using CSI storage; can also serve as a worker node |

### Infrastructure Requirements

- Openshift version: 4.19.1

## Getting Started

We do not support the entire infrastructure deployment process for OpenShift like we do with AWS, Azure, and Open Source Kubernetes. You will need an already functioning OpenShift cluster. If you're interested in deploying an OpenShift cluster, [please refer to their documentation here](https://docs.redhat.com/en/documentation/openshift_container_platform/4.14/html/installation_overview/ocp-installation-overview).

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
