# Ollama Connection to RAM

## Introduction

Ollama is the only LLM provider that you will need to install onto the cluster. This can be done using the [example values file provided](../../examples/ollama.yaml) or referring to the [official documentation](https://github.com/ollama/ollama).

> Note: We do *allow* Ollama deployments to interact with RAM, *we do not support it*.

## Installation

Here is an [Example Ollama Values File](../../examples/ollama.yaml). You can edit it as you'd like to fit your deployment.

Ollama can be installed onto your cluster with the following commands:

```sh

helm repo add otwld https://helm.otwld.com/ 
helm repo update
helm install ollama otwld/ollama -f <your_ollama_values> --version 1.12.0 --namespace ollama --create-namespace

```

## Connection

After you have installed Ollama using the commands above, you can add it to the RAM cluster by following these steps:

- Open the Settings panel in the top right of the UI
- Select the ollama model type
- Insert the desired name and model that Ollama supports
- Insert the `http://<ollama_namespace>.<ollama_service_name>:<ollama_port_number>` into the URI field

    > Example: `http://ollama.ollama:11434`

- Select which groups will have access to this LLM
- Wait for the model to be loaded in by Ollama

At this point it should be ready to be queried by the user via agents or chat.
