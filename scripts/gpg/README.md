# GPG Key Generation

This document provides instructions for generating GPG keys for use with SAS Retrieval Agent Manager. GPG keys are used for encrypting and decrypting sensitive data in SAS Retrieval Agent Manager. Follow the instructions below to generate GPG keys and deploy them as Kubernetes secrets and configmaps.

## Requirements

- Docker
- Existing access to Kubernetes cluster
- Windows, WSL, or Linux OS

## Generate GPG Keys

Run the appropriate script for your platform to generate GPG keys. This will create and run the docker container that installs the necessary tools and generates the keys. The generated keys will be automatically applied to your Kubernetes cluster and saved to a folder named `output` in the directory that the script is located in.

### Windows Example

```sh

.\run-bootstrap-gpg.ps1

```

### Linux/Mac Example

```sh

./run-bootstrap-gpg.sh

```

### Options

You have the option of changing the prefix to the gpg keys that are saved by adding the `--release <my-custom-prefix>` flag to the end of the command. By default, the prefix is `retrieval-agent-manager`. If you change the prefix, make sure to update the `security.gpg.nameOverride` value in your `values.yaml` file to match the new prefix.

Example with custom prefix:

```yaml

security:
  gpg:
    nameOverride: my-custom-prefix

```
