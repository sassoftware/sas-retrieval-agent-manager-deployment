# sas-retrieval-agent-manager

![Version: 1.2.3-dev.20241225](https://img.shields.io/badge/Version-1.2.3--dev.20241225-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.2.0](https://img.shields.io/badge/AppVersion-1.2.0-informational?style=flat-square)

A comprehensive Helm chart for deploying SAS Retrieval Agent Manager (RAM) platform. Provides AI-powered document retrieval, processing, and management capabilities with integrated authentication, file management, and vector search functionality.

**Homepage:** <https://www.sas.com/en_us/software/viya.html>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |

## Source Code

* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>

## Requirements

Kubernetes: `>=1.24.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80},"childScheduling":{"agentDevServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"agentProdServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"automation":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"embeddingModel":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"eval":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"mcpToolServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"source":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"vectorizationHub":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}},"config":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_genai_traces":"False","hide_destination_secrets":"False","hide_llm_secrets":"False","license":"","license_secret":null,"log_level":"INFO","num_workers":4,"sslVerify":"True"},"latest_version":"v1","livenessProbe":{"failureThreshold":15,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":5,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":2,"resources":{"limits":{"cpu":2,"memory":"5Gi"},"requests":{"cpu":"250m","memory":"2Gi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"internalPort":8765,"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"spawn":{"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""}},"tolerations":[],"volumeMounts":[],"volumes":[]}` | SAS Retrieval Agent Manager API: Main backend service |
| api.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| api.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| api.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| api.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| api.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| api.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| api.autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage for scaling (optional) |
| api.childScheduling | object | `{"agentDevServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"agentProdServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"automation":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"embeddingModel":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"eval":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"mcpToolServer":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"source":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]},"vectorizationHub":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}}` | Configuration for scheduling child entities spawned by the API. |
| api.childScheduling.agentDevServer | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the Agent Development Server |
| api.childScheduling.agentProdServer | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the Agent Production Server |
| api.childScheduling.automation | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the automation pods |
| api.childScheduling.embeddingModel | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the embedding model pods |
| api.childScheduling.eval | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the Evaluation pods |
| api.childScheduling.mcpToolServer | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the MCP Tool Server pods |
| api.childScheduling.source | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the Custom and Git source pods |
| api.childScheduling.vectorizationHub | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"nodeSelector":{},"tolerations":[]}` | Scheduling configuration for the Vectorization Hub pods |
| api.config.azure_settings | object | `{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}}` | Azure integration settings for API and identity management |
| api.config.azure_settings.azure_identity | object | `{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"}` | Azure integration settings for identity management |
| api.config.azure_settings.azure_identity.client_id | string | `""` | Azure AD client ID for authentication (leave blank to disable) |
| api.config.azure_settings.azure_identity.enabled | bool | `false` | Enable Azure AD identity integration (true/false) |
| api.config.azure_settings.azure_identity.scope | string | `"https://cognitiveservices.azure.com/.default"` | OAuth2 scope for Azure Cognitive Services authentication |
| api.config.azure_settings.azure_identity.token_keyword | string | `"AZURE_IDENTITY"` | Keyword used to identify Azure identity tokens in requests |
| api.config.azure_settings.openAI.default_api_version | string | `"2024-10-21"` | Default API version for Azure OpenAI service (format: YYYY-MM-DD) |
| api.config.base_path | string | `"/SASRetrievalAgentManager/api"` | Base path for API endpoints |
| api.config.enable_dev_mode | string | `"False"` | Enable development mode features |
| api.config.enable_genai_traces | string | `"False"` | Whether to send traces to the observability platform via vector |
| api.config.hide_destination_secrets | string | `"False"` | Whether to hide the destination secrets in the UI |
| api.config.hide_llm_secrets | string | `"False"` | Whether to hide the LLM api key in the UI |
| api.config.license | string | `""` | License content (if not using secret) |
| api.config.license_secret | string | `nil` | Name of the license secret |
| api.config.log_level | string | `"INFO"` | Log level for the API |
| api.config.num_workers | int | `4` | Number of worker processes |
| api.config.sslVerify | string | `"True"` | SSL verification setting |
| api.latest_version | string | `"v1"` | Latest API version |
| api.livenessProbe | object | `{"failureThreshold":15,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for API |
| api.livenessProbe.failureThreshold | int | `15` | Number of consecutive failures required to mark container as not ready |
| api.livenessProbe.initialDelaySeconds | int | `30` | Initial delay before starting probes |
| api.livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| api.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| api.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| api.nodeSelector | object | `{}` | Node labels for pod assignment |
| api.podAnnotations | object | `{}` | Annotations to add to the pods |
| api.podLabels | object | `{}` | Labels to add to the pods |
| api.podSecurityContext | object | `{"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| api.podSecurityContext.fsGroup | int | `1001` | Group ID for file system ownership |
| api.podSecurityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| api.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| api.podSecurityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| api.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| api.readinessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for API |
| api.readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| api.readinessProbe.initialDelaySeconds | int | `30` | Initial delay before starting probes |
| api.readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| api.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| api.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| api.replicaCount | int | `2` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| api.resources | object | `{"limits":{"cpu":2,"memory":"5Gi"},"requests":{"cpu":"250m","memory":"2Gi"}}` | The resources to allocate for the API container |
| api.resources.limits | object | `{"cpu":2,"memory":"5Gi"}` | Resource limits for the container |
| api.resources.limits.cpu | int | `2` | CPU limit |
| api.resources.limits.memory | string | `"5Gi"` | Memory limit |
| api.resources.requests | object | `{"cpu":"250m","memory":"2Gi"}` | Resource requests for the container |
| api.resources.requests.cpu | string | `"250m"` | CPU request |
| api.resources.requests.memory | string | `"2Gi"` | Memory request |
| api.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| api.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| api.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| api.securityContext.privileged | bool | `false` | Run as non-privileged container |
| api.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| api.securityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| api.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| api.securityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| api.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| api.service | object | `{"internalPort":8765,"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| api.service.internalPort | int | `8765` | Internal service port (bypasses OAuth2 proxy for service-to-service calls) |
| api.service.port | int | `80` | Kubernetes Service port (routes through OAuth2 proxy for ingress/external traffic) |
| api.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| api.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for API |
| api.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| api.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| api.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| api.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| api.spawn | object | `{"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""}}` | Settings for the services being spawned by the API. These include the embedding model service and the vector store service. |
| api.spawn.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for API |
| api.spawn.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| api.spawn.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| api.spawn.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| api.spawn.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| api.tolerations | list | `[]` | Tolerations for pod assignment |
| api.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| api.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| db | object | `{"init":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"config":{"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","schema":"retagentmgr","userRole":"sas_ram_user_role"},"database":{"host":"","initializeDb":"true","port":"5432","sslmode":"require"},"keycloak":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","schema":"keycloak"},"migration":{"createUser":true},"monitoring":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerMonitoring","schema":"monitoring","userRole":"sas_ram_user_role"},"postgrest":{"db":"SASRetrievalAgentManagerMonitoring","schema":"monitoring"},"timescale":{"enabled":false},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"schema":"vectorstore"},"weaviate":{"enabled":false}},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[]},"migration":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"config":{"embModelHydration":{"enabled":false,"models":[]},"llmHydration":{"enabled":false,"endpoint":"","key":"","models":[]}},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[]},"rest":{"adminService":{"port":3001,"type":"ClusterIP"},"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"config":{"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true},"livenessProbe":{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"livenessProbeMonitoring":{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"monitoring":{"adminService":{"port":3003},"service":{"internalPort":3102,"port":3002}},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"readinessProbeMonitoring":{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":2,"resources":{"limits":{"cpu":1,"memory":"500Mi"},"requests":{"cpu":"50m","memory":"64Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"internalPort":3100,"port":3000,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}}` | SAS Retrieval Agent Manager DB: Database services |
| db.init.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| db.init.config.application | object | `{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","schema":"retagentmgr","userRole":"sas_ram_user_role"}` | Application database configuration |
| db.init.config.application.adminRole | string | `"sas_ram_admin_role"` | Admin role name for application |
| db.init.config.application.createDB | bool | `true` | Whether to create application database |
| db.init.config.application.createSchema | bool | `true` | Whether to create application schema |
| db.init.config.application.createUser | bool | `true` | Whether to create application user |
| db.init.config.application.db | string | `"SASRetrievalAgentManager"` | Application database name |
| db.init.config.application.schema | string | `"retagentmgr"` | Application schema name |
| db.init.config.application.userRole | string | `"sas_ram_user_role"` | User role name for application |
| db.init.config.database | object | `{"host":"","initializeDb":"true","port":"5432","sslmode":"require"}` | Database connection and initialization configuration |
| db.init.config.database.host | string | `""` | Database host |
| db.init.config.database.initializeDb | string | `"true"` | Whether to initialize the database |
| db.init.config.database.port | string | `"5432"` | Database port |
| db.init.config.database.sslmode | string | `"require"` | SSL mode for database connection |
| db.init.config.keycloak | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","schema":"keycloak"}` | keycloak database and user configuration I believe these keycloak values should be here in the values file as it centralizes user management and we can point to the db.init.config key with customers and let them have at it |
| db.init.config.keycloak.createDB | bool | `true` | Whether to create Keycloak database |
| db.init.config.keycloak.createSchema | bool | `true` | Whether to create Keycloak schema |
| db.init.config.keycloak.createUser | bool | `true` | Whether to create Keycloak user |
| db.init.config.keycloak.db | string | `"SASRetrievalAgentManagerIAM"` | Keycloak database name |
| db.init.config.keycloak.schema | string | `"keycloak"` | Keycloak schema name |
| db.init.config.migration | object | `{"createUser":true}` | Controls database schema migration operations using Goose migration tool |
| db.init.config.migration.createUser | bool | `true` | Whether to create migration user |
| db.init.config.monitoring | object | `{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerMonitoring","schema":"monitoring","userRole":"sas_ram_user_role"}` | Monitoring database configuration |
| db.init.config.monitoring.adminRole | string | `"sas_ram_admin_role"` | Admin role name for application |
| db.init.config.monitoring.createDB | bool | `true` | Whether to create application database |
| db.init.config.monitoring.createSchema | bool | `true` | Whether to create application schema |
| db.init.config.monitoring.createUser | bool | `true` | Whether to create application user |
| db.init.config.monitoring.userRole | string | `"sas_ram_user_role"` | User role name for application |
| db.init.config.postgrest | object | `{"db":"SASRetrievalAgentManagerMonitoring","schema":"monitoring"}` | Controls REST API generation from PostgreSQL database |
| db.init.config.postgrest.db | string | `"SASRetrievalAgentManagerMonitoring"` | the database for storing logs/metrics |
| db.init.config.postgrest.schema | string | `"monitoring"` | the schema for storing logs/metrics |
| db.init.config.timescale | object | `{"enabled":false}` | TimescaleDB configuration |
| db.init.config.timescale.enabled | bool | `false` | Whether timescale is enabled |
| db.init.config.vectorStore | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"schema":"vectorstore"}` | Controls vector database setup for AI/ML embeddings and similarity search |
| db.init.config.vectorStore.createDB | bool | `true` | Whether to create vector store database |
| db.init.config.vectorStore.createSchema | bool | `true` | Whether to create vector store schema |
| db.init.config.vectorStore.createUser | bool | `true` | Whether to create vector store user |
| db.init.config.vectorStore.db | string | `"SASRetrievalAgentManagerVector"` | Vector store database name |
| db.init.config.vectorStore.enabled | bool | `true` | Whether vector store is enabled |
| db.init.config.vectorStore.schema | string | `"vectorstore"` | Vector store schema name |
| db.init.config.weaviate | object | `{"enabled":false}` | weaviate settings |
| db.init.config.weaviate.enabled | bool | `false` | Enable hydration for local Weaviate installation |
| db.init.nodeSelector | object | `{}` | Node labels for pod assignment |
| db.init.podAnnotations | object | `{}` | Annotations to add to the pods |
| db.init.podLabels | object | `{}` | Labels to add to the pods |
| db.init.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| db.init.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| db.init.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| db.init.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| db.init.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.init.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| db.init.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the database initialization container |
| db.init.resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| db.init.resources.limits.cpu | string | `"200m"` | CPU limit |
| db.init.resources.limits.memory | string | `"256Mi"` | Memory limit |
| db.init.resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| db.init.resources.requests.cpu | string | `"100m"` | CPU request |
| db.init.resources.requests.memory | string | `"128Mi"` | Memory request |
| db.init.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| db.init.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| db.init.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| db.init.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| db.init.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| db.init.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.init.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| db.init.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for database initialization |
| db.init.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| db.init.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| db.init.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| db.init.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| db.init.tolerations | list | `[]` | Tolerations for pod assignment |
| db.migration.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| db.migration.config.embModelHydration | object | `{"enabled":false,"models":[]}` | Embedding model hydration configuration |
| db.migration.config.embModelHydration.enabled | bool | `false` | Whether to automatically hydrate embedding model data |
| db.migration.config.embModelHydration.models | list | `[]` | Examples:   - "ibm-granite/granite-embedding-30m-english"   - "prdev/mini-gte"   - "sentence-transformers/all-MiniLM-L6-v2"   - "nomic-ai/nomic-embed-text-v2-moe"   - "ibm-granite/granite-embedding-107m-multilingual"   - "sentence-transformers/distiluse-base-multilingual-cased-v2" |
| db.migration.config.llmHydration | object | `{"enabled":false,"endpoint":"","key":"","models":[]}` | LLM hydration configuration |
| db.migration.config.llmHydration.enabled | bool | `false` | Whether to automatically hydrate LLM data |
| db.migration.config.llmHydration.endpoint | string | `""` | Example: |
| db.migration.config.llmHydration.key | string | `""` | B64 Encoded API key for LLM provider |
| db.migration.config.llmHydration.models | list | `[]` | Examples:     - name: "gpt-4.1"       context_limit: 1047576     - name: "gpt-4.1-mini"       context_limit: 1047576     - name: "gpt-4.1-nano"       context_limit: 1047576 |
| db.migration.nodeSelector | object | `{}` | Node labels for pod assignment |
| db.migration.podAnnotations | object | `{}` | Annotations to add to the pods |
| db.migration.podLabels | object | `{}` | Labels to add to the pods |
| db.migration.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| db.migration.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| db.migration.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| db.migration.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| db.migration.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.migration.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| db.migration.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the database migration container |
| db.migration.resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| db.migration.resources.limits.cpu | string | `"200m"` | CPU limit |
| db.migration.resources.limits.memory | string | `"256Mi"` | Memory limit |
| db.migration.resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| db.migration.resources.requests.cpu | string | `"100m"` | CPU request |
| db.migration.resources.requests.memory | string | `"128Mi"` | Memory request |
| db.migration.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| db.migration.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| db.migration.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| db.migration.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| db.migration.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| db.migration.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.migration.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| db.migration.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for database migration |
| db.migration.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| db.migration.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| db.migration.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| db.migration.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| db.migration.tolerations | list | `[]` | Tolerations for pod assignment |
| db.rest.adminService | object | `{"port":3001,"type":"ClusterIP"}` | Admin service configuration for PostgREST management |
| db.rest.adminService.port | int | `3001` | Kubernetes Service port for PostgREST admin interface |
| db.rest.adminService.type | string | `"ClusterIP"` | Kubernetes Service type for PostgREST admin interface |
| db.rest.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| db.rest.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| db.rest.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| db.rest.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| db.rest.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| db.rest.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| db.rest.config.jwt-role-claim-key | string | `".resource_access.\"sas-ram-app\".roles[0]"` | JWT role claim key configuration (uses value from keycloak.clientId) |
| db.rest.config.log-level | string | `"info"` | Log level for PostgREST (info, warn, etc.) |
| db.rest.config.openapi-mode | string | `"follow-privileges"` | OpenAPI mode configuration |
| db.rest.config.openapi-security-active | bool | `true` | Whether OpenAPI security is active |
| db.rest.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for PostgREST |
| db.rest.livenessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| db.rest.livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| db.rest.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| db.rest.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| db.rest.livenessProbeMonitoring | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for PostgREST |
| db.rest.livenessProbeMonitoring.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| db.rest.livenessProbeMonitoring.periodSeconds | int | `10` | How often to perform the probe |
| db.rest.livenessProbeMonitoring.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| db.rest.livenessProbeMonitoring.timeoutSeconds | int | `1` | Timeout for the probe |
| db.rest.monitoring.adminService | object | `{"port":3003}` | Port for PostgREST monitoring admin server |
| db.rest.monitoring.adminService.port | int | `3003` | Kubernetes Service port for PostgREST admin interface on the monitoring db |
| db.rest.monitoring.service | object | `{"internalPort":3102,"port":3002}` | Port for PostgREST monitoring server |
| db.rest.monitoring.service.internalPort | int | `3102` | Internal monitoring service port (bypasses OAuth2 proxy for service-to-service calls) |
| db.rest.monitoring.service.port | int | `3002` | Kubernetes Service port for PostgREST interface on the monitoring db (routes through OAuth2 proxy) |
| db.rest.nodeSelector | object | `{}` | Node labels for pod assignment |
| db.rest.podAnnotations | object | `{}` | Annotations to add to the pods |
| db.rest.podLabels | object | `{}` | Labels to add to the pods |
| db.rest.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| db.rest.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| db.rest.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| db.rest.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| db.rest.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.rest.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| db.rest.readinessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for PostgREST |
| db.rest.readinessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| db.rest.readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| db.rest.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| db.rest.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| db.rest.readinessProbeMonitoring | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for PostgREST |
| db.rest.readinessProbeMonitoring.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| db.rest.readinessProbeMonitoring.periodSeconds | int | `10` | How often to perform the probe |
| db.rest.readinessProbeMonitoring.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| db.rest.readinessProbeMonitoring.timeoutSeconds | int | `1` | Timeout for the probe |
| db.rest.replicaCount | int | `2` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| db.rest.resources | object | `{"limits":{"cpu":1,"memory":"500Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | The resources to allocate for the PostgREST container |
| db.rest.resources.limits | object | `{"cpu":1,"memory":"500Mi"}` | Resource limits for the container |
| db.rest.resources.limits.cpu | int | `1` | CPU limit |
| db.rest.resources.limits.memory | string | `"500Mi"` | Memory limit |
| db.rest.resources.requests | object | `{"cpu":"50m","memory":"64Mi"}` | Resource requests for the container |
| db.rest.resources.requests.cpu | string | `"50m"` | CPU request |
| db.rest.resources.requests.memory | string | `"64Mi"` | Memory request |
| db.rest.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| db.rest.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| db.rest.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| db.rest.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| db.rest.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| db.rest.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| db.rest.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| db.rest.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| db.rest.service | object | `{"internalPort":3100,"port":3000,"type":"ClusterIP"}` | Kubernetes Service configuration |
| db.rest.service.internalPort | int | `3100` | Internal service port (bypasses OAuth2 proxy for service-to-service calls) |
| db.rest.service.port | int | `3000` | Kubernetes Service port (routes through OAuth2 proxy for ingress/external traffic) |
| db.rest.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| db.rest.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| db.rest.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| db.rest.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| db.rest.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| db.rest.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| db.rest.tolerations | list | `[]` | Tolerations for pod assignment |
| db.rest.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| db.rest.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| extraObjects | list | `[]` | Allows deployment of additional secrets, configmaps, or custom resources |
| iam | object | `{"keycloak":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"config":{"adminRole":"sas-iot-admin","clientId":"sas-ram-app","clientSecret":"","cookieSecret":"","proxy":"edge","realm":"sas-iot","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","userRole":"sas-iot-user"},"livenessProbe":{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30},"replicaCount":2,"resources":{"limits":{"cpu":"500m","memory":"768Mi"},"requests":{"cpu":"50m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"startupProbe":{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30},"tolerations":[],"volumeMounts":[],"volumes":[]},"oauthProxy":{"resources":{"limits":{"cpu":"50m","memory":"32Mi"},"requests":{"cpu":"25m","memory":"16Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"},"volumeMounts":[],"volumes":[]}}` | SAS Retrieval Agent Manager IAM: Authentication services |
| iam.keycloak.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| iam.keycloak.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| iam.keycloak.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| iam.keycloak.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| iam.keycloak.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| iam.keycloak.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| iam.keycloak.config.adminRole | string | `"sas-iot-admin"` | Admin role name in Keycloak |
| iam.keycloak.config.clientId | string | `"sas-ram-app"` | OAuth2 client ID for the application |
| iam.keycloak.config.clientSecret | string | `""` | OAuth2 client secret for the application |
| iam.keycloak.config.cookieSecret | string | `""` | OAuth2 client secret for the application |
| iam.keycloak.config.proxy | string | `"edge"` | Proxy mode configuration (edge, reencrypt, or passthrough) |
| iam.keycloak.config.realm | string | `"sas-iot"` | Keycloak realm name for the application |
| iam.keycloak.config.secret_path | string | `"/mnt/config/keycloak"` | Path to Keycloak configuration secret mount |
| iam.keycloak.config.serviceaccountsEnabled | bool | `false` | Whether service accounts are enabled in Keycloak |
| iam.keycloak.config.strictHostname | bool | `true` | Whether to enforce strict hostname checking |
| iam.keycloak.config.theme | string | `"sasblue"` | Keycloak theme to use |
| iam.keycloak.config.userRole | string | `"sas-iot-user"` | User role name in Keycloak |
| iam.keycloak.livenessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30}` | Liveness probe configuration for Keycloak |
| iam.keycloak.livenessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| iam.keycloak.livenessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| iam.keycloak.livenessProbe.periodSeconds | int | `30` | How often to perform the probe |
| iam.keycloak.nodeSelector | object | `{}` | Node labels for pod assignment |
| iam.keycloak.podAnnotations | object | `{}` | Annotations to add to the pods |
| iam.keycloak.podLabels | object | `{}` | Labels to add to the pods |
| iam.keycloak.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| iam.keycloak.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| iam.keycloak.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| iam.keycloak.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| iam.keycloak.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| iam.keycloak.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| iam.keycloak.readinessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30}` | Readiness probe configuration for Keycloak |
| iam.keycloak.readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| iam.keycloak.readinessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| iam.keycloak.readinessProbe.periodSeconds | int | `30` | How often to perform the probe |
| iam.keycloak.replicaCount | int | `2` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| iam.keycloak.resources | object | `{"limits":{"cpu":"500m","memory":"768Mi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | The resources to allocate for the Keycloak container |
| iam.keycloak.resources.limits | object | `{"cpu":"500m","memory":"768Mi"}` | Resource limits for the container |
| iam.keycloak.resources.limits.cpu | string | `"500m"` | CPU limit |
| iam.keycloak.resources.limits.memory | string | `"768Mi"` | Memory limit |
| iam.keycloak.resources.requests | object | `{"cpu":"50m","memory":"256Mi"}` | Resource requests for the container |
| iam.keycloak.resources.requests.cpu | string | `"50m"` | CPU request |
| iam.keycloak.resources.requests.memory | string | `"256Mi"` | Memory request |
| iam.keycloak.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| iam.keycloak.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| iam.keycloak.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| iam.keycloak.securityContext.privileged | bool | `false` | Whether the container runs in privileged mode |
| iam.keycloak.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| iam.keycloak.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| iam.keycloak.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| iam.keycloak.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| iam.keycloak.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| iam.keycloak.service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| iam.keycloak.service.port | int | `8080` | Kubernetes Service port |
| iam.keycloak.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| iam.keycloak.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for Keycloak |
| iam.keycloak.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| iam.keycloak.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| iam.keycloak.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| iam.keycloak.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| iam.keycloak.startupProbe | object | `{"failureThreshold":5,"initialDelaySeconds":240,"periodSeconds":30}` | Liveness probe configuration for Keycloak |
| iam.keycloak.startupProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| iam.keycloak.startupProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| iam.keycloak.startupProbe.periodSeconds | int | `30` | How often to perform the probe |
| iam.keycloak.tolerations | list | `[]` | Tolerations for pod assignment |
| iam.keycloak.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| iam.keycloak.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| iam.oauthProxy | object | `{"resources":{"limits":{"cpu":"50m","memory":"32Mi"},"requests":{"cpu":"25m","memory":"16Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"},"volumeMounts":[],"volumes":[]}` | OAuth2 Proxy configuration for authentication |
| iam.oauthProxy.resources | object | `{"limits":{"cpu":"50m","memory":"32Mi"},"requests":{"cpu":"25m","memory":"16Mi"}}` | The resources to allocate for the OAuth2 Proxy container |
| iam.oauthProxy.resources.limits | object | `{"cpu":"50m","memory":"32Mi"}` | Resource limits for the OAuth2 Proxy container |
| iam.oauthProxy.resources.limits.cpu | string | `"50m"` | CPU limit |
| iam.oauthProxy.resources.limits.memory | string | `"32Mi"` | Memory limit |
| iam.oauthProxy.resources.requests | object | `{"cpu":"25m","memory":"16Mi"}` | Resource requests for the OAuth2 Proxy container |
| iam.oauthProxy.resources.requests.cpu | string | `"25m"` | CPU request |
| iam.oauthProxy.resources.requests.memory | string | `"16Mi"` | Memory request |
| iam.oauthProxy.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the OAuth2 Proxy application container |
| iam.oauthProxy.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| iam.oauthProxy.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the OAuth2 Proxy container |
| iam.oauthProxy.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| iam.oauthProxy.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| iam.oauthProxy.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| iam.oauthProxy.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| iam.oauthProxy.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the OAuth2 Proxy container |
| iam.oauthProxy.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"}` | OAuth2 Proxy service account configuration |
| iam.oauthProxy.serviceAccount.annotations | object | `{}` | Annotations to add to the OAuth2 Proxy service account |
| iam.oauthProxy.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials for OAuth2 Proxy |
| iam.oauthProxy.serviceAccount.create | bool | `true` | Specifies whether a service account should be created for OAuth2 Proxy |
| iam.oauthProxy.serviceAccount.name | string | `"oauth2-proxy"` | The name of the service account to use for OAuth2 Proxy |
| iam.oauthProxy.volumeMounts | list | `[]` | Additional volumeMounts on the OAuth2 Proxy Deployment definition |
| iam.oauthProxy.volumes | list | `[]` | Additional volumes on the OAuth2 Proxy Deployment definition |
| images.agent | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"},"tag":"1.18.1-20260812.1786551478299"}` | Container image configuration for RAM agents |
| images.agent.pullPolicy | string | `"IfNotPresent"` | Image pull policy for agent container |
| images.agent.repo.base | string | `"cr.sas.com"` | Container registry base URL for agent |
| images.agent.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"` | Container image path/name for agent |
| images.agent.tag | string | `"1.18.1-20260812.1786551478299"` | Container image tag for agent |
| images.api | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager"},"tag":"1.20.15-20260818.1787076669742"}` | Container image configuration for the RAM API |
| images.api.pullPolicy | string | `"IfNotPresent"` | Image pull policy for API container |
| images.api.repo.base | string | `"cr.sas.com"` | SAS container registry |
| images.api.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager"` | SAS API image |
| images.api.tag | string | `"1.20.15-20260818.1787076669742"` | Image tag (defaults to chart appVersion) |
| images.embedding | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"ghcr.io","path":"huggingface/text-embeddings-inference"},"tag":"cpu-1.8"}` | Container image configuration for embedding model inference |
| images.embedding.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| images.embedding.repo.base | string | `"ghcr.io"` | Container registry base URL for embedding model inference |
| images.embedding.repo.path | string | `"huggingface/text-embeddings-inference"` | Container image path/name for embedding model inference |
| images.embedding.tag | string | `"cpu-1.8"` | Container image tag for embedding model inference with CPU |
| images.eval | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"},"tag":"1.15.8-20260812.1786551507408"}` | Container image configuration for evaluations |
| images.eval.pullPolicy | string | `"IfNotPresent"` | Image pull policy for eval container |
| images.eval.repo.base | string | `"cr.sas.com"` | Container registry base URL for evaluation service |
| images.eval.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"` | Container image path/name for evaluation service |
| images.eval.tag | string | `"1.15.8-20260812.1786551507408"` | Container image tag for evaluation service |
| images.goose | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"},"tag":"1.15.3-20260812.1786551418645"}` | Goose migration tool container image configuration |
| images.goose.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Goose container |
| images.goose.repo.base | string | `"cr.sas.com"` | Container registry base URL for Goose |
| images.goose.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-db-migration"` | Container image path/name for Goose |
| images.goose.tag | string | `"1.15.3-20260812.1786551418645"` | Goose container image tag |
| images.imagePullSecrets | list | `[]` | Applied to all sub-charts that reference private registries |
| images.keycloak | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"},"tag":"26.3.2"}` | Container image configuration for Keycloak |
| images.keycloak.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Keycloak container |
| images.keycloak.repo | object | `{"base":"quay.io","path":"keycloak/keycloak"}` | Container image configuration for Keycloak |
| images.keycloak.repo.base | string | `"quay.io"` | Container registry base URL for Keycloak |
| images.keycloak.repo.path | string | `"keycloak/keycloak"` | Container image path/name for Keycloak |
| images.keycloak.tag | string | `"26.3.2"` | Keycloak container image tag |
| images.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"}` | kubectl container image configuration (used for Kubernetes operations) |
| images.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| images.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl |
| images.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl image |
| images.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| images.kubectl.tag | string | `"1.31.12"` | kubectl container image tag |
| images.mcpToolbox | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"us-central1-docker.pkg.dev","path":"database-toolbox/toolbox/toolbox"},"tag":"1.1.0"}` | Container image configuration for PSQL Toolbox MCP Server |
| images.mcpToolbox.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| images.mcpToolbox.repo.base | string | `"us-central1-docker.pkg.dev"` | Container registry base URL for embedding model inference |
| images.mcpToolbox.repo.path | string | `"database-toolbox/toolbox/toolbox"` | Container image path/name for embedding model inference |
| images.mcpToolbox.tag | string | `"1.1.0"` | Container image tag for embedding model inference with CPU |
| images.oauthProxy | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"}` | Container image configuration for OAuth2 Proxy |
| images.oauthProxy.pullPolicy | string | `"IfNotPresent"` | Image pull policy for OAuth2 Proxy container |
| images.oauthProxy.repo.base | string | `"quay.io"` | Container registry base URL for OAuth2 Proxy |
| images.oauthProxy.repo.path | string | `"oauth2-proxy/oauth2-proxy"` | Container image path/name for OAuth2 Proxy |
| images.oauthProxy.tag | string | `"v7.12.0"` | OAuth2 Proxy container image tag |
| images.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"}` | PostgreSQL database container image configuration |
| images.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| images.postgres.repo | object | `{"base":"docker.io","path":"postgres"}` | Container image configuration for Postgres |
| images.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| images.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| images.postgres.tag | string | `"15-alpine"` | PostgreSQL container image tag |
| images.postgrest | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"},"tag":"v13.0.4"}` | PostgREST main container image configuration |
| images.postgrest.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| images.postgrest.repo.base | string | `"docker.io"` | PostgREST registry |
| images.postgrest.repo.path | string | `"postgrest/postgrest"` | Official PostgREST image |
| images.postgrest.tag | string | `"v13.0.4"` | Image tag (defaults to chart appVersion) |
| images.repo | object | `{"base":null}` | Image repository details (useful for private registries) |
| images.repo.base | string | `nil` | Base container registry URL (used when mirrorring images) |
| images.theme | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"},"tag":"1.3.10-20260806.1786005822825"}` | Custom theme container image configuration |
| images.theme.pullPolicy | string | `"IfNotPresent"` | Image pull policy for theme container |
| images.theme.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}` | Container image configuration for the SAS Keycloak theme |
| images.theme.repo.base | string | `"cr.sas.com"` | Container registry base URL for theme |
| images.theme.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"` | Container image path/name for theme |
| images.theme.tag | string | `"1.3.10-20260806.1786005822825"` | Theme container image tag |
| images.ui | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"},"tag":"1.13.16-20260817.1786995762570"}` | Container image configuration for UI |
| images.ui.pullPolicy | string | `"IfNotPresent"` | Image pull policy for UI container |
| images.ui.repo.base | string | `"cr.sas.com"` | Container registry base URL |
| images.ui.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"` | Container image path/name |
| images.ui.tag | string | `"1.13.16-20260817.1786995762570"` | Container image tag |
| images.vectorizationHub | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"},"tag":"1.15.7-20260817.1787003665570"}` | Container image configuration for vectorization hub |
| images.vectorizationHub.pullPolicy | string | `"IfNotPresent"` | Image pull policy for vectorization hub container |
| images.vectorizationHub.repo.base | string | `"cr.sas.com"` | Container registry base URL for vectorization hub |
| images.vectorizationHub.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"` | Container image path/name for vectorization hub |
| images.vectorizationHub.tag | string | `"1.15.7-20260817.1787003665570"` | Container image tag for vectorization hub |
| ingress | object | `{"annotations":{},"api":{"annotations":{},"paths":["/SASRetrievalAgentManager/api"]},"className":null,"classType":null,"domain":null,"enableRootIngress":true,"enabled":true,"keycloak":{"paths":["/SASRetrievalAgentManager/auth","/SASRetrievalAgentManager/auth/realms","/SASRetrievalAgentManager/auth/resources"]},"keycloakAdmin":{"paths":["/SASRetrievalAgentManager/auth/admin"]},"oauthProxy":{"logoutPaths":["/SASRetrievalAgentManager/logout"],"paths":["/SASRetrievalAgentManager/oauth2"]},"postgrest":{"annotations":{},"paths":["/SASRetrievalAgentManager/postgrest","/SASRetrievalAgentManager/postgrest/monitoring"]},"tls":{"caCertificate":"","certManager":{"dnsNames":[],"duration":null,"enabled":false,"issuerRef":{"kind":"ClusterIssuer","name":""},"renewBefore":null},"certificate":"","enabled":true,"key":"","secretName":""},"ui":{"annotations":{},"paths":["/SASRetrievalAgentManager"]}}` | Ingress configuration for all services |
| ingress.annotations | object | `{}` | Add annotations here to override defaults or add new ones |
| ingress.api | object | `{"annotations":{},"paths":["/SASRetrievalAgentManager/api"]}` | Default annotations defined in templates/ingress/_nginx.tpl (nginx.default.annotations.api) |
| ingress.api.annotations | object | `{}` | Additional annotations for the API ingress (override or extend defaults) |
| ingress.api.paths | list | `["/SASRetrievalAgentManager/api"]` | API ingress paths configuration |
| ingress.className | string | `nil` | If not set, defaults are used based on classType |
| ingress.classType | string | `nil` | Ingress controller class type (nginx, route, contour, or null) |
| ingress.domain | string | `nil` | If not set, each chart uses its own host configuration |
| ingress.enableRootIngress | bool | `true` | Whether RAM is hosted on the root ingress or not |
| ingress.enabled | bool | `true` | Enable ingress resources globally |
| ingress.keycloak | object | `{"paths":["/SASRetrievalAgentManager/auth","/SASRetrievalAgentManager/auth/realms","/SASRetrievalAgentManager/auth/resources"]}` | Keycloak public ingress configuration |
| ingress.keycloak.paths | list | `["/SASRetrievalAgentManager/auth","/SASRetrievalAgentManager/auth/realms","/SASRetrievalAgentManager/auth/resources"]` | Keycloak public paths configuration |
| ingress.keycloakAdmin | object | `{"paths":["/SASRetrievalAgentManager/auth/admin"]}` | Keycloak admin ingress configuration |
| ingress.keycloakAdmin.paths | list | `["/SASRetrievalAgentManager/auth/admin"]` | Keycloak admin paths configuration |
| ingress.oauthProxy | object | `{"logoutPaths":["/SASRetrievalAgentManager/logout"],"paths":["/SASRetrievalAgentManager/oauth2"]}` | OAuth2 Proxy ingress configuration |
| ingress.oauthProxy.logoutPaths | list | `["/SASRetrievalAgentManager/logout"]` | OAuth2 logout paths |
| ingress.oauthProxy.paths | list | `["/SASRetrievalAgentManager/oauth2"]` | OAuth2 authentication paths |
| ingress.postgrest | object | `{"annotations":{},"paths":["/SASRetrievalAgentManager/postgrest","/SASRetrievalAgentManager/postgrest/monitoring"]}` | Default annotations defined in templates/ingress/_nginx.tpl (nginx.default.annotations.postgrest) |
| ingress.postgrest.annotations | object | `{}` | Additional annotations for the PostgREST ingress (override or extend defaults) |
| ingress.postgrest.paths | list | `["/SASRetrievalAgentManager/postgrest","/SASRetrievalAgentManager/postgrest/monitoring"]` | PostgREST paths configuration |
| ingress.tls.caCertificate | string | `""` | PEM-encoded CA certificate content, paired with `certificate` |
| ingress.tls.certManager | object | `{"dnsNames":[],"duration":null,"enabled":false,"issuerRef":{"kind":"ClusterIssuer","name":""},"renewBefore":null}` | certificate will be populated into spec.tls. |
| ingress.tls.certManager.dnsNames | list | `[]` | `ingress.domain` is always included |
| ingress.tls.certManager.duration | string | `nil` | If not set, cert-manager's default is used |
| ingress.tls.certManager.enabled | bool | `false` | For OpenShift Routes, requires openshift-routes controller to be installed. |
| ingress.tls.certManager.issuerRef | object | `{"kind":"ClusterIssuer","name":""}` | controller (requires openshift-routes to be installed separately). |
| ingress.tls.certManager.issuerRef.kind | string | `"ClusterIssuer"` | Kind of issuer: Issuer or ClusterIssuer |
| ingress.tls.certManager.issuerRef.name | string | `""` | Name of the Issuer or ClusterIssuer |
| ingress.tls.certManager.renewBefore | string | `nil` | If not set, cert-manager's default is used |
| ingress.tls.certificate | string | `""` | Ignored when `certManager.enabled` is true |
| ingress.tls.enabled | bool | `true` | Enable TLS/SSL termination |
| ingress.tls.key | string | `""` | PEM-encoded private key content, paired with `certificate` |
| ingress.tls.secretName | string | `""` | controller (github.com/cert-manager/openshift-routes) using the annotations below |
| ingress.ui | object | `{"annotations":{},"paths":["/SASRetrievalAgentManager"]}` | Default annotations defined in templates/ingress/_nginx.tpl (nginx.default.annotations.ui) |
| ingress.ui.annotations | object | `{}` | Additional annotations for the UI ingress (override or extend defaults) |
| ingress.ui.paths | list | `["/SASRetrievalAgentManager"]` | UI ingress paths configuration |
| integrations | object | `{"istio":{"enabled":false,"waypoint":{"name":"waypoint","waypointFor":"all"}},"kueue":{"config":{"cpuQuota":"32","memoryQuota":"128Gi","nvidiaGpuQuota":0,"podQuota":6},"enabled":true},"trustedCerts":{"enabled":false,"name":"trusted-certs-bundle","type":"configMap"},"viya":{"enabled":false}}` | Integrations with external services |
| integrations.istio | object | `{"enabled":false,"waypoint":{"name":"waypoint","waypointFor":"all"}}` | Istio ambient mesh integration. Deploys a waypoint proxy (L7 Envoy) into the release namespace so that X-Forwarded-For is populated with the real source pod IP for all HTTP traffic. |
| integrations.istio.enabled | bool | `false` | Enable Istio waypoint proxy and namespace enrollment |
| integrations.istio.waypoint | object | `{"name":"waypoint","waypointFor":"all"}` | Waypoint proxy configuration |
| integrations.istio.waypoint.name | string | `"waypoint"` | Name of the Gateway (waypoint) resource |
| integrations.istio.waypoint.waypointFor | string | `"all"` | Traffic types handled by the waypoint. "all" processes both east-west service traffic and ingress workload traffic. "service" handles east-west service traffic only. "workload" handles ingress workload traffic only. |
| integrations.kueue | object | `{"config":{"cpuQuota":"32","memoryQuota":"128Gi","nvidiaGpuQuota":0,"podQuota":6},"enabled":true}` | Kueue configuration for job scheduling and resource management |
| integrations.kueue.config | object | `{"cpuQuota":"32","memoryQuota":"128Gi","nvidiaGpuQuota":0,"podQuota":6}` | Kueue configuration |
| integrations.kueue.config.cpuQuota | string | `"32"` | Kueue CPU quota |
| integrations.kueue.config.memoryQuota | string | `"128Gi"` | Kueue memory quota |
| integrations.kueue.config.nvidiaGpuQuota | int | `0` | Kueue gpu quota |
| integrations.kueue.config.podQuota | int | `6` | Kueue pod quota |
| integrations.kueue.enabled | bool | `true` | Kueue enablement flag |
| integrations.trustedCerts | object | `{"enabled":false,"name":"trusted-certs-bundle","type":"configMap"}` | Trusted certificate configuration for secure communication with external services |
| integrations.trustedCerts.name | string | `"trusted-certs-bundle"` | Name of the ConfigMap or Secret containing trusted certificates (if enabled) |
| integrations.trustedCerts.type | string | `"configMap"` | Type of Kubernetes resource used to store trusted certificates Be aware that when managing these with trust-manager, it requires some explicit configuration to work with the operator. Refer to the documentation for more details: https://cert-manager.io/docs/trust/trust-manager/installation/#enable-secret-targets |
| integrations.viya | object | `{"enabled":false}` | Viya configuration for when deploying in parallel |
| integrations.viya.enabled | bool | `false` | Wether or not viya is enabled on the cluster |
| name | string | `"retrieval-agent-manager"` | This becomes the prefix for all Kubernetes resource names |
| platform | string | `"azure"` | Platform we are deploying on. (azure, aws, kubernetes, openshift) |
| podAnnotations | object | `{}` | Annotations to be added to all pods deployed by the SAS Retrieval Agent manager chart |
| podLabels | object | `{"sas.com/deployment":"retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to be added to all pods deployed by the SAS Retrieval Agent manager chart |
| security | object | `{"gpg":{"config":{"passphrase_path":"/mnt/config/gpg_passphrase","private_key_path":"/mnt/config/gpg_key"},"nameOverride":""}}` | SAS Retrieval Agent Manager Security: Security services |
| security.gpg.config.passphrase_path | string | `"/mnt/config/gpg_passphrase"` | Path to GPG passphrase secret mount |
| security.gpg.config.private_key_path | string | `"/mnt/config/gpg_key"` | Path to GPG private key secret mount |
| security.gpg.nameOverride | string | `""` | Default produces: retrieval-agent-manager-gpg-{passphrase,private-key,public-key} |
| storage | object | `{"application":{"pvc":{"accessModes":["ReadWriteOnce"],"existingClaim":"","name":"vhub-pv","size":"20Gi","storageClassName":null}},"customStorageClass":{"create":null,"name":"azurefile-sas"},"embedding":{"pvc":{"accessModes":["ReadWriteMany"],"existingClaim":"","name":"embedding-pv","size":"40Gi","storageClassName":null}}}` | SAS Retrieval Agent Manager Storage: Storage services |
| storage.application | object | `{"pvc":{"accessModes":["ReadWriteOnce"],"existingClaim":"","name":"vhub-pv","size":"20Gi","storageClassName":null}}` | Application data storage configuration |
| storage.application.pvc | object | `{"accessModes":["ReadWriteOnce"],"existingClaim":"","name":"vhub-pv","size":"20Gi","storageClassName":null}` | Persistent Volume Claim configuration (only used when type is 'pvc') |
| storage.application.pvc.accessModes | list | `["ReadWriteOnce"]` | Access modes for the root directory PVC |
| storage.application.pvc.existingClaim | string | `""` | Existing claim name for the root directory PVC (if not creating a new one) |
| storage.application.pvc.name | string | `"vhub-pv"` | Name for the PVC |
| storage.application.pvc.size | string | `"20Gi"` | Size for the root directory PVC |
| storage.application.pvc.storageClassName | string | `nil` | Storage class name for the root directory PVC |
| storage.customStorageClass | object | `{"create":null,"name":"azurefile-sas"}` | allows the creation of a custom storage class, used for an azurefile fix. |
| storage.customStorageClass.create | string | `nil` | Whether to create the custom storage class |
| storage.customStorageClass.name | string | `"azurefile-sas"` | Storage class name for the custom storage class (only used for an azurefile fix) |
| storage.embedding | object | `{"pvc":{"accessModes":["ReadWriteMany"],"existingClaim":"","name":"embedding-pv","size":"40Gi","storageClassName":null}}` | Embedding storage configuration |
| storage.embedding.pvc | object | `{"accessModes":["ReadWriteMany"],"existingClaim":"","name":"embedding-pv","size":"40Gi","storageClassName":null}` | Persistent Volume Claim configuration for embedding models |
| storage.embedding.pvc.accessModes | list | `["ReadWriteMany"]` | Access modes for the embedding PVC |
| storage.embedding.pvc.existingClaim | string | `""` | Existing claim name for the embedding PVC (if not creating a new one) |
| storage.embedding.pvc.name | string | `"embedding-pv"` | Name for the PVC |
| storage.embedding.pvc.size | string | `"40Gi"` | Size for the embedding PVC |
| storage.embedding.pvc.storageClassName | string | `nil` | Storage class name for the embedding PVC |
| ui | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80},"config":{"sslVerify":false},"livenessProbe":{"failureThreshold":9,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":9,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1},"replicaCount":2,"resources":{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"25m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"internalPort":8180,"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | SAS Retrieval Agent Manager UI: Main frontend service |
| ui.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| ui.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| ui.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| ui.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| ui.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| ui.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| ui.autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage for scaling (optional) |
| ui.config.sslVerify | bool | `false` | Whether to verify SSL certificates for backend API calls |
| ui.livenessProbe | object | `{"failureThreshold":9,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| ui.livenessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| ui.livenessProbe.periodSeconds | int | `15` | How often to perform the probe |
| ui.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| ui.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| ui.nodeSelector | object | `{}` | Node labels for pod assignment |
| ui.podAnnotations | object | `{}` | Annotations to add to the pods |
| ui.podLabels | object | `{}` | Labels to add to the pods |
| ui.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| ui.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| ui.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| ui.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| ui.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| ui.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| ui.readinessProbe | object | `{"failureThreshold":9,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| ui.readinessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| ui.readinessProbe.periodSeconds | int | `15` | How often to perform the probe |
| ui.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| ui.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| ui.replicaCount | int | `2` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| ui.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"25m","memory":"128Mi"}}` | The resources to allocate for the container |
| ui.resources.limits | object | `{"cpu":"500m","memory":"256Mi"}` | Resource limits for the container |
| ui.resources.limits.cpu | string | `"500m"` | CPU limit |
| ui.resources.limits.memory | string | `"256Mi"` | Memory limit |
| ui.resources.requests | object | `{"cpu":"25m","memory":"128Mi"}` | Resource requests for the container |
| ui.resources.requests.cpu | string | `"25m"` | CPU request |
| ui.resources.requests.memory | string | `"128Mi"` | Memory request |
| ui.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| ui.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| ui.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| ui.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| ui.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| ui.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| ui.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| ui.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| ui.service | object | `{"internalPort":8180,"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| ui.service.internalPort | int | `8180` | Internal service port (bypasses OAuth2 proxy for service-to-service calls) |
| ui.service.port | int | `8080` | Kubernetes Service port (routes through OAuth2 proxy for ingress/external traffic) |
| ui.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| ui.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| ui.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| ui.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| ui.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| ui.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| ui.tolerations | list | `[]` | Tolerations for pod assignment |
| ui.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| ui.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| users | object | `{"application":{"admin":{"password":"","username":"AppAdmin"}},"database":{"admin":{"password":"","username":"azure_pg_admin"}},"embedding":{"password":"","username":"sas_ram_embedding_user"},"keycloak":{"admin":{"password":"","username":"kcAdmin"},"user":{"password":"","username":"sas_keycloak_user"}},"migration":{"password":"","username":"sas_ram_migration"},"monitoring":{"password":"","username":"sas_mon_pgrest_user"},"otel":{"password":"","username":"sas_ram_otel_user"},"postgrest":{"password":"","username":"sas_ram_pgrest_user"},"vectorStore":{"password":"","username":"sas_vector_store_user"},"vectorizationJob":{"password":"","username":"sas_ram_vectorization_user"}}` | User account configuration for all services |
| vectorizationHub | object | `{"config":{"availableHardware":{"execution_providers":["cpu","openvino"],"hide_destination_secrets":"False","hide_llm_secrets":"False","job_req_cpu":{"default":2,"max":6,"min":1},"job_req_mem":{"default":"8Gi","max":"48Gi","min":"8Gi","model_default":{"all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","granite-embedding-278m-multilingual":"16Gi","nomic-embed-text-v2-moe":"16Gi"}},"mcp_req_cpu":{"default":0.5,"max":6,"min":0.1},"mcp_req_mem":{"default":"512Mi","max":"4Gi","min":"512Mi"},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":0.5,"max":6,"min":0.1},"plugin_req_mem":{"default":"1Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por","ara"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ","ara","tur"]}},"postgreSQLCertSecret":""}}` | SAS Retrieval Agent Manager Vectorization Hub: Main vectorization service |
| vectorizationHub.config | object | `{"availableHardware":{"execution_providers":["cpu","openvino"],"hide_destination_secrets":"False","hide_llm_secrets":"False","job_req_cpu":{"default":2,"max":6,"min":1},"job_req_mem":{"default":"8Gi","max":"48Gi","min":"8Gi","model_default":{"all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","granite-embedding-278m-multilingual":"16Gi","nomic-embed-text-v2-moe":"16Gi"}},"mcp_req_cpu":{"default":0.5,"max":6,"min":0.1},"mcp_req_mem":{"default":"512Mi","max":"4Gi","min":"512Mi"},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":0.5,"max":6,"min":0.1},"plugin_req_mem":{"default":"1Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por","ara"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ","ara","tur"]}},"postgreSQLCertSecret":""}` | Vectorization Hub configuration settings |
| vectorizationHub.config.availableHardware | object | `{"execution_providers":["cpu","openvino"],"hide_destination_secrets":"False","hide_llm_secrets":"False","job_req_cpu":{"default":2,"max":6,"min":1},"job_req_mem":{"default":"8Gi","max":"48Gi","min":"8Gi","model_default":{"all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","granite-embedding-278m-multilingual":"16Gi","nomic-embed-text-v2-moe":"16Gi"}},"mcp_req_cpu":{"default":0.5,"max":6,"min":0.1},"mcp_req_mem":{"default":"512Mi","max":"4Gi","min":"512Mi"},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":0.5,"max":6,"min":0.1},"plugin_req_mem":{"default":"1Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por","ara"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ","ara","tur"]}}` | Available hardware configuration for processing |
| vectorizationHub.config.availableHardware.execution_providers | list | `["cpu","openvino"]` | Execution providers for ML/AI processing |
| vectorizationHub.config.availableHardware.hide_destination_secrets | string | `"False"` | Whether to hide the destination secrets in the UI |
| vectorizationHub.config.availableHardware.hide_llm_secrets | string | `"False"` | Whether to hide the LLM api key in the UI |
| vectorizationHub.config.availableHardware.job_req_cpu | object | `{"default":2,"max":6,"min":1}` | CPU requirements for jobs |
| vectorizationHub.config.availableHardware.job_req_cpu.default | int | `2` | Default CPU allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_cpu.max | int | `6` | Maximum CPU allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_cpu.min | int | `1` | Minimum CPU allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_mem | object | `{"default":"8Gi","max":"48Gi","min":"8Gi","model_default":{"all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","granite-embedding-278m-multilingual":"16Gi","nomic-embed-text-v2-moe":"16Gi"}}` | Memory requirements for jobs |
| vectorizationHub.config.availableHardware.job_req_mem.default | string | `"8Gi"` | Default memory allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_mem.max | string | `"48Gi"` | Maximum memory allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_mem.min | string | `"8Gi"` | Minimum memory allocation for jobs |
| vectorizationHub.config.availableHardware.job_req_mem.model_default | object | `{"all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","granite-embedding-278m-multilingual":"16Gi","nomic-embed-text-v2-moe":"16Gi"}` | Model-specific memory defaults |
| vectorizationHub.config.availableHardware.mcp_req_cpu | object | `{"default":0.5,"max":6,"min":0.1}` | CPU requirements for jobs |
| vectorizationHub.config.availableHardware.mcp_req_cpu.default | float | `0.5` | Default CPU allocation for MCP |
| vectorizationHub.config.availableHardware.mcp_req_cpu.max | int | `6` | Maximum CPU allocation for MCP |
| vectorizationHub.config.availableHardware.mcp_req_cpu.min | float | `0.1` | Minimum CPU allocation for MCP |
| vectorizationHub.config.availableHardware.mcp_req_mem | object | `{"default":"512Mi","max":"4Gi","min":"512Mi"}` | Memory requirements for jobs |
| vectorizationHub.config.availableHardware.mcp_req_mem.default | string | `"512Mi"` | Default memory allocation for jobs |
| vectorizationHub.config.availableHardware.mcp_req_mem.max | string | `"4Gi"` | Maximum memory allocation for jobs |
| vectorizationHub.config.availableHardware.mcp_req_mem.min | string | `"512Mi"` | Minimum memory allocation for jobs |
| vectorizationHub.config.availableHardware.openvino_device_type | list | `["CPU_FP32"]` | OpenVINO device types supported |
| vectorizationHub.config.availableHardware.plugin_req_cpu | object | `{"default":0.5,"max":6,"min":0.1}` | CPU requirements for plugins |
| vectorizationHub.config.availableHardware.plugin_req_cpu.default | float | `0.5` | Default CPU allocation for MCP |
| vectorizationHub.config.availableHardware.plugin_req_cpu.max | int | `6` | Maximum CPU allocation for MCP |
| vectorizationHub.config.availableHardware.plugin_req_cpu.min | float | `0.1` | Minimum CPU allocation for MCP |
| vectorizationHub.config.availableHardware.plugin_req_mem | object | `{"default":"1Gi","max":"16Gi","min":"1Gi"}` | Memory requirements for plugins |
| vectorizationHub.config.availableHardware.plugin_req_mem.default | string | `"1Gi"` | Default memory allocation for plugins |
| vectorizationHub.config.availableHardware.plugin_req_mem.max | string | `"16Gi"` | Maximum memory allocation for plugins |
| vectorizationHub.config.availableHardware.plugin_req_mem.min | string | `"1Gi"` | Minimum memory allocation for plugins |
| vectorizationHub.config.availableHardware.supported_ocr_languages | object | `{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por","ara"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ","ara","tur"]}` | Supported OCR languages by engine |
| vectorizationHub.config.availableHardware.supported_ocr_languages.paddle | list | `["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por","ara"]` | Languages supported by PaddleOCR |
| vectorizationHub.config.availableHardware.supported_ocr_languages.tesseract | list | `["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ","ara","tur"]` | Languages supported by Tesseract |
| vectorizationHub.config.postgreSQLCertSecret | string | `""` | Secret containing the cert used for database connections in vectorization jobs |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
