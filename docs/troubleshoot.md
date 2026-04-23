# Troubleshooting

This section provides information on how to troubleshoot common issues that may arise when deploying or using SAS Retrieval Agent Manager.

## Node Upgrades

SAS Retrieval Agent Manager deploys Pod Disruption Budgets (PDBs) for all deployments to improve availability. However, these **will** interfere with node pool draining during upgrades. To work around this, delete the PDBs before draining the node pool, then redeploy them once the upgrade is complete.

## Vectorization Jobs

A vectorization job has failed if it ends in a failed state, or if it completes with a warning and the resulting collection is unusable. If this occurs, verify the following:

- The `Vector` extension is installed in your PostgreSQL database
- The `db-init` and `db-migration` jobs completed without errors

If this is the case, please install the `Vector` extension and reinstall SAS Retrieval Agent Manager or use Weaviate as a vector database instead.

## Encryption/Decryption

Encryption issues typically arise when SAS Retrieval Agent Manager is deployed multiple times or upgraded without GPG keys configured in the values file. If this occurs, verify the following:

- The deployment was upgraded or reinstalled with the correct GPG keys set in the values file
  - The public key can be found in ConfigMaps, and the private key in Secrets, within the `retagentmgr` namespace

If this is the case, insert the GPG keys in the values file and reinstall SAS Retrieval Agent manager.

Commands to get your gpg keys using kubectl:

```bash
# Private Key
kubectl get secret retrieval-agent-manager-gpg-private-key -n retagentmgr -o jsonpath='{.data}'

# Public Key
kubectl get cm retrieval-agent-manager-gpg-public-key -n retagentmgr -o jsonpath='{.data}'

```

## Deployment Upgrades

Issues can occur when installing a newer version of SAS Retrieval Agent Manager over an existing deployment. If this occurs, verify the following:

- The values file used during the upgrade matches the schema and conventions expected by the target version

## Connection Errors

Login issues may present as an error message after login indicating that the API or PostgREST pod is not functioning correctly. If this occurs, verify the following:

- The database and Kubernetes cluster are both running and healthy

## Increasing Vectorization or Embedding Storage Sizes

Before you deploy SAS Retrieval Agent Manager, you will need to set the Vectorization Hub PVC size equal to the amount of gigabytes purchased in your order. If you purchase more storage afterwards, you will have to upgrade the vectorization hub PVC. For the embedding-pvc or vhub-pvc, you can change the sizes of them in the values file with the following fields:

Vectorization Hub PVC:

```yaml

storage:
  application:
    pvc:
      size: <total_gigabytes_purchased> # ex: 20Gi

```

Embedding PVC:

```yaml

storage:
  embedding:
    pvc:
      size: <desired_pvc_size> # ex: 20Gi

```

Once you override the desired fields in your values file, upgrade your SAS Retrieval Agent Manager installation with the following command to apply the changes:

```sh

helm upgrade --install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version <SAS Retrieval Agent Manager Version> \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr

```

> **Note:** Once you increase a PVC size, you cannot decrease it with an upgrade. You will have to uninstall SAS Retrieval Agent Manager completely and reinstall from scratch to lower it at that point.
