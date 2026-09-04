---
layout: default
title: GPG keys
parent: Deployment
nav_order: 7
---

# GPG keys
{: .no_toc }

1. TOC
{:toc}

---

> [!CAUTION]
> GPG keys are the encryption foundation for all sensitive data in SAS Retrieval Agent Manager.
> Deleting or regenerating existing GPG keys post-deployment will result in permanent, unrecoverable
> data loss.

GPG keys must be deployed as Kubernetes secrets and configmaps before the **initial** installation
of SAS Retrieval Agent Manager. They are required for the encryption and decryption of sensitive
data.

## Rules

- **NEVER** run the key scripts if GPG keys already exist in the `retagentmgr` namespace.
- **NEVER** delete the GPG key secrets or configmaps from the cluster.
- **NEVER** regenerate keys and reapply them to an existing installation.
- **BACK UP** your GPG keys and store them securely before you install.

Once generated and applied, the keys are permanently tied to that environment's encrypted data.
There is no recovery path if existing keys are lost, overwritten, or regenerated against a live
installation.

## Generate and apply the keys

Use the scripts in the
[scripts/gpg directory](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/tree/main/scripts/gpg)
to create the keys and apply them to the cluster as secrets and configmaps.

```bash
# Linux or macOS, from scripts/gpg
./run-bootstrap-gpg.sh
```

```powershell
# Windows PowerShell, from scripts/gpg
.\run-bootstrap-gpg.ps1
```

The scripts write the generated key material to `scripts/gpg/output`.

If you use a Helm release name other than the default `retrieval-agent-manager`, pass
`--release <custom-prefix>` and set the same value in `security.gpg.nameOverride` in your values
file.

## Back up the output

Copy `scripts/gpg/output` to a secure location outside the repository before you install. This
backup is your only recovery path.

## Upgrades

> [!CAUTION]
> Do not redeploy or regenerate GPG keys when upgrading.

Your existing GPG keys must remain in place for the upgraded installation to decrypt its data. The
provided scripts will not run if GPG keys already exist, as intended.

## Next step

Continue to [Install and upgrade](./install.md).
