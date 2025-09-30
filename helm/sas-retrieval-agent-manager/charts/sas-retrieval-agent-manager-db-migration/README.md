# sas-retrieval-agent-manager-db-migration

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for SAS Retrieval Agent Manager Database Migration - Schema migration with Goose for AI/ML database evolution

**Homepage:** <https://www.sas.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| SAS IoT Team | <iot-support@sas.com> | <https://www.sas.com/en_us/software/iot.html> |
| Goose Project | <support@pressly.com> | <https://github.com/pressly/goose> |

## Source Code

* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://github.com/pressly/goose>
* <https://www.postgresql.org/>
* <https://cr.sas.com/viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| fullnameOverride | string | `"sas-retrieval-agent-manager-db-migration"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"vectorStore":{"enabled":true},"weaviate":{"enabled":true}},"imagePullSecrets":[]}` | Global configuration for database migration |
| global.configuration | object | `{"vectorStore":{"enabled":true},"weaviate":{"enabled":true}}` | Configuration settings |
| global.configuration.vectorStore | object | `{"enabled":true}` | Vector store configuration |
| global.configuration.vectorStore.enabled | bool | `true` | Whether vector store migrations are enabled |
| global.configuration.weaviate | object | `{"enabled":true}` | Weaviate vector database configuration |
| global.configuration.weaviate.enabled | bool | `true` | Whether Weaviate-related migrations are enabled |
| global.imagePullSecrets | list | `[]` | Array of imagePullSecrets for global use |
| image | object | `{"goose":{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"},"tag":"1.4.0-20250910.1757512678252"},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"}}` | Container image configuration for database migration |
| image.goose | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"},"tag":"1.4.0-20250910.1757512678252"}` | Goose database migration tool container image configuration |
| image.goose.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Goose migration container |
| image.goose.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"}` | Container image configuration for goose |
| image.goose.repo.base | string | `"cr.sas.com"` | Container registry base URL for Goose migration tool |
| image.goose.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"` | Container image path/name for Goose migration tool |
| image.goose.tag | string | `"1.4.0-20250910.1757512678252"` | Goose migration container image tag |
| image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"}` | PostgreSQL container image configuration |
| image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| image.postgres.repo | object | `{"base":"docker.io","path":"postgres"}` | Container image configuration for postgres |
| image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| image.postgres.tag | string | `"15-alpine"` | PostgreSQL container image tag |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| nameOverride | string | `"db-migration"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the database migration container |
| resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| resources.limits.cpu | string | `"200m"` | CPU limit |
| resources.limits.memory | string | `"256Mi"` | Memory limit |
| resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"100m"` | CPU request |
| resources.requests.memory | string | `"128Mi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for database migration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
