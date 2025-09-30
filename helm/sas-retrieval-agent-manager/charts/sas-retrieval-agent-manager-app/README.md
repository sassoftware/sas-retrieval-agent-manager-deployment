# sas-retrieval-agent-manager-app

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for SAS Retrieval Agent Manager App - React-based frontend web application for AI-powered document retrieval and query management

**Homepage:** <https://www.sas.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| SAS IoT Team | <iot-support@sas.com> | <https://www.sas.com/en_us/software/iot.html> |

## Source Code

* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://cr.sas.com/viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| fullnameOverride | string | `"sas-retrieval-agent-manager-app"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"ui":{"enableRootIngress":true,"sslVerify":"False"}},"domain":"","ingress":{"className":"nginx","enabled":true,"secretname":"","tls":{"enabled":true}}}` | Global configuration for SAS Retrieval Agent Manager App |
| global.configuration | object | `{"ui":{"enableRootIngress":true,"sslVerify":"False"}}` | Global configuration |
| global.configuration.ui | object | `{"enableRootIngress":true,"sslVerify":"False"}` | UI-specific configuration |
| global.configuration.ui.enableRootIngress | bool | `true` | Enable root ingress path routing |
| global.configuration.ui.sslVerify | string | `"False"` | SSL verification setting for UI requests |
| global.domain | string | `""` | If not set, each chart uses its own host configuration |
| global.ingress | object | `{"className":"nginx","enabled":true,"secretname":"","tls":{"enabled":true}}` | Default global ingress enabled value |
| global.ingress.className | string | `"nginx"` | Ingress controller class |
| global.ingress.enabled | bool | `true` | Enable ingress resources globally |
| global.ingress.secretname | string | `""` | Name of TLS secret |
| global.ingress.tls.enabled | bool | `true` | Enable TLS/SSL termination |
| image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"},"tag":"1.0.22-20250922.1758553227551"}` | Container image configuration for SAS Retrieval Agent Manager App |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for API container |
| image.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"}` | Container image configuration for API |
| image.repo.base | string | `"cr.sas.com"` | Container registry base URL |
| image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"` | Container image path/name |
| image.tag | string | `"1.0.22-20250922.1758553227551"` | Container image tag |
| imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to the web application |
| ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| ingress.className | string | `"nginx"` | Class name of the Ingress |
| ingress.enabled | bool | `true` | Enable ingress for external access |
| ingress.hosts | list | `[]` | Hosts configuration (used when useGlobal is false) |
| ingress.paths | list | `[{"path":"/SASRetrievalAgentManager(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| ingress.tls | list | `[]` | TLS configuration for ingress |
| ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| livenessProbe | object | `{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| livenessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| livenessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for liveness |
| livenessProbe.httpGet.path | string | `"/"` | Path to probe for liveness |
| livenessProbe.periodSeconds | int | `15` | How often to perform the probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| nameOverride | string | `"app"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| readinessProbe | object | `{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| readinessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| readinessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for readiness |
| readinessProbe.httpGet.path | string | `"/"` | Path to probe for readiness |
| readinessProbe.periodSeconds | int | `15` | How often to perform the probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| resources | object | `{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | The resources to allocate for the container |
| resources.limits | object | `{"cpu":1,"memory":"512Mi"}` | Resource limits for the container |
| resources.limits.cpu | int | `1` | CPU limit |
| resources.limits.memory | string | `"512Mi"` | Memory limit |
| resources.requests | object | `{"cpu":"100m","memory":"256Mi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"100m"` | CPU request |
| resources.requests.memory | string | `"256Mi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.port | int | `8080` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| volumes | list | `[]` | Additional volumes on the output Deployment definition |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
