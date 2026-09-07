---
layout: default
title: Deployment
nav_order: 3
has_children: true
permalink: /deployment/
---

# Deployment

Follow these steps in order. Steps 1 and 2 cover sizing and infrastructure; steps 3 through 7
install the application.

Before you start, complete [Get started](./get-started.md) to gather your prerequisites, license,
and image pull secret.

| Step | Page | Purpose |
|------|------|---------|
| 1 | [Cluster sizing](./sizing.md) | Choose a Small, Medium, or Large tier and size your nodes |
| 2 | Platform guide — [Azure](./azure-deployment.md), [AWS](./aws-deployment.md), [Kubernetes](./k8s-deployment.md), or [OpenShift](./ocp-deployment.md) | Provision the cluster and database infrastructure |
| 3 | [Configure the database](./database.md) | Size PostgreSQL, enable extensions, secure the connection |
| 4 | [Install dependencies](./user/DependencyInstall.md) | cert-manager, trust-manager, Linkerd, ingress controller, Kueue |
| 5 | [GPG keys](./gpg-keys.md) | Generate and back up the encryption keys |
| 6 | [Values file generator](./configure-values.md) | Build your `ram-values.yaml` |
| 7 | [Install and upgrade](./install.md) | Deploy the Helm chart and verify |

> [!CAUTION]
> GPG keys are the encryption foundation for all sensitive data. Generate and back them up before
> the first installation, and never regenerate them afterwards. See [GPG keys](./gpg-keys.md).

## Supported platforms

| Platform       | Description                                        |
|----------------|----------------------------------------------------|
| **Kubernetes** | Open-source Kubernetes deployment                  |
| **Azure**      | Azure Kubernetes Service (AKS) deployment          |
| **AWS**        | Amazon Elastic Kubernetes Service (EKS) deployment |
| **OpenShift**  | OpenShift Container Platform (OCP)                 |