# sas-retrieval-agent-manager-db-init

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for SAS Retrieval Agent Manager Database Initialization - PostgreSQL database setup and schema creation for AI/ML workloads

**Homepage:** <https://www.sas.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| SAS IoT Team | <iot-support@sas.com> | <https://www.sas.com/en_us/software/iot.html> |

## Source Code

* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://www.postgresql.org/>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| fullnameOverride | string | `"sas-retrieval-agent-manager-db-init"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"database":{"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"},"keycloak":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","password":"","schema":"keycloak","user":"sas_keycloak_user"},"migration":{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"},"vectorizationJob":{"password":"","user":"sas_ram_vectorization_user"},"weaviate":{"enabled":true}}}` | Global configuration for database initialization and setup |
| global.configuration | object | `{"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"database":{"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"},"keycloak":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","password":"","schema":"keycloak","user":"sas_keycloak_user"},"migration":{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"},"vectorizationJob":{"password":"","user":"sas_ram_vectorization_user"},"weaviate":{"enabled":true}}` | Configuration settings |
| global.configuration.application | object | `{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"}` | Application database configuration |
| global.configuration.application.adminRole | string | `"sas_ram_admin_role"` | Admin role name for application |
| global.configuration.application.createDB | bool | `true` | Whether to create application database |
| global.configuration.application.createSchema | bool | `true` | Whether to create application schema |
| global.configuration.application.createUser | bool | `true` | Whether to create application user |
| global.configuration.application.db | string | `"SASRetrievalAgentManager"` | Application database name |
| global.configuration.application.password | string | `""` | Application database user password |
| global.configuration.application.schema | string | `"retagentmgr"` | Application schema name |
| global.configuration.application.user | string | `"sas_ram_pgrest_user"` | Application database user name |
| global.configuration.application.userRole | string | `"sas_ram_user_role"` | User role name for application |
| global.configuration.database | object | `{"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"}` | Database connection and initialization configuration |
| global.configuration.database.host | string | `""` | Database host |
| global.configuration.database.initAdminPassword | string | `""` | Initial admin password (should be provided via secret) |
| global.configuration.database.initAdminRole | string | `"azure_pg_admin"` | Initial admin role for database management |
| global.configuration.database.initializeDb | string | `"true"` | Whether to initialize the database |
| global.configuration.database.port | string | `"5432"` | Database port |
| global.configuration.database.sslmode | string | `"require"` | SSL mode for database connection |
| global.configuration.keycloak | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","password":"","schema":"keycloak","user":"sas_keycloak_user"}` | Keycloak database configuration |
| global.configuration.keycloak.createDB | bool | `true` | Whether to create Keycloak database |
| global.configuration.keycloak.createSchema | bool | `true` | Whether to create Keycloak schema |
| global.configuration.keycloak.createUser | bool | `true` | Whether to create Keycloak user |
| global.configuration.keycloak.db | string | `"SASRetrievalAgentManagerIAM"` | Keycloak database name |
| global.configuration.keycloak.password | string | `""` | Keycloak database user password |
| global.configuration.keycloak.schema | string | `"keycloak"` | Keycloak schema name |
| global.configuration.keycloak.user | string | `"sas_keycloak_user"` | Keycloak database user name |
| global.configuration.migration | object | `{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"}` | Database migration configuration |
| global.configuration.migration.createUser | bool | `true` | Whether to create migration user |
| global.configuration.migration.dbMigrationPassword | string | `""` | Database migration user password (should be provided via secret) |
| global.configuration.migration.dbMigrationUser | string | `"sas_iot_migration"` | Database migration user name |
| global.configuration.vectorStore | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"}` | Vector store database configuration |
| global.configuration.vectorStore.createDB | bool | `true` | Whether to create vector store database |
| global.configuration.vectorStore.createSchema | bool | `true` | Whether to create vector store schema |
| global.configuration.vectorStore.createUser | bool | `true` | Whether to create vector store user |
| global.configuration.vectorStore.db | string | `"SASRetrievalAgentManagerVector"` | Vector store database name |
| global.configuration.vectorStore.enabled | bool | `true` | Whether vector store is enabled |
| global.configuration.vectorStore.password | string | `""` | Vector store database user password |
| global.configuration.vectorStore.schema | string | `"vectorstore"` | Vector store schema name |
| global.configuration.vectorStore.user | string | `"vector_store_user"` | Vector store database user name |
| global.configuration.vectorizationJob | object | `{"password":"","user":"sas_ram_vectorization_user"}` | Vectorization job user configuration |
| global.configuration.vectorizationJob.password | string | `""` | Vectorization job user password |
| global.configuration.vectorizationJob.user | string | `"sas_ram_vectorization_user"` | Vectorization job user name |
| global.configuration.weaviate | object | `{"enabled":true}` | Weaviate vector database configuration |
| global.configuration.weaviate.enabled | bool | `true` | Whether Weaviate integration is enabled |
| image | object | `{"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s","useGlobal":false},"tag":"1.31.12"},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres","useGlobal":false},"tag":"15-alpine"}}` | Container image configuration for database initialization |
| image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s","useGlobal":false},"tag":"1.31.12"}` | kubectl container image configuration (used for Kubernetes operations) |
| image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s","useGlobal":false}` | Container image configuration for kubectl |
| image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl |
| image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| image.kubectl.repo.useGlobal | bool | `false` | Use global registry configuration instead of local |
| image.kubectl.tag | string | `"1.31.12"` | kubectl container image tag |
| image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres","useGlobal":false},"tag":"15-alpine"}` | PostgreSQL container image configuration |
| image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| image.postgres.repo | object | `{"base":"docker.io","path":"postgres","useGlobal":false}` | Container image configuration for postgres |
| image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| image.postgres.repo.useGlobal | bool | `false` | Use global registry configuration instead of local |
| image.postgres.tag | string | `"15-alpine"` | PostgreSQL container image tag |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| nameOverride | string | `"initialization"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the database initialization container |
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
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for database initialization |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
