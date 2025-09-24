# Deployment Assets

## Supported Platforms

## Deployment Configuration Files

### Azure

| File Type | Link | Description                                                                                                        |
|-----------|------|--------------------------------------------------------------------------------------------------------------------|
| **Helm Values**         | [azure-ram-values.yaml](./azure/azure-ram-values.yaml) | Helm chart values for Azure-specific configuration |
| **Environment**         | [azure.env](./azure/azure.env) | Environment variables needed for Azure deployment                          |
| **Terraform Variables** | [azure.tfvars](./azure/azure.tfvars) | Terraform variable definitions for Azure infrastructure              |

### AWS

| File Type | Link | Description                                                                                                     |
|-----------|------|-----------------------------------------------------------------------------------------------------------------|
| **Helm Values**         | [aws-ram-values.yaml](./aws/aws-ram-values.yaml) | Helm chart values for AWS-specific configuration      |
| **Environment**         | [aws.env](./aws/aws.env)                         | Environment variables for AWS deployment              |
| **Terraform Variables** | [aws.tfvars](./aws/aws.tfvars)                   | Terraform variable definitions for AWS infrastructure |
| **EFS Configuration**   | [efs.yaml](./aws/efs.yaml)                       | Amazon Elastic File System configuration              |
| **Trust Policy**        | [trust-policy.json](./aws/trust-policy.json)     | IAM trust policy for service roles                    |

### Bare Metal

| File Type | Link | Description                                                                                               |
|-----------|------|-----------------------------------------------------------------------------------------------------------|
| **Helm Values**       | [k8s-ram-values.yaml](./k8s/k8s-ram-values.yaml)     | Helm chart values for Kubernetes deployment   |
| **Environment**       | [ansible-creds.env](./k8s/ansible-creds.env)         | Ansible credentials and environment variables |
| **Ansible Variables** | [ansible-vars.yaml](./k8s/ansible-vars.yaml)         | Ansible playbook variables                    |
| **Inventory**         | [ansible-inventory.ini](./k8s/ansible-inventory.ini) | Ansible inventory file defining target hosts  |

## Getting Started

1. **Choose your platform** - Navigate to the appropriate directory (azure, aws, or k8s)
2. **Copy templates** - Copy the example files into a local directory
3. **Customize configuration** - Edit the files with your environment-specific values
4. **Deploy** - Use the appropriate deployment tools (Terraform, Helm, Ansible) for your chosen platform
