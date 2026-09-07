---
layout: default
title: Cluster sizing
parent: Deployment
nav_order: 1
---

# Cluster sizing
{: .no_toc }

1. TOC
{:toc}

---

SAS Retrieval Agent Manager sizing is **platform-independent**. A tier defines a CPU, memory, and
storage requirement. It does not define a cloud provider instance type.

Size a deployment in three steps:

1. [Choose a tier](#step-1-choose-a-tier) from your expected workload.
2. Read the [resource requirements](#step-2-tier-requirements) for that tier.
3. [Select any instance type](#step-3-example-instance-types) on your platform that meets those
   requirements.

The same tier requires the same resources on Azure Kubernetes Service (AKS), Amazon Elastic
Kubernetes Service (EKS), OpenShift, and upstream Kubernetes.

## Step 1: Choose a tier

Tiers are defined by workload, not by infrastructure:

| Tier       | Queries per day | Agents, custom sources, and MCP servers |
|------------|-----------------|------------------------------------------|
| **Small**  | Up to 4000      | Up to 6                                  |
| **Medium** | Up to 8000      | Up to 20                                 |
| **Large**  | More than 8000  | More than 20                             |

Guidance:

- If your workload falls between two tiers, choose the larger tier.
- The agent count is usually the stronger signal. Each running agent, custom source, and MCP server
  holds a scheduled pod, so it consumes cluster capacity even when query volume is low.
- If you expect to exceed the Large tier, contact SAS before you deploy.

## Step 2: Tier requirements

These are the worker node requirements. They apply to every platform.

| Tier       | Worker nodes | vCPU per node | RAM per node (minimum) | RAM per node (recommended) |
|------------|--------------|---------------|------------------------|-----------------------------|
| **Small**  | 1 to 3       | 8             | 32 GiB                 | 64 GiB                      |
| **Medium** | 2 to 6       | 8             | 32 GiB                 | 64 GiB                      |
| **Large**  | 2 to 8       | 16            | 64 GiB                 | 128 GiB                     |

> **Important:** Use the **recommended** memory if you run embedding or vectorization workloads.
> Vectorization jobs request 8 GiB by default, and the supported embedding models default to 16 GiB
> each. A cluster built to the minimum memory figure can schedule fewer concurrent jobs.

Node counts are a range because the cluster autoscaler scales between them. Size your quotas and
capacity planning against the maximum node count.

## Step 3: Example instance types

The following instance types satisfy the requirements above. They are examples. Any instance type
that meets the vCPU and memory requirement for your tier is supported.

| Tier       | Azure                             | AWS                            |
|------------|-----------------------------------|--------------------------------|
| **Small**  | `Standard_D8s_v5` (8 vCPU, 32 GiB)  | `r6in.2xlarge` (8 vCPU, 64 GiB)  |
| **Medium** | `Standard_D8s_v5` (8 vCPU, 32 GiB)  | `r6in.2xlarge` (8 vCPU, 64 GiB)  |
| **Large**  | `Standard_D16s_v5` (16 vCPU, 64 GiB) | `r6in.4xlarge` (16 vCPU, 128 GiB) |

The two families differ in memory ratio, which is why the same tier looks different per provider:

- Azure `D`-series is general purpose and provides **4 GiB per vCPU**. These examples meet the
  **minimum** memory requirement.
- AWS `r6in` is memory-optimized and provides **8 GiB per vCPU**. These examples meet the
  **recommended** memory requirement.

To match the recommended figure on Azure, use a memory-optimized `E`-series instance such as
`Standard_E8s_v5` (8 vCPU, 64 GiB) or `Standard_E16s_v5` (16 vCPU, 128 GiB). To reduce cost on AWS
where embedding workloads are light, a general purpose `m6i` instance meets the minimum.

> **Note:** The shipped Terraform examples default to the recommended memory figure. The AWS example
> uses `r6in.2xlarge` and the Azure example uses `Standard_d16s_v7`, both of which provide 64 GiB per
> node.

## Pod limits per node

Pod density is not a constraint at any tier, but verify it if you use small instances or run other
workloads on the same cluster.

A deployment requires roughly **30 to 40 pods across the whole cluster**:

| Workload                          | Pods                                          |
|-----------------------------------|-----------------------------------------------|
| SAS Retrieval Agent Manager       | 8 (API, UI, PostgREST, and Keycloak, 2 each)  |
| Child workloads (agents, sources, evaluations, models) | Up to 6, capped by the Kueue `podQuota` |
| Required dependencies             | 15 to 25                                      |
| Per-node agents                   | 1 to 2 per node (Linkerd, and Envoy if you use Contour) |

At the Small tier the node pool can scale down to a single node, so plan for the full 30 to 40 pods
landing on one node.

### Amazon EKS

EKS is the only supported platform with a pod limit tied to the instance type. The Amazon VPC CNI
assigns each pod an IP address from the node's elastic network interfaces:

```text
maxPods = (number of ENIs x (IPs per ENI - 1)) + 2
```

Managed node groups also enforce a hard cap: **110 pods** for instances with fewer than 30 vCPU, and
250 pods above that. Every instance type in this guide has fewer than 30 vCPU, so the cap is 110.

The recommended instance types support well above the 30 to 40 pods a deployment needs. Confirm the
figure for any instance type you substitute:

```bash
aws ec2 describe-instance-types \
  --filters "Name=instance-type,Values=<instance-type>" \
  --query 'InstanceTypes[*].[InstanceType, NetworkInfo.MaximumNetworkInterfaces, NetworkInfo.Ipv4AddressesPerInterface]' \
  --output table
```

If you need more pods per node than the formula allows, enable
[prefix delegation](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html)
in the VPC CNI rather than moving to a larger instance.

### Other platforms

- **AKS** uses Azure CNI Overlay in the shipped example, which does not consume VNet IP addresses per
  pod. The default limit is 250 pods per node.
- **Upstream Kubernetes and OpenShift** use the kubelet default of 110 pods per node.

## Control plane and storage nodes

Managed platforms (AKS, EKS) operate the control plane for you. Size only the worker nodes.

On upstream Kubernetes and OpenShift you also size the control plane. The worker node requirements
are the tiers in [Step 2](#step-2-tier-requirements) and do not change.

| Node type            | Upstream Kubernetes | OpenShift | vCPU | RAM   | Disk  |
|----------------------|---------------------|-----------|------|-------|-------|
| Control plane (tainted) | 1 node           | 3 nodes   | 4    | 8 GiB | 50 GiB |
| NFS server           | 1 node (optional)   | 1 node (optional) | 8 | 16 GiB | 200 GiB |

- OpenShift uses three control plane nodes for high availability. A single control plane node is
  suitable only for non-production upstream Kubernetes clusters.
- The NFS server node is required only when your storage class is `nfs-client`. On OpenShift it is
  optional if you use CSI storage. It can also be an extra worker node.
- Allow at least 200 GiB of disk per worker node.

## Job scheduling quotas

Kueue caps the resources that agents, evaluations, source pods, and model services can consume. The
chart defaults are:

```yaml
integrations:
  kueue:
    config:
      cpuQuota: "32"
      memoryQuota: "128Gi"
      podQuota: 6
```

Set these to fit the cluster you actually built. The quota must not exceed the total allocatable
capacity at your maximum node count, or jobs are admitted that the cluster cannot schedule.

The defaults suit a Small or Medium cluster built to the **recommended** memory figure. If you build
to the minimum figure, lower `memoryQuota` accordingly.

## Database sizing

The PostgreSQL database is sized separately and uses the same tier names. See
[Configure the database](./database.md#sizing).

## Storage sizing

| Volume            | Values key                     | Default | Notes                                        |
|-------------------|--------------------------------|---------|----------------------------------------------|
| Application (vhub) | `storage.application.pvc.size` | 20Gi    | Set to the amount of data purchased from SAS |
| Embedding         | `storage.embedding.pvc.size`   | 40Gi    | Sized for your embedding models              |

> **Caution:** You can increase a PVC size with an upgrade, but you cannot decrease it. See
> [Increasing vectorization or embedding storage sizes](./troubleshoot.md#increasing-vectorization-or-embedding-storage-sizes).
