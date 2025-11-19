# JSON Schema Definitions

This branch contains reusable JSON schema definitions for Helm chart `values.yaml` files.

## Purpose

These schemas are externalized to be referenced by multiple Helm charts within the SAS Retrieval Agent Manager deployment. They provide consistent validation and documentation for common Kubernetes resource configurations.

## Available Schemas

- **affinity-schema.json** - Pod affinity and anti-affinity rules
- **autoscaling-schema.json** - Horizontal Pod Autoscaler configuration
- **image-schema.json** - Container image configuration (repository, tag, pull policy)
- **ingress-schema.json** - Ingress resource configuration
- **nodeselector-schema.json** - Node selector specifications
- **podsecuritycontext-schema.json** - Pod-level security context settings
- **probe-schema.json** - Liveness, readiness, and startup probe definitions
- **resources-schema.json** - CPU and memory resource requests/limits
- **securitycontext-schema.json** - Container-level security context settings
- **service-schema.json** - Kubernetes Service configuration
- **serviceaccount-schema.json** - Service account configuration
- **strategy-schema.json** - Deployment strategy (RollingUpdate, Recreate)
- **tolerations-schema.json** - Pod toleration specifications

## Usage

Reference these schemas in your Helm chart's `values.schema.json` using the `$ref` keyword with the raw GitHub URL pointing to this branch:

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "properties": {
    "image": {
      "$ref": "https://raw.githubusercontent.com/sassoftware/sas-retrieval-agent-manager-deployment/schemas/affinity-schema.json"
    }
  }
}
```
