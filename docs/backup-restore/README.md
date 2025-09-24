# Backup & Restore Guide

This folder provides documentation and instructions for managing backup and restore operations in Kubernetes environments using Velero.

## Contents

- [operator.md](./operator.md): Operator instructions for deploying Velero on AWS, Azure, GCP, and native Kubernetes (including NFS plugin example).
- [backup.md](./backup.md): Steps to configure backups for a PersistentVolumeClaim (PVC) named `vhub-pv` using Velero.
- [restore.md](./restore.md): Steps to restore data to a PVC named `vhub-pv` using Velero.

## Purpose

These documents are intended to help operators and users:

- Deploy Velero in various cloud and on-premises environments
- Configure and execute backups for critical volumes
- Restore data efficiently in case of failure or migration

Refer to each file for detailed, step-by-step instructions tailored to your platform and use case.
