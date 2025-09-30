# keycloak

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Keycloak Identity and Access Management with OAuth2/OIDC support

**Homepage:** <https://www.keycloak.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| Keycloak Team | <keycloak-dev@lists.jboss.org> | <https://www.keycloak.org/> |

## Source Code

* <https://github.com/keycloak/keycloak>
* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://quay.io/repository/keycloak/keycloak>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | mail | v4.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| fullnameOverride | string | `"sas-retrieval-agent-manager-keycloak"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"keycloak":{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","proxy":"edge","realm":"sas-iot","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","userRole":"sas-iot-user"}}}` | Global configuration for Keycloak and related services |
| global.configuration | object | `{"keycloak":{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","proxy":"edge","realm":"sas-iot","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","userRole":"sas-iot-user"}}` | Configuration settings |
| global.configuration.keycloak | object | `{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","proxy":"edge","realm":"sas-iot","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","userRole":"sas-iot-user"}` | Keycloak-specific configuration |
| global.configuration.keycloak.adminRole | string | `"sas-iot-admin"` | Admin role name in Keycloak |
| global.configuration.keycloak.appAdmin | string | `"AppAdmin"` | Application admin username |
| global.configuration.keycloak.appAdminPassword | string | `""` | Application admin password |
| global.configuration.keycloak.clientId | string | `"sas-ram-app"` | OAuth2 client ID for the application |
| global.configuration.keycloak.clientSecret | string | `""` | OAuth2 client secret for the application |
| global.configuration.keycloak.keycloakAdmin | string | `"kcAdmin"` | Keycloak admin username |
| global.configuration.keycloak.keycloakAdminPassword | string | `""` | Keycloak admin password |
| global.configuration.keycloak.proxy | string | `"edge"` | Proxy mode configuration (edge, reencrypt, or passthrough) |
| global.configuration.keycloak.realm | string | `"sas-iot"` | Keycloak realm name for the application |
| global.configuration.keycloak.serviceaccountsEnabled | bool | `false` | Whether service accounts are enabled in Keycloak |
| global.configuration.keycloak.strictHostname | bool | `true` | Whether to enforce strict hostname checking |
| global.configuration.keycloak.theme | string | `"sasblue"` | Keycloak theme to use |
| global.configuration.keycloak.userRole | string | `"sas-iot-user"` | User role name in Keycloak |
| image | object | `{"keycloak":{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"},"tag":"26.3.2"},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"},"theme":{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"},"tag":"1.2.19-20250908.1757359720294"}}` | Container image configuration for Keycloak and related services |
| image.keycloak | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"},"tag":"26.3.2"}` | Container image configuration for Keycloak |
| image.keycloak.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Keycloak container |
| image.keycloak.repo | object | `{"base":"quay.io","path":"keycloak/keycloak"}` | Container image configuration for Keycloak |
| image.keycloak.repo.base | string | `"quay.io"` | Container registry base URL for Keycloak |
| image.keycloak.repo.path | string | `"keycloak/keycloak"` | Container image path/name for Keycloak |
| image.keycloak.tag | string | `"26.3.2"` | Keycloak container image tag |
| image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"}` | kubectl container image configuration (used for Kubernetes operations) |
| image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl container |
| image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl |
| image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| image.kubectl.tag | string | `"1.31.12"` | kubectl container image tag |
| image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"},"tag":"15-alpine"}` | PostgreSQL database container image configuration |
| image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| image.postgres.repo | object | `{"base":"docker.io","path":"postgres"}` | Container image configuration for Postgres |
| image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| image.postgres.tag | string | `"15-alpine"` | PostgreSQL container image tag |
| image.theme | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"},"tag":"1.2.19-20250908.1757359720294"}` | Custom theme container image configuration |
| image.theme.pullPolicy | string | `"IfNotPresent"` | Image pull policy for theme container |
| image.theme.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}` | Container image configuration for the SAS Keycloak theme |
| image.theme.repo.base | string | `"cr.sas.com"` | Container registry base URL for theme |
| image.theme.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"` | Container image path/name for theme |
| image.theme.tag | string | `"1.2.19-20250908.1757359720294"` | Theme container image tag |
| imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| ingress | object | `{"admin":{"enabled":true,"host":"","path":"/SASRetrievalAgentManager/auth/admin","pathType":"Prefix","sourceRange":[]},"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/auth(/(realms|resources)/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to Keycloak |
| ingress.admin | object | `{"enabled":true,"host":"","path":"/SASRetrievalAgentManager/auth/admin","pathType":"Prefix","sourceRange":[]}` | Admin interface ingress configuration |
| ingress.admin.enabled | bool | `true` | Enable admin interface access via ingress. If false, admin console is only accessible via port forwarding |
| ingress.admin.host | string | `""` | Admin interface host (ignored if useGlobal is true) |
| ingress.admin.path | string | `"/SASRetrievalAgentManager/auth/admin"` | Admin interface path |
| ingress.admin.pathType | string | `"Prefix"` | Admin interface path type |
| ingress.admin.sourceRange | list | `[]` | IP addresses or CIDR blocks allowed to access admin interface. Empty means allow all |
| ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response received from proxied server |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| ingress.className | string | `"nginx"` | Class name of the Ingress |
| ingress.enabled | bool | `true` | Enable ingress for external access to Keycloak |
| ingress.hosts | list | `[]` | Hosts configuration (ignored if useGlobal is true) |
| ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/auth(/(realms|resources)/(.*))$","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| ingress.tls | list | `[]` | TLS configuration for ingress |
| ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30}` | Liveness probe configuration for Keycloak |
| livenessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| livenessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"}` | HTTP GET probe configuration |
| livenessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/auth/realms/master"` | Path to probe for liveness |
| livenessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| livenessProbe.periodSeconds | int | `30` | How often to perform the probe |
| mail | object | `{"config":{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}},"container":{"postfix":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}},"enabled":false,"fullnameOverride":"mail","persistence":{"enabled":false},"pod":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}}` | Mail server configuration (optional email service for development) |
| mail.config | object | `{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}}` | Mail server configuration settings |
| mail.config.general | object | `{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"}` | General mail server settings |
| mail.config.general.ALLOW_EMPTY_SENDER_DOMAINS | string | `"true"` | Allow empty sender domains |
| mail.config.general.TZ | string | `"UTC"` | Timezone for mail server |
| mail.config.postfix | object | `{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}` | Postfix-specific configuration |
| mail.config.postfix.myhostname | string | `""` | Mail server hostname |
| mail.config.postfix.mynetworks | string | `"10.0.0.0/8, 127.0.0.0/8"` | Trusted networks for mail relay |
| mail.config.postfix.smtpd_recipient_restrictions | string | `"permit_mynetworks, reject_unauth_destination"` | SMTP recipient restrictions |
| mail.container | object | `{"postfix":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}}` | Container configuration for mail server |
| mail.container.postfix | object | `{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}` | Postfix container configuration |
| mail.container.postfix.securityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for postfix container |
| mail.container.postfix.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for postfix container |
| mail.enabled | bool | `false` | Enable mail server deployment |
| mail.fullnameOverride | string | `"mail"` | Full name override for mail service |
| mail.persistence | object | `{"enabled":false}` | Persistence configuration for mail server |
| mail.persistence.enabled | bool | `false` | Enable persistence for mail server |
| mail.pod | object | `{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}` | Pod configuration for mail server |
| mail.pod.securityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for mail server pod |
| mail.pod.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for mail server pod |
| nameOverride | string | `"keycloak"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| oauthProxy | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-oauth2-proxy","image":{"pullPolicy":"Always","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"},"imagePullSecrets":[{"name":"acr-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"logoutPaths":[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}],"paths":[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/ping","port":"http"}},"nameOverride":"oauth2-proxy","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/ping","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":4180,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"},"tolerations":[],"volumeMounts":[],"volumes":[]}` | OAuth2 Proxy configuration for authentication |
| oauthProxy.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities for OAuth2 Proxy |
| oauthProxy.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration for OAuth2 Proxy |
| oauthProxy.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling for OAuth2 Proxy |
| oauthProxy.autoscaling.maxReplicas | int | `100` | Maximum number of replicas for OAuth2 Proxy |
| oauthProxy.autoscaling.minReplicas | int | `1` | Minimum number of replicas for OAuth2 Proxy |
| oauthProxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for OAuth2 Proxy scaling |
| oauthProxy.fullnameOverride | string | `"sas-retrieval-agent-manager-oauth2-proxy"` | String to fully override the OAuth2 Proxy fullname template |
| oauthProxy.image | object | `{"pullPolicy":"Always","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"}` | OAuth2 Proxy container image configuration |
| oauthProxy.image.pullPolicy | string | `"Always"` | Image pull policy for OAuth2 Proxy container |
| oauthProxy.image.repo.base | string | `"quay.io"` | Container registry base URL for OAuth2 Proxy |
| oauthProxy.image.repo.path | string | `"oauth2-proxy/oauth2-proxy"` | Container image path/name for OAuth2 Proxy |
| oauthProxy.image.tag | string | `"v7.12.0"` | OAuth2 Proxy container image tag |
| oauthProxy.imagePullSecrets | list | `[{"name":"acr-secret"}]` | Array of imagePullSecrets for OAuth2 Proxy |
| oauthProxy.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"logoutPaths":[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}],"paths":[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | OAuth2 Proxy ingress configuration |
| oauthProxy.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the OAuth2 Proxy Ingress |
| oauthProxy.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` | Enable CORS for OAuth2 Proxy |
| oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/session-cookie-samesite" | string | `"lax"` | Session cookie SameSite attribute |
| oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| oauthProxy.ingress.className | string | `"nginx"` | Class name of the OAuth2 Proxy Ingress |
| oauthProxy.ingress.enabled | bool | `true` | Enable ingress for OAuth2 Proxy |
| oauthProxy.ingress.hosts | list | `[]` | Hosts configuration for OAuth2 Proxy (ignored if useGlobal is true) |
| oauthProxy.ingress.logoutPaths | list | `[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}]` | OAuth2 logout paths |
| oauthProxy.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}]` | OAuth2 authentication paths |
| oauthProxy.ingress.tls | list | `[]` | TLS configuration for OAuth2 Proxy ingress |
| oauthProxy.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts for OAuth2 Proxy |
| oauthProxy.livenessProbe | object | `{"httpGet":{"path":"/ping","port":"http"}}` | Liveness probe configuration for OAuth2 Proxy |
| oauthProxy.livenessProbe.httpGet | object | `{"path":"/ping","port":"http"}` | HTTP GET probe configuration for liveness |
| oauthProxy.livenessProbe.httpGet.path | string | `"/ping"` | Path to probe for liveness |
| oauthProxy.nameOverride | string | `"oauth2-proxy"` | String to partially override the OAuth2 Proxy fullname template |
| oauthProxy.nodeSelector | object | `{}` | Node labels for OAuth2 Proxy pod assignment |
| oauthProxy.podAnnotations | object | `{}` | Annotations to add to the OAuth2 Proxy pods |
| oauthProxy.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the OAuth2 Proxy pods |
| oauthProxy.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the OAuth2 Proxy pods |
| oauthProxy.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| oauthProxy.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| oauthProxy.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| oauthProxy.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| oauthProxy.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the OAuth2 Proxy pod |
| oauthProxy.readinessProbe | object | `{"httpGet":{"path":"/ping","port":"http"}}` | Readiness probe configuration for OAuth2 Proxy |
| oauthProxy.readinessProbe.httpGet | object | `{"path":"/ping","port":"http"}` | HTTP GET probe configuration for readiness |
| oauthProxy.readinessProbe.httpGet.path | string | `"/ping"` | Path to probe for readiness |
| oauthProxy.replicaCount | int | `1` | Number of OAuth2 Proxy replicas @schema type: integer required: true default: 1 @schema |
| oauthProxy.resources | object | `{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}}` | The resources to allocate for the OAuth2 Proxy container |
| oauthProxy.resources.limits | object | `{"cpu":"100m","memory":"64Mi"}` | Resource limits for the OAuth2 Proxy container |
| oauthProxy.resources.limits.cpu | string | `"100m"` | CPU limit |
| oauthProxy.resources.limits.memory | string | `"64Mi"` | Memory limit |
| oauthProxy.resources.requests | object | `{"cpu":"50m","memory":"32Mi"}` | Resource requests for the OAuth2 Proxy container |
| oauthProxy.resources.requests.cpu | string | `"50m"` | CPU request |
| oauthProxy.resources.requests.memory | string | `"32Mi"` | Memory request |
| oauthProxy.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the OAuth2 Proxy application container |
| oauthProxy.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| oauthProxy.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the OAuth2 Proxy container |
| oauthProxy.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| oauthProxy.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| oauthProxy.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| oauthProxy.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| oauthProxy.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the OAuth2 Proxy container |
| oauthProxy.service | object | `{"port":4180,"type":"ClusterIP"}` | OAuth2 Proxy service configuration |
| oauthProxy.service.port | int | `4180` | Kubernetes Service port for OAuth2 Proxy |
| oauthProxy.service.type | string | `"ClusterIP"` | Kubernetes Service type for OAuth2 Proxy |
| oauthProxy.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"}` | OAuth2 Proxy service account configuration |
| oauthProxy.serviceAccount.annotations | object | `{}` | Annotations to add to the OAuth2 Proxy service account |
| oauthProxy.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials for OAuth2 Proxy |
| oauthProxy.serviceAccount.create | bool | `true` | Specifies whether a service account should be created for OAuth2 Proxy |
| oauthProxy.serviceAccount.name | string | `"oauth2-proxy"` | The name of the service account to use for OAuth2 Proxy |
| oauthProxy.tolerations | list | `[]` | Tolerations for OAuth2 Proxy pod assignment |
| oauthProxy.volumeMounts | list | `[]` | Additional volumeMounts on the OAuth2 Proxy Deployment definition |
| oauthProxy.volumes | list | `[]` | Additional volumes on the OAuth2 Proxy Deployment definition |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30}` | Readiness probe configuration for Keycloak |
| readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| readinessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"}` | HTTP GET probe configuration |
| readinessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/auth/realms/master"` | Path to probe for readiness |
| readinessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| readinessProbe.periodSeconds | int | `30` | How often to perform the probe |
| replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| resources | object | `{"limits":{"cpu":"500m","memory":"768Mi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | The resources to allocate for the Keycloak container |
| resources.limits | object | `{"cpu":"500m","memory":"768Mi"}` | Resource limits for the container |
| resources.limits.cpu | string | `"500m"` | CPU limit |
| resources.limits.memory | string | `"768Mi"` | Memory limit |
| resources.requests | object | `{"cpu":"50m","memory":"256Mi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"50m"` | CPU request |
| resources.requests.memory | string | `"256Mi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.privileged | bool | `false` | Whether the container runs in privileged mode |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.port | int | `8080` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for Keycloak |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| volumes | list | `[]` | Additional volumes on the output Deployment definition |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
