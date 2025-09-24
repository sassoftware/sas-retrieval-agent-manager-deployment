# Velero Restore to PVC 'vhub-pv'

To restore a backup to a PersistentVolumeClaim (PVC) named `vhub-pv` using Velero:

## Prerequisites

- A Velero backup containing the PVC `vhub-pv` exists.
- The target namespace is available in the cluster.

## Steps

1. List available backups:

   ```sh
   velero backup get
   ```

2. Restore the backup:

   ```sh
   velero restore create --from-backup vhub-pv-backup
   ```

   Replace `vhub-pv-backup` with the name of your backup.

3. Optionally, restore to a different namespace:

   ```sh
   velero restore create --from-backup vhub-pv-backup \
     --namespace-mappings <SOURCE_NAMESPACE>:<TARGET_NAMESPACE>
   ```

## Verification

- Check restore status:

  ```sh
  velero restore get
  ```

- View restore details:

  ```sh
  velero restore describe <RESTORE_NAME>
  ```
