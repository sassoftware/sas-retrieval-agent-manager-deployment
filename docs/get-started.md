---
layout: default
title: Get started
nav_order: 2
permalink: /get-started/
---

# Get started
{: .no_toc }

1. TOC
{:toc}

---

This page covers everything you need before you deploy SAS Retrieval Agent Manager. Complete it
once, then follow the [Deployment](./deployment.md) section for your platform.

## Prerequisites

All deployment types require:

- Administrative access to target infrastructure
- Database admin privileges for PostgreSQL initialization
- Access to SAS container registry credentials
- Valid SAS Retrieval Agent Manager license
- Valid TLS certificate for your desired ingress domain
- Ability to deploy resources in the `retagentmgr` namespace

**Required tools:**

- kubectl
- Helm v3
- Docker
- Platform-specific CLI tools (Azure CLI, AWS CLI, and so on)

## Choose a platform

| Platform       | Kubernetes version | Setup guide                            |
|----------------|--------------------|----------------------------------------|
| **Kubernetes** | 1.35+              | [Kubernetes deployment](./k8s-deployment.md)   |
| **Azure**      | 1.35+              | [Azure deployment](./azure-deployment.md)      |
| **AWS**        | 1.35+              | [AWS deployment](./aws-deployment.md)          |
| **OpenShift**  | 1.32 (OCP v4.19.1) | [OpenShift deployment](./ocp-deployment.md)    |

We use the Viya IAC repositories for node, Kubernetes, and database provisioning on each platform
for uniformity and ease of use.

> **Note:** A SAS Viya license is not required to deploy the infrastructure or the application, and
> SAS Viya is not deployed as part of this process. Only the infrastructure components needed to run
> SAS Retrieval Agent Manager are created.

## Retrieve your license

Use SAS Mirror Manager to access the required SAS Retrieval Agent Manager images. There are two ways
to access these images:

- **Direct download (recommended).** Retrieve the container registry credentials and create the
  corresponding secret. Kubernetes then pulls the images directly from `cr.sas.com`.
- **Mirrored registry download.** Create a mirror registry to pull the images from.

Both methods require these steps first:

1. Use the link in your Software Order Email to go to the specific page at my.sas.com for your
   order.
2. Click the **Downloads** tab.
3. Select both the **License** and **Certificates** rows in the download table.
4. Click **Download** to download the license and certificates.
5. [Download SAS Mirror Manager](https://support.sas.com/en/documentation/install-center/viya/deployment-tools/4/mirror-manager.html).

### Gather login credentials

Retrieve the Docker login credentials used to create the image pull secret:

```sh
mirrormgr list remote docker login \
    --deployment-data ~path-to-certs-zip-file
```

Example output:

```sh
docker login -u 1ABC23 -p 'deFG^hiJkLmn!o456p7q8R{stuVwXy|Z' cr.sas.com
```

### Create the pull secret

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

After you create the secret, you can pull all required images from `cr.sas.com` with the default
settings.

### Use a mirror registry

See
[Mirror Container Images](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/tree/main/scripts/mirror)
for requirements and usage instructions.

The SAS Retrieval Agent Manager package does not include some underlying external dependencies. If
you mirror images to a registry before you deploy, first mirror the images that the Helm chart
depends on. These images are listed under the `images` section of the values file.

### Renew a license

1. Use the link in your Software License Renewal Confirmation email to go to the specific page at
   my.sas.com for your order.
2. Click the **Downloads** tab.
3. Select both the **License** and **Certificates** rows in the download table.
4. Click **Download** to download the license and certificates.
5. [Download SAS Mirror Manager](https://support.sas.com/en/documentation/install-center/viya/deployment-tools/4/mirror-manager.html).
6. [Update the pull secret](#create-the-pull-secret).
7. Update `license.jwt` in the `license-secret` secret in the `retagentmgr` namespace:
   `kubectl edit secret license-secret -n retagentmgr`.
8. Restart the `sas-retrieval-agent-manager-api` pod.
9. Restart your agents from the user interface.

## Next step

Continue to [Deployment](./deployment.md) and select your platform.
