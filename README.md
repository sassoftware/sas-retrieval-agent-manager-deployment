# SAS Retrieval Agent Manager

## Table of Contents

- [SAS Retrieval Agent Manager](#sas-retrieval-agent-manager)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Supported Deployment Platforms](#supported-deployment-platforms)
  - [Prerequisites](#prerequisites)
    - [Common Prerequisites](#common-prerequisites)
    - [Technical Prerequisites](#technical-prerequisites)
  - [Infrastructure Setup](#infrastructure-setup)
    - [Retrieve License](#retrieve-license)
    - [Kubernetes](#kubernetes)
    - [Database](#database)
      - [Automatic Database Initialization](#automatic-database-initialization)
      - [Manual Database Setup (Optional)](#manual-database-setup-optional)
  - [Application Deployment Guides](#application-deployment-guide)
  - [Backup and Restore Guide](#backup-and-restore-guide)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
    - [Debug Commands](#debug-commands)
  - [Contributing](#contributing)
  - [License](#license)
  - [Additional Resources](#additional-resources)

---

## Overview

SAS Retrieval Agent Manager is a comprehensive solution for managing agents or interacting directly with LLMs in a RAG or non-RAG context. This documentation provides setup and deployment instructions for multiple platforms, such as Open-Source Kubernetes (k8s), Azure Kubernetes Service (AKS), and Amazon Elastic Kubernetes Service (EKS).

## Supported Deployment Platforms

| Platform       | Description                                        |
|----------------|----------------------------------------------------|
| **Kubernetes** | Open-Source Kubernetes deployment                  |
| **Azure**      | Azure Kubernetes Service (AKS) deployment          |
| **AWS**        | Amazon Elastic Kubernetes Service (EKS) deployment |

## Prerequisites

### Common Prerequisites

All deployment types require:

- Administrative access to target infrastructure
- Database admin privileges for PostgreSQL initialization
- Access to SAS container registry credentials
- Valid SAS Retrieval Agent Manager license
- Ability to deploy resources in the `retagentmgr` namespace

### Technical Prerequisites

**Required Tools:**

- kubectl
- Helm
- Docker
- Platform-specific CLI tools (Azure CLI, AWS CLI, etc.)

## Infrastructure Setup

### Kubernetes

Choose your preferred deployment platform and follow the cluster setup guide:

| Platform       | Kubernetes Version | Setup Guide                                                             |
|----------------|--------------------|-------------------------------------------------------------------------|
| **Kubernetes** | 1.30.10            | [Getting Started](./docs/k8s-deployment.md#kubernetes-deployment-guide) |
| **Azure**      | 1.32               | [Getting Started](./docs/azure-deployment.md#azure-deployment-guide)    |
| **AWS**        | 1.32               | [Getting Started](./docs/aws-deployment.md)                             |

### Database

#### Automatic Database Initialization

SAS Retrieval Agent Manager automatically initializes the required databases during deployment unless specified otherwise. This requires providing database admin credentials in your RAM values file.

#### Manual Database Setup (Optional)

If you prefer to set up databases manually or need to avoid giving admin-level access to the SAS Retrieval Agent Manager application, see the [Manual Database Setup Guide](./scripts/db-init-scripts/readme.md).

To use manual database setup, set these values to `false` in your RAM Values file:

- `initializeDb`
- `createUsers`
- `createSchema`
- `createDB`

## Application Deployment Guide

### Retrieve License

You can use SAS Mirror Manager to access the required RAM images. There are two ways of accessing these images using SAS Mirror Manager.

- Direct Download: The user only needs to retrieve the container registry credentials and create the relative secret. Kubernetes then automatically pulls the RAM images directly from cr.sas.com using the SAS Docker credentials.

- Mirrored Registry Download: Create a mirror registry to pull the RAM images from.

Both methods will require the following steps initially:

1. Use the link in your Software Order Email to go the specific page at my.sas.com for your order.

2. Click the Downloads tab.

3. Select both the License and Certificates rows in the download table.

4. Click the Download button to download the License and Certificates.

5. [Download SAS Mirror Manager](https://support.sas.com/en/documentation/install-center/viya/deployment-tools/4/mirror-manager.html).

#### Direct Download (Recommended Method)

##### Gather Login Credentials

Use the following command to retrieve docker login credentials used for creating a secret for pulling the necessary charts for SAS Retrieval Agent Manager:

```sh
mirrormgr list remote docker login \
    --deployment-data ~path-to-certs-zip-file
```

Example Output:

```sh
docker login -u 1ABC23 -p 'deFG^hiJkLmn!o456p7q8R{stuVwXy|Z' cr.sas.com
```

##### Create Pull Secret

After getting the login information you can create a secret that is used to pull from the SAS Container Registry using the following command:

```sh
# The correct namespace to store all SAS RAM Resources
kubectl create ns retagentmgr

# Generate the kubernetes file to apply the secret
kubectl create secret docker-registry -n retagentmgr cr-sas-secret \
  --docker-server=cr.sas.com \
  --docker-username='username-from-previous-command' \
  --docker-password='password-from-previous-command' \
  --dry-run=client -o yaml > cr-sas-secret.yaml

# Apply the secret in the retagentmgr namespace
kubectl apply -f cr-sas-secret.yaml -n retagentmgr
```

After creating the secret, you should be able to pull all RAM images needed from cr.sas.com with the default settings.

#### Mirrored Registry Download

##### Populate the Registry

Use the following command to populate a mirror registry with the necessary charts for SAS Retrieval Agent Manager:

```sh
mirrormgr mirror registry \
    --destination myregistry.mydomain.com/my-namespace \
    --username myregistryuser \
    --password myregistrypassword \
    --deployment-data ~path-to-certs-zip-file
```

###### Pull from Registry

Edit your RAM Values file ([See Examples here](./examples/README.md)) to pull from that registry instead of the default, `cr.sas.com` registry.

Example Usage:

```yaml
# ====================
# GLOBAL CONFIGURATION
# ====================
global:
  image:
    repo:
      # -- Base container registry URL
      base: 'myregistry.mydomain.com/my-namespace'
```

> Note: You can find more information on how to use SAS mirror manager in the [Viya Documentation](https://go.documentation.sas.com/doc/en/itopscdc/v_067/dplyml0phy0dkr/n1h0rgtr10fpnfn1mg0s8fgfuof8.htm).

### Populate Mirror Registry with Depdendencies

The RAM package that you receive does not include some images that the RAM Helm chart is dependent on. This is only an issue if you are mirroring the RAM images to a registry before you deploy.

Before you install RAM using a mirror registry, you should mirror the images that the RAM Helm chart depends on first. This can be done by using the [mirror registry dependency script](./scripts/mirror-registry-dependencies/README.md).

### Install Required Dependencies

After you have access to the Kubernetes cluster, you must install the necessary dependencies for SAS Retrieval Agent Manager to function as expected.

| Dependency                  | Version             |                                                                              |                                                                                                                                                            |
|-----------------------------|---------------------|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ingress-Nginx               | 4.12.3              | [example](./docs/user/DependencyInstall.md#ingress-nginx)                    | [docs](https://kubernetes.github.io/ingress-nginx/deploy/)                                                                                                 |
| Kueue                       | 0.12.1              | [example](./docs/user/DependencyInstall.md#kueue)                            | [docs](https://kueue.sigs.k8s.io/docs/installation/)                                                                                                       |

> Note: It is critical to provide an `azure-dns-label` for Azure NGINX Controller deployments. This is documented at the top of the example NGINX values file given.

### Install SAS Retrieval Agent Manager

After you have configured a Kubernetes cluster and PostgreSQL database, use the following code to deploy SAS Retrieval Agent Manager on your platform:

#### Configure RAM Values File

Customize your RAM Values file based on the deployment template for your specific platform.

| Platform              | RAM Values Examples                              |
|-----------------------|--------------------------------------------------|
| **Azure**             | [Example](./examples/azure/azure-ram-values.yaml)|
| **AWS**               | [Example](./examples/aws/aws-ram-values.yaml)    |
| **Bare-Metal**        | [Example](./examples/k8s/k8s-ram-values.yaml)    |

#### Deploy with Helm

```bash
helm install my-sas-retrieval-agent-manager oci://ghcr.io/sas-institute-rnd-internal/tmp-viya-iot-ram-helm/sas-retrieval-agent-manager \
  --version 2025.9.44 \
  --values <RAM Values file>
```

Note: Until an official repository is created, a tarball installation will be required. Also, if something fails and you need to redeploy, you'll have to run `kubectl delete ns retagentmgr` first.

#### Verify Deployment

```bash
kubectl get pods -n retagentmgr
```

## Backup and Restore Guide

To backup and restore the data you use RAM for, visit the [backup and restore page](./docs/backup-restore/README.md).

## Troubleshooting

### Common Issues

**Database Connection Issues:**

- Check firewall rules and security groups
- Validate database credentials
- Ensure bidirectional connectivity between cluster and database

**Ingress Issues:**

- Verify TLS certificate validity
- Check that controller references correct certificate
- Confirm DNS resolution

**API Server or PostgREST Not Responding:**

- Run the `sas-retagentmgr-fetch-keycloak-certs` cronjob
- Delete API, PostgREST, and OAuth-proxy pods and let them spin back up

### Debug Commands

```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n retagentmgr

# Check events in namespace
kubectl get events -n retagentmgr --sort-by='.lastTimestamp'

# View resource status
kubectl get all -n retagentmgr

# Check logs
kubectl logs <pod-name> -n retagentmgr
```

## Contributing

> We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License

> This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
