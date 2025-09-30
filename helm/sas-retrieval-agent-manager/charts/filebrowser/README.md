# filebrowser

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.23.0](https://img.shields.io/badge/AppVersion-v2.23.0-informational?style=flat-square)

A Helm chart for File Browser - A web-based file management interface with OAuth2 authentication

**Homepage:** <https://filebrowser.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |

## Source Code

* <https://github.com/filebrowser/filebrowser>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| config | object | `{"address":"","baseURL":"/files","database":"/db/filebrowser.db","log":"stdout","port":18080,"root":"/mnt/data"}` | File Browser application specific configuration |
| config.address | string | `""` | Address to bind the server to (empty means all interfaces) |
| config.baseURL | string | `"/files"` | Base URL path for the filebrowser application |
| config.database | string | `"/db/filebrowser.db"` | Path to the SQLite database file for storing filebrowser configuration |
| config.log | string | `"stdout"` | Log output destination (stdout, stderr, or file path) |
| config.port | int | `18080` | Port on which the filebrowser application listens inside the container |
| config.root | string | `"/mnt/data"` | Root directory that filebrowser will serve and manage files from |
| db | object | `{"pvc":{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"256Mi","storageClassName":""}}` | Database configuration for Filebrowser |
| db.pvc | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"256Mi","storageClassName":""}` | Database persistence configuration |
| db.pvc.accessModes | list | `["ReadWriteOnce"]` | Access modes for the database PVC |
| db.pvc.enabled | bool | `true` | Enable persistence for database |
| db.pvc.size | string | `"256Mi"` | Size for the database PVC |
| db.pvc.storageClassName | string | `""` | Storage class name for the database PVC |
| enabled | bool | `false` | Enable the actual filebrowser deployment. Set to true to deploy the filebrowser component |
| fullnameOverride | string | `"sas-retrieval-agent-manager-filebrowser"` | String to fully override the fullname template with a string |
| image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"filebrowser/filebrowser"},"tag":"v2.42.1"}` | Container image configuration for Filebrowser and related services |
| image.pullPolicy | string | `"IfNotPresent"` | Container image pull policy |
| image.repo | object | `{"base":"docker.io","path":"filebrowser/filebrowser"}` | Container image configuration |
| image.repo.base | string | `"docker.io"` | Container registry base URL |
| image.repo.path | string | `"filebrowser/filebrowser"` | Container image path/name |
| image.tag | string | `"v2.42.1"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images |
| ingress | object | `{"annotations":{"nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"paths":[{"path":"/SASRetrievalAgentManager/files(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to Filebrowser |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body (for file uploads) |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response received from proxied server |
| ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| ingress.className | string | `"nginx"` | Class name of the Ingress |
| ingress.enabled | bool | `true` | Enable ingress for external access to API |
| ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/files(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Ingress path configuration when useGlobal is true |
| ingress.tls | list | `[]` | TLS configuration for ingress |
| ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| initContainers | list | `[]` | Set of initContainers for the deployment |
| livenessProbe | object | `{}` | Liveness probe configuration (disabled by default, enable if needed) |
| nameOverride | string | `"filebrowser"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{}` | The security context for the pods |
| readinessProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| resources | object | `{}` | The resources to allocate for the container |
| rootDir.hostPath | object | `{"path":"/mnt/data"}` | Host path configuration (only used when type is 'hostPath') |
| rootDir.hostPath.path | string | `"/mnt/data"` | Path on the host to mount |
| rootDir.pvc | object | `{"accessModes":["ReadWriteOnce"],"createStorageClass":true,"name":"vhub-pv","size":"20Gi","storageClassName":"azurefile-sas"}` | Persistent Volume Claim configuration (only used when type is 'pvc') |
| rootDir.pvc.accessModes | list | `["ReadWriteOnce"]` | Access modes for the root directory PVC |
| rootDir.pvc.createStorageClass | bool | `true` | Whether to create the storage class if it doesn't exist |
| rootDir.pvc.name | string | `"vhub-pv"` | Name for the PVC |
| rootDir.pvc.size | string | `"20Gi"` | Size for the root directory PVC |
| rootDir.pvc.storageClassName | string | `"azurefile-sas"` | Storage class name for the root directory PVC |
| rootDir.readOnly | bool | `false` | Mount the root directory in read-only mode |
| rootDir.type | string | `"pvc"` | Type of rootDir mount. Valid values are [pvc, hostPath, emptyDir] |
| securityContext | object | `{}` | The security context for the application container |
| service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.port | int | `80` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration for API |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| strategy | object | `{"type":"Recreate"}` | Deployment strategy to use (Recreate is recommended for stateful applications) |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
