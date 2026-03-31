# Deployment Assets

## Supported Platforms

### Azure

| File Type | Link | Description                                                                                                        |
|-----------|------|--------------------------------------------------------------------------------------------------------------------|
| **Environment**         | [azure.env](./azure/azure.env) | Environment variables needed for Azure deployment                          |
| **Terraform Variables** | [azure.tfvars](./azure/azure.tfvars) | Terraform variable definitions for Azure infrastructure              |

### AWS

| File Type | Link | Description                                                                                                     |
|-----------|------|-----------------------------------------------------------------------------------------------------------------|
| **Environment**         | [aws.env](./aws/aws.env)                         | Environment variables for AWS deployment              |
| **Terraform Variables** | [aws.tfvars](./aws/aws.tfvars)                   | Terraform variable definitions for AWS infrastructure |
| **EFS Configuration**   | [efs.yaml](./aws/efs.yaml)                       | Amazon Elastic File System configuration              |
| **Trust Policy**        | [trust-policy.json](./aws/trust-policy.json)     | IAM trust policy for service roles                    |

### Open Source Kubernetes

| File Type | Link | Description                                                                                               |
|-----------|------|-----------------------------------------------------------------------------------------------------------|
| **Environment**       | [ansible-creds.env](./k8s/ansible-creds.env)         | Ansible credentials and environment variables |
| **Ansible Variables** | [ansible-vars.yaml](./k8s/ansible-vars.yaml)         | Ansible playbook variables                    |
| **Inventory**         | [ansible-inventory.ini](./k8s/ansible-inventory.ini) | Ansible inventory file defining target hosts  |

### OpenShift

| File Type | Link | Description                                                                                               |
|-----------|------|-----------------------------------------------------------------------------------------------------------|
| **Environment**       | [ansible-creds.env](./k8s/ansible-creds.env)         | Ansible credentials and environment variables |
| **Ansible Variables** | [ansible-vars.yaml](./k8s/ansible-vars.yaml)         | Ansible playbook variables                    |
| **Inventory**         | [ansible-inventory.ini](./k8s/ansible-inventory.ini) | Ansible inventory file defining target hosts  |

## Getting Started

1. **Choose your platform** - Navigate to the appropriate directory (azure, aws, or k8s)
2. **Copy templates** - Copy the example files into a local directory
3. **Customize infrastructure templates** - Edit the infrastructure files with your environment-specific values
4. **Configure Values File** - Edit the example SAS Retrieval Agent Manager Values file to your needs
5. **Deploy** - Use the appropriate deployment tools (Terraform, Helm, Ansible) for your chosen platform
