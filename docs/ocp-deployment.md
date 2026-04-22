# OpenShift Deployment Guide

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Configuration Setup](#configuration-setup)
- [Database Deployment](#database-deployment)
- [PostgreSQL SSL Certificate](#deploy-postgresql-ssl-certificate)
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

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.
