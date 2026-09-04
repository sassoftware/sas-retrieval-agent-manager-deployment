---
layout: home
title: Overview
nav_order: 1
permalink: /
---

# SAS Retrieval Agent Manager

SAS Retrieval Agent Manager is a comprehensive solution for managing agents or interacting directly
with LLMs in a RAG or non-RAG context. This documentation covers deployment and operation on
open-source Kubernetes, Azure Kubernetes Service (AKS), Amazon Elastic Kubernetes Service (EKS), and
OpenShift Container Platform (OCP).

> [!CAUTION]
> GPG Key Warning - Read Before Doing Anything
>
> GPG keys are the encryption foundation for all sensitive data in SAS Retrieval Agent Manager.
> Deleting or regenerating existing GPG keys post-deployment will result in permanent, unrecoverable
> data loss. See [GPG keys](./docs/gpg-keys.md).

## Start here

1. **[Get started](./docs/get-started.md)** — prerequisites, tools, license retrieval, and image
   pull secret.
2. **[Deployment](./docs/deployment.md)** — provision infrastructure and install the application.
3. **[Values file generator](./docs/configure-values.md)** — build your `ram-values.yaml`.

## Supported deployment platforms

| Platform       | Description                                        | Kubernetes version | Guide |
|----------------|----------------------------------------------------|--------------------|-------|
| **Kubernetes** | Open-source Kubernetes deployment                  | 1.35+              | [Guide](./docs/k8s-deployment.md)   |
| **Azure**      | Azure Kubernetes Service (AKS) deployment          | 1.35+              | [Guide](./docs/azure-deployment.md) |
| **AWS**        | Amazon Elastic Kubernetes Service (EKS) deployment | 1.35+              | [Guide](./docs/aws-deployment.md)   |
| **OpenShift**  | OpenShift Container Platform (OCP)                 | 1.32 (OCP v4.19.1) | [Guide](./docs/ocp-deployment.md)   |

## Documentation

| Topic | Description |
|-------|-------------|
| [Get started](./docs/get-started.md) | Prerequisites, platform selection, license, and pull secret |
| [Deployment](./docs/deployment.md) | Infrastructure, database, dependencies, GPG keys, install and upgrade |
| [Identity and access](./docs/identity-and-access.md) | Keycloak, LDAP, OpenID Connect, and SAML |
| [LLM connections](./docs/llm-connection/README.md) | Connect Azure OpenAI, Amazon Bedrock, OpenAI, or Ollama |
| [Monitoring](./docs/monitoring/README.md) | Logs, metrics, and traces |
| [Backup and restore](./docs/backup-restore/README.md) | Protect and recover your data |
| [Troubleshooting](./docs/troubleshoot.md) | Common issues and resolutions |
| [Values file generator](./docs/configure-values.md) | Interactive `ram-values.yaml` builder |

## Conversational Deployment

You can use a coding assistant to guide an Azure and Azure Kubernetes Service (AKS) deployment. Use a coding assistant that supports repository instructions in an `AGENTS.md` file.

1. Clone this repository.
2. Open the repository root in your coding assistant.
3. Confirm that the assistant can read [AGENTS.md](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/AGENTS.md).
4. Ask the assistant: `Help me deploy SAS Retrieval Agent Manager by following AGENTS.md.`
5. Answer one question at a time.
6. Review each proposed command or file change.
7. Approve each change only after you confirm its target and effect.
8. Enter all secrets directly in your local terminal. Do not enter secrets in the assistant chat.

The `AGENTS.md` file gives the assistant the deployment sequence and safety rules. The assistant checks the Azure subscription, infrastructure path, AKS context, namespace, dependencies, values file, GPG keys, installation, and deployment status. The assistant must stop when a check fails or a target is not clear.

This conversational workflow supports Azure and AKS only. Use the platform guides above for other deployment platforms.

## Contributing

We welcome your contributions!
Please read [CONTRIBUTING.md](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/CONTRIBUTING.md) for details on how to submit contributions to this project.

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

As with any container image, direct and indirect dependencies are governed by their own licenses.
Users of the published container image are responsible for ensuring that their use complies with all applicable licenses.

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
