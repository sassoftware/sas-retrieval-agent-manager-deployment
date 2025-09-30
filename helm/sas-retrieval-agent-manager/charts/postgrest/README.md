# postgrest

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for PostgREST - RESTful API for PostgreSQL databases with automatic API generation

**Homepage:** <https://postgrest.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| PostgREST Team | <contact@postgrest.org> | <https://postgrest.org/> |

## Source Code

* <https://github.com/PostgREST/postgrest>
* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://hub.docker.com/r/postgrest/postgrest>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminService | object | `{"port":3001,"type":"ClusterIP"}` | Admin service configuration for PostgREST management |
| adminService.port | int | `3001` | Kubernetes Service port for PostgREST admin interface |
| adminService.type | string | `"ClusterIP"` | Kubernetes Service type for PostgREST admin interface |
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| fullnameOverride | string | `"sas-retrieval-agent-manager-postgrest"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"application":{"adminRole":"sas_ram_admin_role","password":"","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"postgrest":{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000},"swagger":{"enabled":false}}}` | Global configuration for PostgREST and related services |
| global.configuration | object | `{"application":{"adminRole":"sas_ram_admin_role","password":"","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"postgrest":{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000},"swagger":{"enabled":false}}` | Global configuration |
| global.configuration.application | object | `{"adminRole":"sas_ram_admin_role","password":"","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"}` | Application-specific configuration |
| global.configuration.application.adminRole | string | `"sas_ram_admin_role"` | Admin role name for database access |
| global.configuration.application.password | string | `""` | Database password for PostgREST application |
| global.configuration.application.user | string | `"sas_ram_pgrest_user"` | Database user for PostgREST application |
| global.configuration.application.userRole | string | `"sas_ram_user_role"` | User role name for database access |
| global.configuration.postgrest | object | `{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000}` | PostgREST-specific configuration |
| global.configuration.postgrest.admin-server-port | int | `3001` | Port for PostgREST admin server |
| global.configuration.postgrest.jwt-role-claim-key | string | `".resource_access.\"sas-ram-app\".roles[0]"` | JWT role claim key configuration (uses value from keycloak.clientId) |
| global.configuration.postgrest.log-level | string | `"info"` | Log level for PostgREST (info, warn, etc.) |
| global.configuration.postgrest.openapi-mode | string | `"follow-privileges"` | OpenAPI mode configuration |
| global.configuration.postgrest.openapi-security-active | bool | `true` | Whether OpenAPI security is active |
| global.configuration.postgrest.server-port | int | `3000` | Port for PostgREST main server |
| global.configuration.swagger | object | `{"enabled":false}` | Swagger UI configuration |
| global.configuration.swagger.enabled | bool | `false` | Whether Swagger UI is enabled |
| image | object | `{"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"},"postgrest":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"},"tag":"v13.0.4"}}` | Container image configuration for PostgREST and related services |
| image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"}` | kubectl container image configuration (used for Kubernetes operations) |
| image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl |
| image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl |
| image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| image.kubectl.tag | string | `"1.31.12"` | kubectl container image tag |
| image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"}` | PostgreSQL database container image configuration |
| image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| image.postgres.repo | object | `{"base":"docker.io","path":"postgres"}` | Container image configuration for postgres |
| image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| image.postgres.tag | string | `"15-alpine"` | PostgreSQL container image tag |
| image.postgrest | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"},"tag":"v13.0.4"}` | PostgREST main container image configuration |
| image.postgrest.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgREST container |
| image.postgrest.repo | object | `{"base":"docker.io","path":"postgrest/postgrest"}` | Container image configuration for postgrest |
| image.postgrest.repo.base | string | `"docker.io"` | Container registry base URL for PostgREST |
| image.postgrest.repo.path | string | `"postgrest/postgrest"` | Container image path/name for PostgREST |
| image.postgrest.tag | string | `"v13.0.4"` | PostgREST container image tag |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[{"host":"chart-example.local","paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]}],"paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to PostgREST |
| ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| ingress.className | string | `"nginx"` | Class name of the Ingress |
| ingress.enabled | bool | `true` | Enable ingress for external access |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]}]` | Hosts configuration (used when useGlobal is false) |
| ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| ingress.tls | list | `[]` | TLS configuration for ingress |
| ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/live","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for PostgREST |
| livenessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| livenessProbe.httpGet | object | `{"path":"/live","port":"admin","scheme":"HTTP"}` | HTTP GET probe configuration for liveness |
| livenessProbe.httpGet.path | string | `"/live"` | Path to probe for liveness |
| livenessProbe.httpGet.port | string | `"admin"` | Port to probe on |
| livenessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme to use |
| livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| nameOverride | string | `"postgrest"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/ready","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for PostgREST |
| readinessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| readinessProbe.httpGet | object | `{"path":"/ready","port":"admin","scheme":"HTTP"}` | HTTP GET probe configuration for readiness |
| readinessProbe.httpGet.path | string | `"/ready"` | Path to probe for readiness |
| readinessProbe.httpGet.port | string | `"admin"` | Port to probe on |
| readinessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme to use |
| readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| resources | object | `{"limits":{"cpu":2,"memory":"1Gi"},"requests":{"cpu":"500m","memory":"128Mi"}}` | The resources to allocate for the PostgREST container |
| resources.limits | object | `{"cpu":2,"memory":"1Gi"}` | Resource limits for the container |
| resources.limits.cpu | int | `2` | CPU limit |
| resources.limits.memory | string | `"1Gi"` | Memory limit |
| resources.requests | object | `{"cpu":"500m","memory":"128Mi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"500m"` | CPU request |
| resources.requests.memory | string | `"128Mi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| service | object | `{"port":3000,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.port | int | `3000` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| swagger | object | `{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":false,"fullnameOverride":"","image":{"pullPolicy":"IfNotPresent","repo":{"base":"swaggerapi","path":"swagger-ui"},"tag":"v5.17.14"},"imagePullSecrets":[],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/","port":"http"}},"nameOverride":"swagger","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"200m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Swagger UI configuration for API documentation |
| swagger.affinity | object | `{}` | Map of node/pod affinities for Swagger UI |
| swagger.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration for Swagger UI |
| swagger.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling for Swagger UI |
| swagger.autoscaling.maxReplicas | int | `100` | Maximum number of replicas for Swagger UI |
| swagger.autoscaling.minReplicas | int | `1` | Minimum number of replicas for Swagger UI |
| swagger.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for Swagger UI scaling |
| swagger.enabled | bool | `false` | Enable Swagger UI deployment |
| swagger.fullnameOverride | string | `""` | String to fully override the Swagger UI fullname template |
| swagger.image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"swaggerapi","path":"swagger-ui"},"tag":"v5.17.14"}` | Swagger UI container image configuration |
| swagger.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Swagger UI container |
| swagger.image.repo | object | `{"base":"swaggerapi","path":"swagger-ui"}` | Container image configuration for Swagger |
| swagger.image.repo.base | string | `"swaggerapi"` | Container registry base URL for Swagger UI |
| swagger.image.repo.path | string | `"swagger-ui"` | Container image path/name for Swagger UI |
| swagger.image.tag | string | `"v5.17.14"` | Swagger UI container image tag |
| swagger.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| swagger.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Swagger UI ingress configuration |
| swagger.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Swagger UI Ingress |
| swagger.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| swagger.ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| swagger.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| swagger.ingress.className | string | `"nginx"` | Class name of the Ingress |
| swagger.ingress.enabled | bool | `true` | Enable ingress for external access |
| swagger.ingress.hosts | list | `[]` | Hosts configuration for Swagger UI (ignored if useGlobal is true) |
| swagger.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Swagger UI paths configuration |
| swagger.ingress.tls | list | `[]` | TLS configuration for Swagger UI ingress |
| swagger.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| swagger.livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Liveness probe configuration for Swagger UI |
| swagger.livenessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for liveness |
| swagger.livenessProbe.httpGet.path | string | `"/"` | Path to probe for liveness |
| swagger.nameOverride | string | `"swagger"` | String to partially override the Swagger UI fullname template |
| swagger.nodeSelector | object | `{}` | Node labels for pod assignment |
| swagger.podAnnotations | object | `{}` | Annotations to add to the Swagger UI pods |
| swagger.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| swagger.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| swagger.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| swagger.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| swagger.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| swagger.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| swagger.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| swagger.readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Readiness probe configuration for Swagger UI |
| swagger.readinessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for readiness |
| swagger.readinessProbe.httpGet.path | string | `"/"` | Path to probe for readiness |
| swagger.replicaCount | int | `1` | Number of Swagger UI replicas |
| swagger.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"200m","memory":"256Mi"}}` | The resources to allocate for the Swagger UI container |
| swagger.resources.limits | object | `{"cpu":"100m","memory":"128Mi"}` | Resource limits for the Swagger UI container |
| swagger.resources.limits.cpu | string | `"100m"` | CPU limit |
| swagger.resources.limits.memory | string | `"128Mi"` | Memory limit |
| swagger.resources.requests | object | `{"cpu":"200m","memory":"256Mi"}` | Resource requests for the Swagger UI container |
| swagger.resources.requests.cpu | string | `"200m"` | CPU request |
| swagger.resources.requests.memory | string | `"256Mi"` | Memory request |
| swagger.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| swagger.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| swagger.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| swagger.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| swagger.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| swagger.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| swagger.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| swagger.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| swagger.service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| swagger.service.port | int | `80` | Kubernetes Service port |
| swagger.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| swagger.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| swagger.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| swagger.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| swagger.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| swagger.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| swagger.tolerations | list | `[]` | Tolerations for pod assignment |
| swagger.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| swagger.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| tolerations | list | `[]` | Tolerations for pod assignment |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| volumes | list | `[]` | Additional volumes on the output Deployment definition |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
