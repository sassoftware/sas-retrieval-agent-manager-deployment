# AWS Deployment Guide

## Table of Contents

- [AWS Deployment Guide](#aws-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Infrastructure Prerequisites](#infrastructure-prerequisites)
    - [Technical Prerequisites](#technical-prerequisites)
  - [Requirements](#requirements)
    - [Hardware Requirements](#hardware-requirements)
    - [Infrastructure Requirements](#infrastructure-requirements)
  - [Getting Started](#getting-started)
    - [Clone the Project](#clone-the-project)
  - [Configuration Setup](#configuration-setup)
  - [Authentication Setup](#aws-authentication)
  - [Deploy the Kubernetes Cluster and PostgreSQL Database](#deploy-the-kubernetes-cluster-and-postgresql-database)
  - [EFS Setup](#deploy-efs-and-dedicated-role)
  - [RDS SSL Cert Setup](#deploy-rds-ssl-certificate)
  - [Application Deployment](#application-deployment)

---

## Overview

This guide describes deploying an AWS infrastructure on which to deploy SAS Retrieval Agent Manager.

## Prerequisites

### Infrastructure Prerequisites

- **External Database:**
  - PostgreSQL database server with bidirectional connectivity to both the Kubernetes cluster and underlying compute nodes for the cluster

### Technical Prerequisites

**Required Access and Tools:**

- Ability to create resources in AWS

## Requirements

### Hardware Requirements

| Node Size        | Status      |
|------------------|-------------|
| **r6in.2xlarge** | Recommended |

### Infrastructure Requirements

- AWS version: 1.32

## Getting Started

### Clone the Project

```bash
# Clone the repository
git clone https://github.com/sassoftware/viya4-iac-aws

# Navigate to project directory
cd viya4-iac-aws
```

## Configuration Setup

Before deploying, you'll need to create and edit two configuration files with your custom values:

| File         | Purpose                                        |                                       |
|--------------|------------------------------------------------|---------------------------------------|
| `terraform.tfvars` | PostgreSQL name, prefix, and location settings | [Example](../examples/aws/terraform.tfvars) |
| `aws.env`    | AWS credentials and environment variables      | [Example](../examples/aws/aws.env)    |

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

After successfully configurating the AWS SSO, you should be able to start deploying resources necsesary for RAM.

An alternative to configuring the SSO would be to have a credentials file in a similar format as the `aws.env` file. This would only be used in the docker deployment of RAM. [An example of an aws credentials file can be found here](../examples/aws/aws.env).

## Deploy the Kubernetes Cluster and PostgreSQL Database

### Bare-Metal Terraform (Recommended)

```bash
# Install terraform
sudo apt install terraform

# Deploy all terraform resources in terraform.tfvars
terraform apply
```

> Note: A direct terraform approach is recommended only for AWS as opposed to the docker recommendation for Bare-metal and Azure

### Docker

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

> [Example Terraform Values File](../examples/aws/terraform.tfvars)

## Deploy EFS and Dedicated Role

The AWS deployment of RAM requires an AWS EFS with a corresponding role that has access to it via the correct policy.

The role that needs to be created should have the `AmazonEFSCSIDriverPolicy` Policy.

[You can do this via the AWS UI or by following the CLI steps here](./user/EFSHelp.md).

## Deploy RDS SSL Certificate

The AWS deployment of RAM requires you to pass the appropriate SSL certificate for your RDS region into the values file. You can find which region SSL certificate you need by running the following command:

```bash
# Find the region you need the RDS SSL Bundle for
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,AvailabilityZone]' --output table
```

> Note: Using this table, find the RDS instance that you want to connect RAM to

[After finding the correct region, download the correct bundle here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html).

After downloading the SSL bundle, upload it as a secret with the key of `cert.pem`. This can be done with the following command:

```bash
# Create a secret with the RDS SSL Bundle you downloaded
kubectl create secret generic rds-ssl-cert --from-file=cert.pem=<your-ssl-bundle>.pem -n retagentmgr
```

> Note: It is critical the enter the name of the secret in the `postgreSQLCertSecret` key in the ram-values under global.configuration.vhub. For example, with this secret name, it would be: `postgreSQLCertSecret: 'rds-ssl-cert'`

## Application Deployment

Return to the [Application Deployment Guide](../README.md#application-deployment-guide) section of the documentation to continue the deployment.
