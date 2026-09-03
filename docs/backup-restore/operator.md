
# Velero Operator Unified Deployment Instructions

Velero is a popular tool for backup and restore of Kubernetes resources and persistent volumes. The deployment process is similar across all environments, with the main difference being the storage provider plugin and its configuration.

## Table of Contents

- [Velero Operator Unified Deployment Instructions](#velero-operator-unified-deployment-instructions)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation Methods](#installation-methods)
    - [Method 1: Helm Installation (Recommended)](#method-1-helm-installation-recommended)
    - [Method 2: CLI Installation](#method-2-cli-installation)
  - [Provider-Specific Configuration](#provider-specific-configuration)
    - [AWS S3](#aws-s3)
    - [Azure Blob Storage](#azure-blob-storage)
    - [Google Cloud Storage](#google-cloud-storage)
    - [S3-Compatible Storage (MinIO)](#s3-compatible-storage-minio)
    - [NFS Subdir External Provisioner](#nfs-subdir-external-provisioner)
  - [Verify Installation](#verify-installation)
  - [Additional Resources](#additional-resources)

---

## Prerequisites

- Kubernetes cluster with `kubectl` configured
- Helm v3 (for Helm installation)
- Storage resource prepared (S3 bucket, Azure Blob container, GCS bucket, etc.)
- Credentials for the storage provider

## Installation Methods

### Method 1: Helm Installation (Recommended)

Helm provides a declarative way to install and manage Velero with all plugins configured.

**1. Add the VMware Tanzu Helm Repository:**

```bash
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
```

**2. Create Credentials Secret:**

Create a credentials file for your provider:

```bash
# AWS credentials file (credentials-velero)
cat > credentials-velero <<EOF
[default]
aws_access_key_id=<AWS_ACCESS_KEY_ID>
aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
EOF

# Create secret in cluster
kubectl create namespace velero
kubectl create secret generic velero-credentials \
  --namespace velero \
  --from-file=cloud=credentials-velero
```

**3. Create Values File:**

Create a `velero-values.yaml` file with your configuration:

```yaml
# velero-values.yaml
configuration:
  backupStorageLocation:
    - name: default
      provider: aws
      bucket: <BUCKET_NAME>
      config:
        region: <REGION>
        s3ForcePathStyle: "false"
        s3Url: ""
  volumeSnapshotLocation:
    - name: default
      provider: aws
      config:
        region: <REGION>

credentials:
  useSecret: true
  existingSecret: velero-credentials

initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins

# Optional: Configure resource requests/limits
resources:
  requests:
    cpu: 500m
    memory: 128Mi
  limits:
    cpu: 1000m
    memory: 512Mi

# Optional: Enable scheduled backups
schedules: {}
  # daily-backup:
  #   disabled: false
  #   schedule: "0 1 * * *"
  #   template:
  #     includedNamespaces:
  #       - retagentmgr
  #     ttl: "168h"
```

**4. Install Velero with Helm:**

```bash
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --values velero-values.yaml
```

**5. Upgrade Velero:**

To update configuration or upgrade Velero:

```bash
helm upgrade velero vmware-tanzu/velero \
  --namespace velero \
  --values velero-values.yaml
```

### Method 2: CLI Installation

Use the Velero CLI for quick installation.

**1. Install the Velero CLI:**

Follow the [Velero Basic Install Guide](https://velero.io/docs/latest/basic-install/).

**2. Choose and Prepare Your Storage Provider:**

Velero supports a variety of storage backends (AWS, Azure, GCP, NFS, etc.) via plugins. Prepare the required storage resource and credentials.

**3. Deploy Velero:**

Use the `velero install` command with your provider settings:

```bash
velero install \
  --provider <PROVIDER_NAME> \
  --plugins <PLUGIN_IMAGE> \
  --bucket <BUCKET_OR_CONTAINER_NAME> \
  --secret-file <PATH_TO_CREDENTIALS> \
  --backup-location-config <KEY1=VALUE1,KEY2=VALUE2,...>
```

See the [Velero Plugins Page](https://velero.io/plugins/) for provider-specific options.

## Provider-Specific Configuration

### AWS S3

**Helm Values:**

```yaml
configuration:
  backupStorageLocation:
    - name: default
      provider: aws
      bucket: my-velero-bucket
      config:
        region: us-east-1
  volumeSnapshotLocation:
    - name: default
      provider: aws
      config:
        region: us-east-1

initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
```

**Credentials File:**

```ini
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Azure Blob Storage

**Helm Values:**

```yaml
configuration:
  backupStorageLocation:
    - name: default
      provider: azure
      bucket: velero-container
      config:
        resourceGroup: <RESOURCE_GROUP>
        storageAccount: <STORAGE_ACCOUNT>
        subscriptionId: <SUBSCRIPTION_ID>
  volumeSnapshotLocation:
    - name: default
      provider: azure
      config:
        resourceGroup: <RESOURCE_GROUP>
        subscriptionId: <SUBSCRIPTION_ID>

initContainers:
  - name: velero-plugin-for-microsoft-azure
    image: velero/velero-plugin-for-microsoft-azure:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
```

**Credentials File:**

```ini
AZURE_SUBSCRIPTION_ID=<SUBSCRIPTION_ID>
AZURE_TENANT_ID=<TENANT_ID>
AZURE_CLIENT_ID=<CLIENT_ID>
AZURE_CLIENT_SECRET=<CLIENT_SECRET>
AZURE_RESOURCE_GROUP=<RESOURCE_GROUP>
AZURE_CLOUD_NAME=AzurePublicCloud
```

### Google Cloud Storage

**Helm Values:**

```yaml
configuration:
  backupStorageLocation:
    - name: default
      provider: gcp
      bucket: my-velero-bucket
      config:
        project: <PROJECT_ID>
  volumeSnapshotLocation:
    - name: default
      provider: gcp
      config:
        project: <PROJECT_ID>

initContainers:
  - name: velero-plugin-for-gcp
    image: velero/velero-plugin-for-gcp:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
```

**Credentials File:**

Use a GCP service account JSON key file.

### S3-Compatible Storage (MinIO)

**Helm Values:**

```yaml
configuration:
  backupStorageLocation:
    - name: default
      provider: aws
      bucket: velero
      config:
        region: minio
        s3ForcePathStyle: "true"
        s3Url: http://minio.minio.svc:9000
        publicUrl: http://minio.example.com

initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
```

### NFS Subdir External Provisioner

The NFS Subdir External Provisioner dynamically provisions persistent volumes using an existing NFS server. This can be used to provide NFS-backed storage for Velero backups or other persistent storage needs.

**1. Add the Helm Repository:**

```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
```

**2. Create Values File:**

Create an `nfs-provisioner-values.yaml` file:

```yaml
# nfs-provisioner-values.yaml
nfs:
  server: <NFS_SERVER_IP_OR_HOSTNAME>
  path: /exported/path
  mountOptions:
    - nfsvers=4.1
    - hard
    - timeo=600
    - retrans=3

storageClass:
  name: nfs-client
  defaultClass: false
  allowVolumeExpansion: true
  reclaimPolicy: Retain
  archiveOnDelete: true
  accessModes: ReadWriteMany
  volumeBindingMode: Immediate

replicaCount: 1

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

**3. Install NFS Subdir External Provisioner:**

```bash
helm install nfs-subdir-external-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --namespace nfs-provisioner \
  --create-namespace \
  --values nfs-provisioner-values.yaml
```

**4. Verify Installation:**

```bash
kubectl get pods -n nfs-provisioner
kubectl get storageclass nfs-client
```

**5. Using NFS Storage with Velero (File System Backup):**

To use NFS-backed PVCs with Velero, use Velero's File System Backup (FSB) with Restic or Kopia:

```yaml
# velero-values.yaml with FSB enabled
configuration:
  backupStorageLocation:
    - name: default
      provider: aws  # Or your primary backup location
      bucket: velero-backups
      config:
        region: us-east-1
  uploaderType: restic  # Or kopia

deployNodeAgent: true

nodeAgent:
  podVolumePath: /var/lib/kubelet/pods
  privileged: true
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.10.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
```

**6. Annotate Pods for Volume Backup:**

For pods using NFS-backed PVCs, annotate them to include volumes in backups:

```bash
kubectl annotate pod/<POD_NAME> backup.velero.io/backup-volumes=<PVC_NAME>
```

Or add the annotation in your deployment:

```yaml
spec:
  template:
    metadata:
      annotations:
        backup.velero.io/backup-volumes: data-volume,config-volume
```

**Example PVC Using NFS Storage Class:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: velero-nfs-backup
  namespace: velero
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 100Gi
```

## Verify Installation

**Check Velero Deployment:**

```bash
kubectl get pods -n velero
kubectl get deployments -n velero
```

**Verify Backup Location:**

```bash
velero backup-location get
```

**Test Backup Creation:**

```bash
velero backup create test-backup --include-namespaces retagentmgr --wait
velero backup describe test-backup
```

**Check Velero Logs:**

```bash
kubectl logs deployment/velero -n velero
```

## Additional Resources

- [Velero Documentation](https://velero.io/docs/latest/)
- [Velero Plugins](https://velero.io/plugins/)
- [Velero Helm Chart](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero)
- [Velero Helm Chart Values](https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/values.yaml)

For advanced scenarios or troubleshooting, refer to the official documentation and plugin guides.
