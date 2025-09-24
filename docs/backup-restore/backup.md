# Velero Backup Configuration for PVC 'vhub-pv'

To back up a PersistentVolumeClaim (PVC) named `vhub-pv` using Velero:

## Prerequisites

- Velero is installed and configured in your Kubernetes cluster.
- The PVC `vhub-pv` exists in the target namespace.

## Steps

1. Create a backup for the PVC:

   ```sh
   velero backup create vhub-pv-backup \
     --include-resources persistentvolumeclaims,persistentvolumes \
     --selector 'claimName=vhub-pv' \
     --namespace 'retagentmgr'
   ```

2. To back up the entire namespace (including the PVC):

   ```sh
   velero backup create vhub-pv-namespace-backup \
     --namespace 'retagentmgr'
   ```

## Verification

- Check backup status:

  ```sh
  velero backup get
  ```

- View backup details:

  ```sh
  velero backup describe vhub-pv-backup
  ```
