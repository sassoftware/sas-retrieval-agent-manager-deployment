# OpenShift Deployment Guide

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Configuration Setup](#configuration-setup)
- [Database Deployment](#database-deployment)
- [PostgreSQL SSL Certificate](#deploy-postgresql-ssl-certificate)
- [Kueue Deployment](#kueue-deployment)
- [OpenShift Service Mesh 3 Deployment](#openshift-service-mesh-3-deployment)
- [Application Deployment](#application-deployment)

---

## Overview

This guide describes deploying SAS Retrieval Agent Manager on an OpenShift cluster.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to both the Kubernetes cluster

### Technical Prerequisites

**Required Access and Tools:**

- Ability to create resources in the OpenShift environment for the SAS Retrieval Agent Manager project

## Requirements

### Hardware Requirements

**Recommended Configuration:**

| Node Type                        | Count | CPUs | RAM  | Disk  | Notes                                                          |
|----------------------------------|-------|------|------|-------|----------------------------------------------------------------|
| **Control Plane Node (tainted)** | 3     | 4    | 8GB  | 50GB  |                                                                |
| **Worker Nodes**                 | 2     | 8    | 16GB | 200GB |                                                                |
| **NFS Server Node**              | 1     | 8    | 16GB | 200GB | Optional if using CSI storage; can also serve as a worker node |

### Infrastructure Requirements

- OpenShift version: 4.19.1

## Getting Started

We do not support the entire infrastructure deployment process for OpenShift like we do with AWS, Azure, and Open Source Kubernetes. You will need an already functioning OpenShift cluster. If you're interested in deploying an OpenShift cluster, [please refer to Red Hat documentation here](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/installation_overview/ocp-installation-overview).

## Configuration Setup

For the OpenShift deployment, all of the necessary deployment changes will occur if you set the `platform` key in the Values file to `openshift` as seen here:

```yaml

# @schema
# enum:
#   - "azure"
#   - "aws"
#   - "kubernetes"
#   - "openshift"
# required: true
# default: "azure"
# @schema
# -- Platform we are deploying on. (azure, aws, kubernetes, openshift)
platform: openshift

```

## Database Deployment

SAS Retrieval Agent Manager requires a PostgreSQL 15+ database. On OpenShift, the Crunchy Postgres for Kubernetes operator provides a quick and convenient way to deploy PostgreSQL directly on the cluster. However, running PostgreSQL inside the cluster shares resources with the application workloads and **will result in degraded performance** compared to a dedicated external PostgreSQL installation. A dedicated external PostgreSQL database is the preferred approach for production deployments.

> **Note:** Follow the [PostgreSQL sizing recommendations in the main README](../README.md#database) to determine your required database size before deploying.

### Install the Crunchy Postgres Operator

The Crunchy Postgres operator can be installed via the OpenShift web console or via the CLI using an `OperatorGroup` and `Subscription`.

#### Via the OpenShift Web Console

1. Log in to the OpenShift web console.
2. Navigate to **Operators → OperatorHub**.
3. Search for **"Crunchy Postgres for Kubernetes"**.
4. Select the operator and click **Install**.
5. Choose the target namespace (e.g., `postgres-operator`) and click **Install**.

#### Via CLI

Create the namespace and operator resources using the following commands:

```bash
# Create the namespace for the Postgres Operator
oc new-project postgres-operator

# Create an OperatorGroup scoped to the namespace
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: postgres-operator-group
  namespace: postgres-operator
spec:
  targetNamespaces:
    - postgres-operator
EOF

# Create a Subscription for the Crunchy Postgres Operator
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: crunchy-postgres-operator
  namespace: postgres-operator
spec:
  channel: v5
  name: crunchy-postgres-operator
  source: certified-operators
  sourceNamespace: openshift-marketplace
EOF
```

Verify the operator is running:

```bash
oc -n postgres-operator get pods --selector=postgres-operator.crunchydata.com/control-plane=postgres-operator
```

### Deploy a PostgresCluster

Once the operator is running, create a `PostgresCluster` resource. The `spec.openshift: true` flag is required for OpenShift environments.

```bash
cat <<EOF | oc apply -f -
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: sas-ram-db
  namespace: postgres-operator
spec:
  openshift: true
  postgresVersion: 15
  instances:
    - name: instance1
      replicas: 1
      dataVolumeClaimSpec:
        accessModes:
          - "ReadWriteOnce"
        resources:
          requests:
            storage: 128Gi
  backups:
    pgbackrest:
      repos:
        - name: repo1
          volume:
            volumeClaimSpec:
              accessModes:
                - "ReadWriteOnce"
              resources:
                requests:
                  storage: 128Gi
  users:
    - name: sasramadmin
      databases:
        - sasram
      options: "SUPERUSER"
EOF
```

Track the status of your cluster:

```bash
oc -n postgres-operator describe postgresclusters.postgres-operator.crunchydata.com sas-ram-db
```

Once running, retrieve the connection credentials from the generated secret:

```bash
# The secret is named <clusterName>-pguser-<userName>
oc -n postgres-operator get secret sas-ram-db-pguser-sasramadmin -o jsonpath='{.data.uri}' | base64 -d
```

> **Note:** For more details on cluster configuration, user management, and high availability, refer to the [Crunchy Postgres for Kubernetes documentation](https://access.crunchydata.com/documentation/postgres-operator/latest/).

## Deploy PostgreSQL SSL Certificate

PGO sets up a PKI and enables TLS for all connections by default. You must extract the CA and TLS certificates from the cluster-generated secrets and build a combined `cert.pem` bundle for SAS Retrieval Agent Manager to use.

### Extract the Certificate Components

PGO stores the cluster certificates in a secret named `<clusterName>-cluster-cert`. Extract the required files:

```bash
# Extract the CA certificate (used as trustedcerts.pem and ca.crt)
oc -n postgres-operator get secret sas-ram-db-cluster-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# Extract the server TLS certificate
oc -n postgres-operator get secret sas-ram-db-cluster-cert -o jsonpath='{.data.tls\.crt}' | base64 -d > tls.crt

# Extract the server TLS private key
oc -n postgres-operator get secret sas-ram-db-cluster-cert -o jsonpath='{.data.tls\.key}' | base64 -d > tls.key
```

### Construct the Certificate Bundle

The `cert.pem` secret key must contain a single PEM file that concatenates **four components in the following order**:

1. **Chain certificate** (`trustedcerts.pem`) — use `ca.crt` extracted above
2. **Intermediate certificate** (`ca.crt`)
3. **Server certificate** (`tls.crt`)
4. **Private key** (`tls.key`)

The resulting file structure should look like this:

```text
-----BEGIN CERTIFICATE-----
<ca.crt contents (chain cert)>
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
<ca.crt contents (intermediate)>
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
<tls.crt contents>
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
<tls.key contents>
-----END RSA PRIVATE KEY-----
```

Build the bundle with the following command:

```bash
cat ca.crt ca.crt tls.crt tls.key > combined-cert.pem
```

> **Note:** When using PGO's built-in PKI, the chain cert and intermediate cert are the same `ca.crt`. If you have configured `spec.customTLSSecret` with your own PKI, use your own `trustedcerts.pem` in place of the first `ca.crt`.

### Create the Kubernetes Secret

After constructing the bundle, upload it as a secret with the key of `cert.pem` in the `retagentmgr` namespace:

```bash
# The correct namespace to store all SAS Retrieval Agent Manager Resources
oc new-project retagentmgr

# Create a secret with the PostgreSQL SSL bundle
oc create secret generic postgres-ssl-cert --from-file=cert.pem=combined-cert.pem -n retagentmgr
```

> **Note:** It is critical to enter the name of the secret in the `postgreSQLCertSecret` key in the ram-values under global.configuration.vhub. For example, with this secret name, it would be: `postgreSQLCertSecret: 'postgres-ssl-cert'`

## Kueue Deployment

On OpenShift, Kueue is installed via the **OpenShift Kueue Operator** rather than the upstream Helm chart used on other platforms.

### Install the OpenShift Kueue Operator

1. Log in to the OpenShift web console.
2. Navigate to **Operators → OperatorHub**.
3. Search for **"Kueue"** and select the **OpenShift Kueue Operator**.
4. Click **Install** and accept the defaults.

Alternatively, install via CLI:

```bash
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-kueue-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: openshift-kueue-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### Create the Kueue Instance

Once the operator is running, create a `Kueue` cluster resource to enable Kueue with the `BatchJob` integration framework:

```bash
cat <<EOF | oc apply -f -
apiVersion: kueue.openshift.io/v1
kind: Kueue
metadata:
  name: cluster
  labels:
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/name: kueue-operator
spec:
  config:
    integrations:
      frameworks:
        - BatchJob
  logLevel: Normal
  managementState: Managed
  operatorLogLevel: Normal
EOF
```

Verify that Kueue is available:

```bash
oc get kueue cluster -o jsonpath='{.status.conditions}'
```

The `Available` condition should show `status: "True"` before proceeding.

### Label the SAS Retrieval Agent Manager Namespace

For Kueue to manage workloads in the `retagentmgr` namespace on OpenShift, the following label **must** be applied to the namespace:

```bash
oc label namespace retagentmgr kueue.openshift.io/managed=true
```

> **Note:** Without this label, Kueue will not intercept and manage vectorization jobs in the `retagentmgr` namespace and those jobs will fail to be queued correctly.

## OpenShift Service Mesh 3 Deployment

Red Hat OpenShift Service Mesh 3 (OSSM3) is an optional integration that enables L7 traffic management for the SAS Retrieval Agent Manager. When enabled, the Helm chart deploys an Istio **ambient-mode waypoint proxy** into the release namespace. The waypoint is an Envoy sidecar-free proxy that processes all HTTP traffic and injects the `X-Forwarded-For` header with the real source pod IP.

> **Note:** This section requires an OpenShift cluster with the Kubernetes Gateway API CRDs installed (see below). OSSM3 is based on the Sail Operator and uses a fundamentally different resource model from OSSM 1/2 — `ServiceMeshControlPlane` is not used here.

### Install the Kubernetes Gateway API CRDs

OSSM3 ambient mode relies on the Kubernetes Gateway API. Install the standard channel CRDs before installing the operator:

```bash
oc apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

Verify the CRDs are established:

```bash
oc get crd gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io grpcroutes.gateway.networking.k8s.io
```

### Install the OpenShift Service Mesh 3 Operator

#### Via the OpenShift Web Console

1. Log in to the OpenShift web console.
2. Navigate to **Operators → OperatorHub**.
3. Search for **"OpenShift Service Mesh"** and select the **Red Hat OpenShift Service Mesh** operator (version 3.x).
4. Click **Install**, select **All namespaces** scope, and accept the defaults.
5. Wait for the operator status to show **Succeeded**.

#### Via CLI

```bash
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator3
  namespace: openshift-operators
spec:
  channel: stable
  name: servicemeshoperator3
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Wait for the operator to be ready:

```bash
oc -n openshift-operators wait --for=condition=Ready pod \
  -l name=sailoperator --timeout=120s
```

### Deploy the IstioCNI Resource

Ambient mode requires the Istio CNI plugin to redirect traffic at the node level without injecting sidecars. Create an `IstioCNI` resource in the `istio-cni` namespace:

```bash
oc new-project istio-cni

cat <<EOF | oc apply -f -
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  version: v1.24.3
  namespace: istio-cni
  profile: openshift-ambient
EOF
```

Verify the CNI daemonset is running on all nodes:

```bash
oc -n istio-cni wait --for=condition=Ready pod \
  -l k8s-app=istio-cni-node --timeout=180s
```

### Deploy the Istio Control Plane

Create the `Istio` resource that provisions the `istiod` control plane:

```bash
oc new-project istio-system

cat <<EOF | oc apply -f -
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
spec:
  version: v1.24.3
  namespace: istio-system
  profile: openshift-ambient
EOF
```

Monitor the control plane until it reaches `Healthy` status:

```bash
oc -n istio-system wait --for=condition=Ready istio default --timeout=180s
```

You can also inspect the status in detail:

```bash
oc -n istio-system get istio default -o jsonpath='{.status}' | jq
```

### Enroll the Release Namespace in Ambient Mesh

Label the `retagentmgr` namespace to opt it into ambient-mode data-plane processing. This must be done **before** installing the SAS Retrieval Agent Manager Helm chart so that the waypoint Gateway is created in an ambient-enabled namespace.

```bash
# Enroll the namespace in Istio ambient mode
oc label namespace retagentmgr istio.io/dataplane-mode=ambient

# Instruct all pods/services in the namespace to route through the waypoint
oc label namespace retagentmgr istio.io/use-waypoint=waypoint
```

> **Note:** The `istio.io/use-waypoint` label value must match the `integrations.istio.waypoint.name` value in your `ram-values.yaml` (default: `waypoint`).

### Configure SAS Retrieval Agent Manager to Use the Waypoint

Enable the Istio integration in your `ram-values.yaml`:

```yaml
integrations:
  istio:
    enabled: true
    waypoint:
      # Must match the value used in the istio.io/use-waypoint namespace label
      name: waypoint
      # "all" processes both east-west service traffic and ingress workload traffic
      waypointFor: all
```

When `enabled: true`, the chart creates a `Gateway` resource with `gatewayClassName: istio-waypoint` in the release namespace. The Istio gateway controller detects this and deploys an Envoy waypoint deployment.

### Verify the Waypoint Is Running

After the Helm chart is installed, confirm the waypoint deployment is healthy:

```bash
# Check the waypoint Gateway resource
oc -n retagentmgr get gateway waypoint

# Check the Envoy waypoint pod deployed by the Istio gateway controller
oc -n retagentmgr get pods -l gateway.istio.io/managed=istio.io-mesh-controller

# Confirm the waypoint is programmed (PROGRAMMED=True)
oc -n retagentmgr get gateway waypoint -o jsonpath='{.status.conditions}' | jq
```

The `Programmed` condition should show `status: "True"` before proceeding to the Application Deployment step.

---

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.
