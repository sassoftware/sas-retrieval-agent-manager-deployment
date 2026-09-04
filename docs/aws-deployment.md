---
layout: default
title: AWS deployment
parent: Deployment
nav_order: 3
has_children: true
---

# AWS deployment
{: .no_toc }

1. TOC
{:toc}

---

## Overview

This guide describes deploying an AWS infrastructure on which to deploy SAS Retrieval Agent Manager.

Complete [Get started](./get-started.md) first. It covers the common prerequisites, tools, and
license retrieval for every platform.

## Prerequisites

In addition to the [common prerequisites](./get-started.md#prerequisites):

- Ability to create resources in AWS
- A PostgreSQL database server with bidirectional connectivity to both the Kubernetes cluster and
  the underlying compute nodes for the cluster

## Requirements

### Hardware Requirements

Cluster sizing is platform-independent. Choose a tier and read the resource requirements in
[Cluster sizing](./sizing.md), then use an AWS instance type that meets them.

Example EKS node group sizes:

| Node Size           | Minimum Nodes | Maximum Nodes | Deployment Size |
|---------------------|---------------|---------------|-----------------|
| **r6in.2xlarge**    | 1             | 3             | Small           |
| **r6in.2xlarge**    | 2             | 6             | Medium          |
| **r6in.4xlarge**    | 2             | 8             | Large           |

> **Note:** These `r6in` examples are memory-optimized and meet the **recommended** memory
> requirement, which suits embedding and vectorization workloads. See
> [Example instance types](./sizing.md#step-3-example-instance-types).

#### PostgreSQL Database Sizing

[Follow the PostgreSQL sizing recommendations here.](./database.md#sizing)

### Infrastructure Requirements

- EKS version: 1.35+

## Getting Started

### Clone the Viya IAC Project

```bash
# Clone the Viya IAC repository
git clone https://github.com/sassoftware/viya4-iac-aws

# Navigate to project directory
cd viya4-iac-aws
```

> **Note:** While we use the viya-iac repository, a viya license or deployment is not required to use SAS Retrieval Agent Manager. This is a standalone application that can be deployed independently of a Viya environment.

## Configuration Setup

Before deploying, you'll need to create and edit two configuration files with your custom values:

| File         | Purpose                                        |                                       |
|--------------|------------------------------------------------|---------------------------------------|
| `terraform.tfvars` | PostgreSQL name, prefix, and location settings | [Example](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/aws/terraform.tfvars) |
| `aws.env`    | AWS credentials and environment variables      | [Example](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/aws/aws.env)    |

> **Tip:** If you need help obtaining AWS environemnt variables, contact your AWS Cloud Administrator or refer to our [AWS Help Guide](./user/AWSHelp.md)

## AWS authentication

Before deploying resources, you need to authenticate with AWS. There are two options for this:

- SSO configuration for bare-metal terraform approach
- ENV credential file setup for docker approach  

The single sign-on (SSO) process establishes secure access to your AWS environment. It can be initialized by the following command:

```bash
# Begin Configuration AWS SSO Profile
aws configure sso
```

1. Provide Initial Information:

   - Session name: Choose a descriptive name (e.g., my-company-sso)
   - Start URL: Your organization's AWS SSO portal URL (e.g., <https://my-company.awsapps.com/start>)
   - Region: The AWS region where your SSO is configured (e.g., us-east-1)
   - Registration scopes: Leave as default (sso:account:access)

2. Select Account and Role:

   - Available AWS accounts you have access to
   - Available roles within the selected account

3. Choose the appropriate account and role for your deployment:

   - Default client region: Choose your preferred AWS region for resources
   - Default output format: Recommended to use json
   - Profile name: Enter a name for this profile (e.g., sso-deployment)

After successfully configurating the AWS SSO, you should be able to start deploying resources necsesary for SAS Retrieval Agent Manager.

An alternative to configuring the SSO would be to have a credentials file in a similar format as the `aws.env` file. This would only be used in the docker deployment of SAS Retrieval Agent Manager. [An example of an aws credentials file can be found here](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/aws/aws.env).

## Infrastructure Deployment

### Docker (Recommended)

Use the provided Docker image to deploy the EKS cluster and PostgreSQL database with the [Example Terraform Values File](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/aws/terraform.tfvars). This method ensures a consistent environment and simplifies dependency management.

```bash
# Build the Docker image
docker build -t viya4-iac-aws .

# Deploy the cluster
sudo docker run --rm \
    --env-file=aws.env \
    --volume=$HOME/.ssh:/.ssh \
    --volume=$(pwd):/workspace \
    viya4-iac-aws \
    apply -auto-approve \
    -var-file=/workspace/terraform.tfvars
```

## AWS Resource Setup

### Deploy EFS and Dedicated Role

The AWS deployment of SAS Retrieval Agent Manager requires an AWS EFS with a corresponding role that has access to it via the correct policy.

The role that needs to be created should have the `AmazonEFSCSIDriverPolicy` Policy.

[You can do this via the AWS UI or by following the CLI steps here](./user/AWSStorageHelp.md).

### Deploy EBS (Optional)

The Weaviate deployment on AWS requires a corresponding role that has access to it via the correct policy.

The role that needs to be created should have the `AmazonEBSCSIDriverPolicy` Policy.

[You can do this via the AWS UI or by following the CLI steps here](./user/AWSStorageHelp.md).

### Deploy RDS SSL Certificate

The AWS deployment of SAS Retrieval Agent Manager requires you to pass the appropriate SSL certificate for your RDS region into the values file. You can find which region SSL certificate you need by running the following command:

```bash
# Find the region you need the RDS SSL Bundle for
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,AvailabilityZone]' --output table
```

> **Note:** Using this table, find the RDS instance that you want to connect SAS Retrieval Agent Manager to

[After finding the correct region, download the correct bundle here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html).

Then follow [Secure the database connection](./database.md#secure-the-database-connection) to build
the `cert.pem` bundle and create the Kubernetes secret.

## Next steps

1. [Configure the database](./database.md) — enable the `pgcrypto` and `vector` extensions on your
   RDS instance.
2. [Install dependencies](./user/DependencyInstall.md).
3. [Install and upgrade](./install.md) — deploy the application.
