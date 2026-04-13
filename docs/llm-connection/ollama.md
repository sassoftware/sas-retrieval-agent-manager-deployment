# Ollama Connection to RAM

## Introduction

Ollama is the only LLM provider that you will need to install onto the cluster. This can be done using the [example values file provided](../../examples/dependencies/optional/ollama.yaml) or referring to the [official documentation](https://github.com/ollama/ollama).

> **Note:** While we support the integration of Ollama as an LLM provider, we do not assist in the deployment.

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
