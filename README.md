# SAS Retrieval Agent Manager

## Table of Contents

- [Overview](#overview)
- [Supported Deployment Platforms](#supported-deployment-platforms)
- [Prerequisites](#prerequisites)
- [Infrastructure Setup](#infrastructure-setup)
  - [Kubernetes](#kubernetes)
  - [PostgreSQL Database](#database)
- [Application Deployment Guide](#application-deployment-guide)
  - [Retrieve License](#retrieve-license)
  - [Required Dependencies](#install-required-dependencies)
  - [Preferred Ingress Controller](#install-preferred-ingress-controller)
  - [Optional Components](#install-optional-components)
  - [Installing SAS Retrieval Agent Manager](#install-sas-retrieval-agent-manager)
  - [Upgrading SAS Retrieval Agent Manager](#upgrade-sas-retrieval-agent-manager)
- [Backup and Restore Guide](#backup-and-restore-guide)
- [Connecting different LLMS](#connecting-different-llms)
- [Monitoring and Logging](#monitoring-and-logging)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Additional Resources](#additional-resources)

---

## Overview

SAS Retrieval Agent Manager is a comprehensive solution for managing agents or interacting directly with LLMs in a RAG or non-RAG context. This documentation provides setup and deployment instructions for multiple platforms, such as Open-Source Kubernetes (k8s), Azure Kubernetes Service (AKS), and Amazon Elastic Kubernetes Service (EKS).

> [!CAUTION]
> GPG Key Warning - Read Before Doing Anything

GPG keys are the encryption foundation for all sensitive data in SAS Retrieval Agent Manager. Deleting or regenerating existing GPG keys post-deployment will result in permanent, unrecoverable data loss.

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

We use the Viya-iac repositories for Node, Kubernetes, and Database provisioning in each platform for uniformity and ease of use. It is important to note that we do not require a SAS Viya license to deploy the infrastructure or application. Similarly, we do not deploy SAS Viya as part of the deployment, only the necessary infrastructure components to run SAS Retrieval Agent Manager. Follow the Kubernetes deployment guide for detailed instructions on setting up your cluster and database for SAS Retrieval Agent Manager.

| Platform       | Kubernetes Version | Setup Guide                                                             |
|----------------|--------------------|-------------------------------------------------------------------------|
| **Kubernetes** | 1.33+              | [Getting Started](./docs/k8s-deployment.md#kubernetes-deployment-guide) |
| **Azure**      | 1.33+              | [Getting Started](./docs/azure-deployment.md#azure-deployment-guide)    |
| **AWS**        | 1.33+              | [Getting Started](./docs/aws-deployment.md)                             |
| **OpenShift**  | 1.32 (OCP v4.19.1) | [Getting Started](./docs/ocp-deployment.md)                             |

### Database (PostgreSQL 15)

SAS Retrieval Agent Manager requires a PostgreSQL 15 database for storing application data, vector embeddings, and more. The database can be deployed on any platform as long as it is accessible from the Kubernetes cluster and meets the sizing recommendations based on your expected usage.

Follow your platform-specific infrastructure steps to deploy a PostgreSQL 15 database that aligns with this sizing recommendation:

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

#### Secure Database Connection

If your database requires SSL, you will need to provide the SSL certificate bundle as a Kubernetes secret in the same namespace as your SAS Retrieval Agent Manager deployment. Upload the bundle as a secret with the key of `cert.pem`. This can be done with the following commands:

```bash
# The correct namespace to store all SAS Retrieval Agent Manager Resources
kubectl create ns retagentmgr

# Create a secret with the RDS SSL Bundle you downloaded
kubectl create secret generic <your-secret-name> --from-file=cert.pem=<your-ssl-bundle>.pem -n retagentmgr
```

> **Note:** It is critical the enter the name of the secret in the `postgreSQLCertSecret` key in the ram-values under vectorizationHub.config.postgreSQLCertSecret. For example, with this secret name, it would be: `postgreSQLCertSecret: '<your-secret-name>'`

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

#### Mirror Registry Download

##### Populate the Registry

Use the [previous docker login command](#gather-login-credentials) provided by SAS Mirror Manager and populate your mirror registry with the SAS Retrieval Agent Manager images using the provided script:

```sh
./scripts/mirror-images.sh \
  myregistry.mydomain.com \
  ./helm/sas-retrieval-agent-manager/values.yaml
```

###### Use the Mirror Registry in the Values File

Edit your SAS Retrieval Agent Manager Values file to pull from that registry instead of the default, `cr.sas.com` registry.

Example Usage:

```yaml
images:
  repo:
    # -- Base container registry URL
    base: 'myregistry.mydomain.com'
```

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
| cert-manager, trust-manager | 1.18.2, 0.18.0      | [Details](./docs/user/DependencyInstall.md#certificate-and-trust-management) | [cert-manager docs](https://cert-manager.io/docs/installation/helm/), [trust-manager docs](https://cert-manager.io/docs/trust/trust-manager/installation/) |
| Linkerd                     | 2.17 (edge-24.11.8) | [Details](./docs/user/DependencyInstall.md#service-mesh)                     | [docs](https://linkerd.io/2/tasks/install-helm/)                                                                                                           |
| Kueue                       | 0.17.2              | [Details](./docs/user/DependencyInstall.md#kueue)                            | [docs](https://kueue.sigs.k8s.io/docs/installation/)                                                                                                       |

> **Note:** Order of installation matters for some dependencies, namely:
>
> 1. Certificate management components (cert-manager and trust-manager) must be installed first.
>
> 2. The service mesh (Linkerd) must be installed second, as it depends on the certificates and issuers created during the
>    first step.
>
> 3. Other dependencies or optional components can be installed in any order after that. They do not have hard dependencies on each other, but
>    do require the previous two steps to be completed to ensure internal traffic is properly secured.

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

After you have configured a Kubernetes cluster and PostgreSQL 15 database, use the following commands to deploy SAS Retrieval Agent Manager on your platform:

### Deploy GPG Keys as Kubernetes Secrets and Configmap

> [!CAUTION]
> This step is for FIRST-TIME INSTALLATION ONLY.
> GPG keys encrypt all sensitive data stored by SAS Retrieval Agent Manager. Once generated and applied before installation, they are permanently tied to that environment's encrypted data. There is no recovery path if existing keys are lost, overwritten, or regenerated against a live installation.

**NEVER run these scripts if GPG keys already exist in the retagentmgr namespace.**

**NEVER delete the GPG key secrets or configmaps from the cluster.**

**NEVER regenerate keys and reapply them to an existing installation.**

GPG keys must be deployed as Kubernetes secrets and configmaps before the initial installation of SAS Retrieval Agent Manager. This is required for the encryption and decryption of sensitive data in SAS Retrieval Agent Manager. Use the scripts located [in the scripts/gpg directory](./scripts/gpg/README.md) to deploy the GPG keys as Kubernetes secrets and configmaps.

#### Configure Values File

We have standardized the values required for deployment across all supported platforms. Please see the [example SAS Retrieval Agent Manager values file](./examples/ram-values.yaml) to get a quickstart.

##### Configure Persistent Volume Size

In the example values file under the `.Storage.embedding.pvc.size` and `.Storage.application.pvc.size` you will want to set the storage capacity. This can be shown in the example values file linked above. The application pvc size starts at 5Gi and increases from there.

> **Note:** Please be aware that the application pvc size corresponds with the amount of data purchased from SAS.

#### Deploy with Helm

```bash
helm install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version 2026.6.0 \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr \
  --create-namespace \
  --timeout 10m
```

> **Note:** Use the package section of this repository to find an installable version. Also, if something fails and you need to redeploy, it is recommended that you run `helm uninstall retrieval-agent-manager -n retagentmgr`.

#### Verify Deployment

```bash
kubectl get pods -n retagentmgr
```

### Upgrade SAS Retrieval Agent Manager

> [!CAUTION]
> DO NOT redeploy or regenerate GPG keys when upgrading.
> Your existing GPG keys must remain in place for the upgraded installation to decrypt its data. Deleting the GPG secrets/configmaps during an upgrade will permanently destroy all encrypted application data with no possibility of recovery. The provided GPG scripts will not run if GPG keys exist, as intended.

**NEVER delete or recreate the GPG secrets or configmaps before, during, or after an upgrade.**

**NEVER rerun the GPG key deployment scripts against an existing installation.**

Please be aware that you must use the same gpg keys and helm values for upgrades as you did for the initial installation. It is also recommended to use the example values file for the version you are upgrading to and copy over any custom values you had in your previous file.

```bash
helm upgrade --install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --version <SAS Retrieval Agent Manager Version> \
  --values <SAS Retrieval Agent Manager Values File> \
  -n retagentmgr \
  --timeout 10m
```

## Backup and Restore Guide

To backup and restore the data you use SAS Retrieval Agent Manager for, visit the [Backup and Restore page](./docs/backup-restore/README.md).

## Connecting different LLMS

To add different LLMs for SAS Retrieval Agent Manager to use, visit the [Connecting an LLM page](./docs/llm-connection/README.md).

## Monitoring and Logging

To monitor and log agent and LLM activity, visit the [Monitoring setup page](./docs/monitoring/README.md)

## Troubleshooting

To troubleshoot common issues with deployment, connectivity, and more, visit the [Troubleshooting page](./docs/troubleshoot.md).

## Contributing

We welcome your contributions!
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

As with any container image, direct and indirect dependencies are governed by their own licenses.
Users of the published container image are responsible for ensuring that their use complies with all applicable licenses.

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
