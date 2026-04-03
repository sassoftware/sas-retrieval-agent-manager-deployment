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
    - [Kubernetes](#kubernetes)
    - [Database](#database)
      - [Automatic Database Initialization](#database-initialization)
  - [Application Deployment Guide](#application-deployment-guide)
    - [Retrieve License](#retrieve-license)
      - [Direct Download (Recommended Method)](#direct-download-recommended-method)
        - [Gather Login Credentials](#gather-login-credentials)
        - [Create Pull Secret](#create-pull-secret)
      - [Mirrored Registry Download](#mirrored-registry-download)
        - [Populate the Registry](#populate-the-registry)
          - [Pull from Registry](#pull-from-registry)
    - [License Renewal Process](#license-renewal-process)
    - [Populate Mirror Registry with Depdendencies](#populate-mirror-registry-with-dependencies)
    - [Install Required Dependencies](#install-required-dependencies)
    - [Install Preferred Ingress Controller](#install-preferred-ingress-controller)
    - [Install Optional Components](#install-optional-components)
    - [Install SAS Retrieval Agent Manager](#install-sas-retrieval-agent-manager)
      - [Configure SAS Retrieval Agent Manager Values File](#configure-values-file)
      - [Deploy with Helm](#deploy-with-helm)
      - [Verify Deployment](#verify-deployment)
  - [Backup and Restore Guide](#backup-and-restore-guide)
  - [Connecting different LLMS](#connecting-different-llms)
  - [Monitoring and Logging](#monitoring-and-logging)
  - [Troubleshooting](#troubleshooting)
    - [Node Upgrades](#node-upgrades)
    - [Vectorization Jobs](#vectorization-jobs)
    - [Encryption/Decryption](#encryptiondecryption)
    - [Deployment Upgrades](#deployment-upgrades)
    - [Connection Errors](#connection-errors)
    - [Increasing PVC Storage Sizes](#increasing-vectorization-or-embedding-storage-sizes)
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
| **OpenShift**  | OpenShift Container Platform (OCP)                 |

## Prerequisites

### Common Prerequisites

All deployment types require:

- Administrative access to target infrastructure
- Database admin privileges for PostgreSQL initialization
- Access to SAS container registry credentials
- Valid SAS Retrieval Agent Manager license
- Valid TLS Certificate for your desired ingress domain
- Ability to deploy resources in the `retagentmgr` namespace

### Technical Prerequisites

**Required Tools:**

- Kubectl
- Helm v3
- Docker
- Platform-specific CLI tools (Azure CLI, AWS CLI, etc.)

## Infrastructure Setup

### Kubernetes

Choose your preferred deployment platform and follow the cluster setup guide:

| Platform       | Kubernetes Version | Setup Guide                                                             |
|----------------|--------------------|-------------------------------------------------------------------------|
| **Kubernetes** | 1.33+              | [Getting Started](./docs/k8s-deployment.md#kubernetes-deployment-guide) |
| **Azure**      | 1.33+              | [Getting Started](./docs/azure-deployment.md#azure-deployment-guide)    |
| **AWS**        | 1.33+              | [Getting Started](./docs/aws-deployment.md)                             |
| **OpenShift**  | 1.32 (OCP v4.19.1) | [Getting Started](./docs/ocp-deployment.md)                             |

### Database

Follow your platform-specific infrastructure steps to deploy a PostgreSQL database that aligns with this sizing recommendation:

| Deployment Size  |  Total vCPU(min) | Total RAM(Gb) |   Storage(Gb) |    Queries per day    |   Agents/Custom Sources/MCP Servers |
|------------------|------------------|---------------|---------------|-----------------------|-------------------------------------|
|    Small         |        4         |       16      |      128      |        4000           |                 6                   |
|    Medium        |        4         |       16      |      128      |        8000           |                 20                  |
|    Large         |        8         |       32      |      128      |        8000+          |                 20+                 |

#### Necessary PostgreSQL Extensions

The following extensions are either required or recommended for the Retrieval Agent manager deployment:

| Extension      | Required/Recommended   | Description                                                                       |
|----------------|------------------------|-----------------------------------------------------------------------------------|
| **PGCrypto**   | Required               | Database encryption of application data                                           |
| **Vector**     | Recommended            | Storing vector embeddings in the PostgreSQL database (alternative is Weaviate)    |

#### Database Initialization

SAS Retrieval Agent Manager automatically initializes the required databases during deployment unless specified otherwise. This requires providing database admin credentials in your SAS Retrieval Agent Manager values file.

## Application Deployment Guide

### Retrieve License

You can use SAS Mirror Manager to access the required SAS Retrieval Agent Manager images. There are two ways of accessing these images using SAS Mirror Manager.

- Direct Download: The user only needs to retrieve the container registry credentials and create the relative secret. Kubernetes then automatically pulls the SAS Retrieval Agent Manager images directly from cr.sas.com using the SAS Docker credentials.

- Mirrored Registry Download: Create a mirror registry to pull the SAS Retrieval Agent Manager images from.

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
# The correct namespace to store all SAS Retrieval Agent Manager Resources
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

After creating the secret, you should be able to pull all SAS Retrieval Agent Manager images needed from cr.sas.com with the default settings.

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

Edit your SAS Retrieval Agent Manager Values file ([See Examples here](./examples/README.md)) to pull from that registry instead of the default, `cr.sas.com` registry.

Example Usage:

```yaml
images:
  repo:
    # -- Base container registry URL
    base: 'myregistry.mydomain.com/my-namespace'
```

> **Note:** You can find more information on how to use SAS mirror manager in the [Viya Documentation](https://go.documentation.sas.com/doc/en/itopscdc/v_067/dplyml0phy0dkr/n1h0rgtr10fpnfn1mg0s8fgfuof8.htm).

### License Renewal Process

For migrating a license from a renewal to SAS Retrieval Agent Manager, use the following steps:

1. Use the link in your Software License Renewal Confirmation email to go the specific page at my.sas.com for your order.

2. Click the Downloads tab.

3. Select both the License and Certificates rows in the download table.

4. Click the Download button to download the License and Certificates.

5. [Download SAS Mirror Manager](https://support.sas.com/en/documentation/install-center/viya/deployment-tools/4/mirror-manager.html).

6. [Update the pull secret](#create-pull-secret).

7. Update your license.jwt in the license-secret secret found in the `retagentmgr` namespace with the new license using the following command: `kubectl edit secret license-secret -n retagentmgr`.

8. Restart the `sas-retrieval-agent-manager-api` pod in your SAS Retrieval Agent Manager deployment.

9. Restart your agents via the UI.

### Populate Mirror Registry with Dependencies

The SAS Retrieval Agent Manager package that you receive does not include some underlying external dependencies. This is only an issue if you are mirroring the SAS Retrieval Agent Manager images to a registry before you deploy.

To solve this, before you perform the installation using a mirror registry, mirror the images that the SAS Retrieval Agent Manager Helm chart depends on first. These images can be found under the `images` section of the values file.

### Install Required Dependencies

After you have access to the Kubernetes cluster, you must install the necessary dependencies for SAS Retrieval Agent Manager to function as expected.

| Dependency                  | Version             |                                                                              |                                                                                                                                                            |
|-----------------------------|---------------------|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| cert-manager, trust-manager | 1.18.2, 0.18.0      | [example](./docs/user/DependencyInstall.md#certificate-and-trust-management) | [cert-manager docs](https://cert-manager.io/docs/installation/helm/), [trust-manager docs](https://cert-manager.io/docs/trust/trust-manager/installation/) |
| Linkerd                     | 2.17 (edge-24.11.8) | [example](./docs/user/DependencyInstall.md#service-mesh)                     | [docs](https://linkerd.io/2/tasks/install-helm/)                                                                                                           |
| Kueue                       | 0.13.4              | [example](./docs/user/DependencyInstall.md#kueue)                            | [docs](https://kueue.sigs.k8s.io/docs/installation/)                                                                                                       |

> **Note:** Order of installation matters for some dependencies, namely:
>
> 1. Certificate management components (cert-manager and trust-manager) must be installed first.
>
> 2. The service mesh (Linkerd) must be installed second, as it depends on the certificates and issuers created during the
>    first step.
>
> 3. Other dependencies or optional components can be installed in any order after that. They do not have hard dependencies on each other, but
>    do require the previous two steps to be completed to ensure internal traffic is properly secured.
> **Note:** It is critical to provide an `azure-dns-label` for Azure ingress controller deployments. This is documented at the top of the example NGINX/Contour values file given.

### Install Preferred Ingress Controller

SAS Retrieval Agent Manager supports two ingress controllers as of now; NGINX and contour. Select your preferred one and follow the installation steps accordingly.

| Component   |    Version    |    Installation Example                                       |       Installation Documentation                           |                         |
|-------------|---------------|---------------------------------------------------------------|----------------------------------------------------------- |-------------------------|
| **NGINX**   |4.12.3         |[example](./docs/user/DependencyInstall.md#nginx)              | [docs](https://kubernetes.github.io/ingress-nginx/deploy/) |                         |
| **Contour** |1.33.1         |[example](./docs/user/DependencyInstall.md#contour)            | [docs](https://projectcontour.io/getting-started/)         |                         |

### Install Optional Components

| Component         | Version|               Example Values File                                             |                      Installation Instructions                     |        Description      |
|-------------------|--------|-------------------------------------------------------------------------------|--------------------------------------------------------------------|-------------------------|
| **Weaviate**      |17.6.0  |[weaviate.yaml](./examples/dependencies/optional/weaviate.yaml)                | [instructions](./docs/user/DependencyInstall.md#weaviate)          | Vector Database         |
| **Ollama**        |1.12.0  |[ollama.yaml](./examples/dependencies/optional/ollama.yaml)                    | [instructions](./docs/llm-connection/ollama.md)                    | LLM Deployment Platform |
| **Vector**        |0.53.0  |[vector.yaml](./examples/dependencies/optional/monitoring/vector.yaml)         | [instructions](./docs/monitoring/README.md)                        | Storing Logs/Traces     |
| **Phoenix**       |4.0.7   |[phoenix.yaml](./examples/dependencies/optional/monitoring/phoenix.yaml)       | [instructions](./docs/monitoring/traces.md)                        | Visualizing Traces      |

> **Note:** If you install SAS Retrieval Agent Manager without these optional components, you can always install them later and connect them to your existing deployment.

### Install SAS Retrieval Agent Manager

After you have configured a Kubernetes cluster and PostgreSQL 15 database, use the following code to deploy SAS Retrieval Agent Manager on your platform:

#### Configure Values File

We have standardized the values required for deployment across all supported platforms. Please see the [example SAS Retrieval Agent Manager values file](./examples/ram-values.yaml) to get a quickstart.

##### Configure Persistent Volume Size

In the example values file under the `.Storage.embedding.pvc.size` and `.Storage.application.pvc.size` you will want to set the storage capacity. This can be shown in the example values file linked above. The application pvc size starts at 5Gi and increases from there.

> **Note:** Please be aware that the application pvc size corresponds with the amount of data purchased from SAS.

#### Deploy with Helm

```bash
helm install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version 2026.3.2 \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr \
  --create-namespace \
  --timeout 10m
```

> **Note:** Use the package section of this repository to find an installable version. Also, if something fails and you need to redeploy, it is recommended that you run `helm uninstall retrieval-agent-manager -n retagentmgr` followed by `kubectl delete ns retagentmgr`. We recommend putting the `ingress-tls` and `cr-sas-secret` secrets in the `extraObjects` of the values install so that you can easily reinstall.

#### Verify Deployment

```bash
kubectl get pods -n retagentmgr
```

## Backup and Restore Guide

To backup and restore the data you use SAS Retrieval Agent Manager for, visit the [Backup and Restore page](./docs/backup-restore/README.md).

## Connecting different LLMS

To add different LLMs for SAS Retrieval Agent Manager to use, visit the [Connecting an LLM page](./docs/llm-connection/README.md).

## Monitoring and Logging

To monitor and log agent and LLM activity, visit the [Monitoring setup page](./docs/monitoring/README.md)

## Troubleshooting

### Node Upgrades

SAS Retrieval Agent Manager deploys Pod Disruption Budgets (PDBs) for all deployments to improve availability. However, these **will** interfere with node pool draining during upgrades. To work around this, delete the PDBs before draining the node pool, then redeploy them once the upgrade is complete.

### Vectorization Jobs

A vectorization job has failed if it ends in a failed state, or if it completes with a warning and the resulting collection is unusable. If this occurs, verify the following:

- The `Vector` extension is installed in your PostgreSQL database
- The `db-init` and `db-migration` jobs completed without errors

If this is the case, please install the `Vector` extension and reinstall SAS Retrieval Agent Manager or use Weaviate as a vector database instead.

### Encryption/Decryption

Encryption issues typically arise when SAS Retrieval Agent Manager is deployed multiple times without GPG keys configured in the values file. If this occurs, verify the following:

- The deployment was upgraded or reinstalled with the correct GPG keys set in the values file
  - The public key can be found in ConfigMaps, and the private key in Secrets, within the `retagentmgr` namespace

If this is the case, insert the GPG keys in the values file and reinstall SAS Retrieval Agent manager.

### Deployment Upgrades

Issues can occur when installing a newer version of SAS Retrieval Agent Manager over an existing deployment. If this occurs, verify the following:

- The values file used during the upgrade matches the schema and conventions expected by the target version

### Connection Errors

Login issues may present as an error message after login indicating that the API or PostgREST pod is not functioning correctly. If this occurs, verify the following:

- The database and Kubernetes cluster are both running and healthy

### Increasing Vectorization or Embedding Storage Sizes

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

helm upgrade retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version <SAS Retrieval Agent Manager Version> \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr

```

> **Note:** Once you increase a PVC size, you cannot decrease it with an upgrade. You will have to uninstall SAS Retrieval Agent Manager completely and reinstall from scratch to lower it at that point.

## Contributing

> We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License

> This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
