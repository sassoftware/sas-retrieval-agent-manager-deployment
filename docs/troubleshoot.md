---
layout: default
title: Troubleshooting
nav_order: 8
---

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

Encryption issues typically arise when SAS Retrieval Agent Manager is deployed without GPG keys configured. If this occurs, verify the following:

- The public key can be found in ConfigMaps within the `retagentmgr` namespace
- The private key can be found in Secrets, within the `retagentmgr` namespace
- The passphrase can be found in Secrets, within the `retagentmgr` namespace

Commands to get your gpg keys using kubectl:

```bash
# Private Key
kubectl get secret retrieval-agent-manager-gpg-private-key -n retagentmgr -o jsonpath='{.data}'

# Public Key
kubectl get cm retrieval-agent-manager-gpg-public-key -n retagentmgr -o jsonpath='{.data}'

# Passphrase
kubectl get secret retrieval-agent-manager-gpg-passphrase -n retagentmgr -o jsonpath='{.data}'

```

If these are missing, please create them using the instructions in the [gpg helper script](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/tree/main/scripts/gpg).

## Deployment Upgrades

Issues can occur when installing a newer version of SAS Retrieval Agent Manager over an existing deployment. If this occurs, verify the following:

- The values file used during the upgrade matches the schema and conventions expected by the target version

## Connection Errors

Login issues may present as an error message after login indicating that the API or PostgREST pod is not functioning correctly. If this occurs, verify the following:

- The database and Kubernetes cluster are both running and healthy

## API Forbidden Errors on Kubernetes Resources

The API pod starts and passes its health probes, but agent and collection status never loads, and
the API log reports a `403` against the Kubernetes API:

```text
WARNING - Could not find deployment: Forbidden
ERROR - Streaming task Task-164464 failed: (403)
Reason: Forbidden: deployments.apps is forbidden: User
"system:serviceaccount:retagentmgr:retrieval-agent-manager-api" cannot watch resource
"deployments" in API group "apps" in the namespace "retagentmgr"
```

The API reads and watches Deployments, Jobs, CronJobs, Services, ConfigMaps, Secrets, Pods and
HorizontalPodAutoscalers in its own namespace. The chart grants that through a namespace-scoped
`Role` and `RoleBinding` named after the API ServiceAccount. A `403` means those objects are
missing or do not bind the account the pod runs under.

Check what the account is actually allowed to do:

```bash
# Should print "yes"
kubectl auth can-i watch deployments.apps -n <namespace> \
  --as=system:serviceaccount:<namespace>:retrieval-agent-manager-api

# Both objects should exist
kubectl get role,rolebinding retrieval-agent-manager-api -n <namespace>

# The subject must match the account the pod runs under
kubectl get rolebinding retrieval-agent-manager-api -n <namespace> -o yaml
kubectl get deployment retrieval-agent-manager-api -n <namespace> \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'
```

If the `Role` and `RoleBinding` are missing, the release predates the fix that decoupled them from
`api.serviceAccount.create`. In chart versions before that change, setting
`api.serviceAccount.create: false` to use a pre-provisioned ServiceAccount also suppressed the
API's RBAC, while `api.serviceAccount.name` kept resolving to the same account. The pod therefore
ran under the expected identity with no permissions. Upgrade the chart, or apply the `Role` and
`RoleBinding` by hand:

```bash
helm template <release> <chart> -n <namespace> -f <your-values.yaml> \
  -s templates/api/role.yaml -s templates/api/rolebinding.yaml | kubectl apply -f -
```

> [!NOTE]
> These are namespace-scoped objects, so this does not require a cluster administrator. It is
> unrelated to the `SecurityContextConstraints` grant described in
> [OpenShift Deployment](ocp-deployment.md); an SCC controls whether a pod may start, not what it
> may call once running.

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
