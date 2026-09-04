---
layout: default
title: Install and upgrade
parent: Deployment
nav_order: 8
---

# Install and upgrade
{: .no_toc }

1. TOC
{:toc}

---

## Before you begin

Confirm that you have completed the following:

1. [Get started](./get-started.md) — license retrieved and image pull secret created.
2. A platform deployment guide — Kubernetes cluster provisioned.
3. [Configure the database](./database.md) — PostgreSQL 15 reachable, extensions enabled.
4. [Install dependencies](./user/DependencyInstall.md) — cert-manager, trust-manager, Linkerd,
   an ingress controller, and Kueue.
5. [GPG keys](./gpg-keys.md) — keys generated, applied, and backed up.

## Configure the values file

SAS Retrieval Agent Manager is configured through a single Helm values file. The values are
standardized across all supported platforms.

> **Tip:** Use the [values file generator](./configure-values.md) to build a `ram-values.yaml`
> interactively. The generator runs entirely in your browser and produces the file you pass to
> `--values` below.

You can also start from the
[example values file](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/ram-values.yaml)
and edit it by hand.

### Persistent volume size

Set the storage capacity under `.storage.embedding.pvc.size` and `.storage.application.pvc.size`.
The application PVC size starts at 5Gi and increases from there.

> **Note:** The application PVC size corresponds with the amount of data purchased from SAS.

### Child workload scheduling

The `api.childScheduling` values control the tolerations, node selectors, and affinity for workloads
spawned by the API, including agents, evaluations, source pods, and model services. The example
values file prefers nodes labeled for SAS Retrieval Agent Manager. Adjust these settings to match
your cluster's scheduling configuration.

## Install

```bash
helm install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version 2026.8.0 \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr \
  --create-namespace \
  --timeout 10m
```

> **Note:** Use the packages section of the repository to find an installable version. If something
> fails and you need to redeploy, run `helm uninstall retrieval-agent-manager -n retagentmgr` and
> retry the installation.

### Verify the deployment

```bash
kubectl get pods -n retagentmgr
```

## Upgrade

> [!CAUTION]
> Do not redeploy or regenerate GPG keys when upgrading. Deleting the GPG secrets or configmaps
> during an upgrade permanently destroys all encrypted application data with no possibility of
> recovery. See [GPG keys](./gpg-keys.md).

We recommend step-through upgrades, applying each version incrementally rather than skipping
versions. This ensures that you get each database migration in the intended order.

You must use the same GPG keys and Helm values for upgrades as you did for the initial installation.
We also recommend starting from the example values file for the version you are upgrading to and
copying over any custom values from your previous file.

```bash
helm upgrade --install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version <SAS Retrieval Agent Manager Version> \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr \
  --timeout 10m
```

## Next steps

- [Identity and access](./identity-and-access.md) — connect an identity provider.
- [LLM connections](./llm-connection/README.md) — connect a model.
- [Monitoring](./monitoring/README.md) — collect logs, metrics, and traces.
- [Backup and restore](./backup-restore/README.md) — protect your data.
- [Troubleshooting](./troubleshoot.md) — resolve common issues.
