---
layout: default
title: Install dependencies
parent: Deployment
nav_order: 7
---

# Install dependencies

After you have access to the Kubernetes cluster, install these dependencies before you install SAS
Retrieval Agent Manager.

| Dependency | Version | Upstream documentation |
| ---------- | ------- | ---------------------- |
| cert-manager, trust-manager | 1.18.2, 0.18.0 | [cert-manager](https://cert-manager.io/docs/installation/helm/), [trust-manager](https://cert-manager.io/docs/trust/trust-manager/installation/) |
| Linkerd **or** Istio | 2.17 (edge-24.11.8) / 1.30.4 | [Linkerd](https://linkerd.io/2/tasks/install-helm/), [Istio](https://istio.io/latest/docs/) |
| NGINX **or** Contour | 4.12.3 / 1.33.1 | [NGINX](https://kubernetes.github.io/ingress-nginx/deploy/), [Contour](https://projectcontour.io/getting-started/) |
| Kueue | 0.17.2 | [Kueue](https://kueue.sigs.k8s.io/docs/installation/) |

> **Important:** Install these in order. Certificate management (cert-manager and trust-manager)
> must be first. The service mesh (Linkerd) must be second, because it depends on the certificates
> and issuers created in the first step. The ingress controller and Kueue can follow in any order.

> **Note:** On OpenShift, use the built-in OpenShift Router and the OpenShift Kueue Operator instead
> of an ingress controller Helm chart and the upstream Kueue chart. See the
> [OpenShift deployment guide](../ocp-deployment.md).

## Optional components

| Component | Version | Example values file | Instructions | Description |
| --------- | ------- | ------------------- | ------------ | ----------- |
| **Weaviate** | 17.6.0 | [weaviate.yaml](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/weaviate.yaml) | [instructions](#weaviate) | Vector database |
| **Ollama** | 1.12.0 | [ollama.yaml](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/ollama.yaml) | [instructions](../llm-connection/ollama.md) | LLM deployment platform |
| **Vector** | 0.53.0 | [vector.yaml](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/monitoring/vector.yaml) | [instructions](../monitoring/README.md) | Storing logs and traces |
| **Phoenix** | 4.0.7 | [phoenix.yaml](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/monitoring/phoenix.yaml) | [instructions](../monitoring/traces.md) | Visualizing traces |

> **Note:** If you install SAS Retrieval Agent Manager without these optional components, you can
> always install them later and connect them to your existing deployment.

## Required Dependencies

### Certificate and Trust Management

SAS Retrieval Agent Manager requires TLS certificates for secure communication. You can use cert-manager to automate the
management and issuance of TLS certificates. The provided chart:

* Installs cert-manager in your cluster to enable issuance of certificates.
* Installs trust-manager to manage the distribution of trusted CA certificates.
* Creates a self-signed CA and required issuers for generating service mesh TLS certificates.

You can install both applications onto your cluster and create service mesh prerequisites with the following commands:

```bash
# Install cert manager, creating issuers
# and certificates for subsequent use.
helm install cert-manager ./helm/cert-manager/ \
  --namespace cert-manager \
  --create-namespace \
  --rollback-on-failure

# Install trust manager, creating trust anchor
# bundle for subsequent use.
helm install trust-manager ./helm/trust-manager/ \
  --namespace cert-manager \
  --rollback-on-failure

```

> **Note:** If cert-manager is already installed on the cluster, you'll have to run `kubectl apply -f ./helm/cert-manager/templates/linkerd-certs/ -n cert-manager` instead for the expected result

### Service Mesh

SAS Retrieval Agent Manager uses Linkerd to enable mutual TLS (mTLS) for secure internal communication between its
components. The provided chart sets up the necessary configurations to enable mTLS within the application with automated
rotation of all certificates, except the trust anchor which requires some manual intervention.

> **Note:** The default Linkerd installation uses a self-signed root certificate authority (CA) to create an intermediate CA
> which acts as the trust anchor. The trust anchor certificate has a one-year validity period, with automatic rotation
> sixty days before expiration.
>
> See the [Linkerd documentation](https://linkerd.io/2.17/tasks/automatically-rotating-control-plane-tls-credentials/#9-rotating-the-trust-anchor)
> for more information on trust anchor rotation and required steps - whilst other certificate/issuer rotations are fully
> automatic, the trust anchor rotation requires some manual intervention.

You can install Linkerd, configured to use the root and trust anchor CAs created when installing cert-manager, onto your
cluster with the following commands:

```bash

helm install linkerd ./helm/linkerd \
  -n linkerd \
  --create-namespace

```

### Kueue

SAS Retrieval Agent Manager requires Kueue for workload management of vectorization jobs.

Here is an [Example Kueue Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/required/kueue.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster with the following commands:

```bash
# Install Kueue using our example values file
helm install kueue oci://registry.k8s.io/kueue/charts/kueue \
  --version=<kueue_version> \
  --namespace kueue \
  -f ./examples/dependencies/required/kueue.yaml \
  --create-namespace
```

#### Deploy the Kueue queue objects manually

Installing Kueue provides the controller. SAS Retrieval Agent Manager also needs three queue
objects: a `ResourceFlavor`, a `ClusterQueue`, and a `LocalQueue`.

By default the Helm chart creates them when `integrations.kueue.enabled` is `true`. If you set
`integrations.kueue.enabled` to `false`, you must create them yourself before SAS Retrieval Agent
Manager starts vectorization jobs.

> **Important:** Use one method only. If the chart creates the queue objects, do not apply the
> manifests. If you apply the manifests, keep `integrations.kueue.enabled` set to `false`.

Use the
[example queue manifests](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/required/kueue-queues.yaml).
They match the chart defaults. Edit the namespace and the quotas to match your cluster, then apply
the file:

```bash
kubectl apply -f kueue-queues.yaml
```

> **Note:** Match the `ClusterQueue` quotas to the capacity of the cluster you built. See
> [Job scheduling quotas](../sizing.md#job-scheduling-quotas).

Verify that the objects are created:

```bash
kubectl get resourceflavor retrieval-agent-manager
kubectl get clusterqueue cluster-queue
kubectl -n retagentmgr get localqueue genai-queue
```

> **Note:** On OpenShift, install Kueue with the OpenShift Kueue Operator instead of this Helm
> chart, and label the namespace. See the
> [OpenShift deployment guide](../ocp-deployment.md#kueue-deployment). The queue objects above are
> the same on every platform.

### Ingress Controllers

SAS Retrieval Agent Manager requires either NGINX or Contour for managing incoming traffic.

#### NGINX

Here is an [Example NGINX Controller Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/required/ingress-controllers/nginx.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster with the following commands:

```bash
# Add ingress-nginx helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install ingress-nginx using our example values file
helm install nginx-ingress-nginx-controller \
    ingress-nginx/ingress-nginx \
    --version=<nginx_version> \
    --namespace ingress-nginx \
    -f ./examples/dependencies/required/ingress-controllers/nginx.yaml \
    --create-namespace
```

#### Contour

Here is an [Example Contour Controller Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/required/ingress-controllers/contour.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster with the following commands:

```bash
# Add contour helm repository
helm repo add contour https://projectcontour.github.io/helm-charts/
helm repo update

# Install contour using our example values file
helm install contour contour/contour \
    --version=<contour_version> \
    --namespace contour \
    -f ./examples/dependencies/required/ingress-controllers/contour.yaml \
    --create-namespace
```

> **Note:** You will have to change ingress.classType to `contour` in the values file as it is nginx by default.

## Optional Components

### Weaviate

SAS has partnered with [Weaviate](https://weaviate.io/) and supports it as a vector database alternative to PGVector storage. This installation is not required but is compatible with SAS Retrieval Agent Manager.

Here is an [Example Weaviate Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/weaviate.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster with the following commands:

```bash
# Add the Helm repo that contains Weaviate
helm repo add weaviate https://weaviate.github.io/weaviate-helm
helm repo update

# Install Weaviate using our example values file
helm install weaviate weaviate/weaviate \
  --version=<weaviate_version> \
  --namespace weaviate \
  -f ./examples/dependencies/optional/weaviate.yaml \
  --create-namespace
```

### Vector

SAS Retrieval Agent Manager uses Vector for collecting, viewing, and managing logs/metrics.

Here is an [Example Vector Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/monitoring/vector.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster by reading the [installation instructions found here](../monitoring/logs-and-metrics.md#installation).

### Phoenix

SAS Retrieval Agent Manager supports [Phoenix](https://github.com/Arize-ai/phoenix), an open-source observability platform for LLM applications.

Here is an [Example Phoenix Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/dependencies/optional/monitoring/phoenix.yaml). You can edit it as you'd like to fit your deployment.

You can look at [installation instructions here](../monitoring/traces.md#installation).
