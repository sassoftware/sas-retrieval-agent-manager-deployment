---
layout: default
title: Deployment
nav_order: 3
has_children: true
permalink: /deployment/
---

# Deployment

Follow these steps in order. Step 1 provisions infrastructure; steps 2 through 6 install the
application.

Before you start, complete [Get started](./get-started.md) to gather your prerequisites, license,
and image pull secret.

| Step | Page | Purpose |
|------|------|---------|
| 1 | Platform guide — [Azure](./azure-deployment.md), [AWS](./aws-deployment.md), [Kubernetes](./k8s-deployment.md), or [OpenShift](./ocp-deployment.md) | Provision the cluster and database infrastructure |
| 2 | [Configure the database](./database.md) | Size PostgreSQL, enable extensions, secure the connection |
| 3 | [Install dependencies](./user/DependencyInstall.md) | cert-manager, trust-manager, Linkerd, ingress controller, Kueue |
| 4 | [GPG keys](./gpg-keys.md) | Generate and back up the encryption keys |
| 5 | [Values file generator](./configure-values.md) | Build your `ram-values.yaml` |
| 6 | [Install and upgrade](./install.md) | Deploy the Helm chart and verify |

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