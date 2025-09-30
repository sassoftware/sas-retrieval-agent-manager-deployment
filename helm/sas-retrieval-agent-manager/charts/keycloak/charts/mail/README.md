# mail

![Version: v4.4.0](https://img.shields.io/badge/Version-v4.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v4.4.0](https://img.shields.io/badge/AppVersion-v4.4.0-informational?style=flat-square)

An outgoing SMTP mail relay for your applications in Kubernetes cluster

**Homepage:** <https://github.com/bokysan/docker-postfix>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Bokysan |  | <https://github.com/bokysan> |

## Source Code

* <https://github.com/bokysan/docker-postfix>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling | object | `{"annotations":{},"enabled":false,"labels":{},"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| certs.create | bool | `false` | Auto-generate certificates for the server and mount them into Postfix volume |
| certs.existingSecret | string | `""` | Provide existing secret name |
| config | object | `{"general":{},"opendkim":{},"postfix":{}}` | Configuration for Postfix and related components |
| container.postfix.securityContext | object | `{}` |  |
| deployment.annotations | object | `{}` |  |
| deployment.labels | object | `{}` |  |
| dns | object | `{"nameservers":{},"options":{},"policy":"","searches":""}` | DNS configuration for the pod |
| existingSecret | string | `""` | Use an existing secret to share with the pod as environment variables |
| extraContainers | list | `[]` |  |
| extraEnv | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` | String to fully override the fullname template |
| headlessService | object | `{"annotations":{},"enabled":true,"labels":{}}` | Headless service configuration for StatefulSets |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"boky/postfix","tag":"latest"}` | Container image configuration |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"boky/postfix"` | Image repository |
| image.tag | string | `"latest"` | Image tag (If not specified uses chart's AppVersion as the tag) |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets for pulling images from private registries |
| lifecycle.postStart | object | `{}` |  |
| livenessProbe | object | `{"exec":{"command":["sh","-c","ps axf | fgrep -v grep | egrep -q '\\{supervisord\\}|/usr/bin/supervisord' && ps axf | fgrep -v grep | egrep -q '(/usr/lib/postfix/sbin/|/usr/libexec/postfix/)master'"]},"failureThreshold":2,"initialDelaySeconds":5,"periodSeconds":5}` | Liveness probe configuration |
| metrics | object | `{"enabled":false,"image":{"repository":"boky/postfix-exporter","tag":"latest"},"logrotate":{"enabled":true,"logrotate.conf":"/var/log/mail.log {\n    copytruncate\n    rotate 1\n    monthly\n    minsize 1M\n    compress\n    missingok\n    notifempty\n    dateext\n    olddir /var/log/\n    maxage 90\n}\n"},"maillog":"/var/log/mail.log","path":"/metrics","port":9154,"resources":{},"service":{"annotations":{},"labels":{}},"serviceMonitor":{"annotations":{},"enabled":false,"labels":{}}}` | Metrics exporter configuration |
| mountSecret | object | `{"data":{},"enabled":false,"path":"/var/lib/secret"}` | Secret to be deployed and mounted into a specific directory in the pod |
| nameOverride | string | `""` | String to partially override the fullname template |
| nodeSelector | object | `{}` |  |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"existingClaim":"","size":"1Gi","storageClass":""}` | Persistence configuration for the pod |
| pod.annotations | object | `{}` |  |
| pod.labels | object | `{}` |  |
| pod.securityContext | object | `{}` |  |
| readinessProbe | object | `{"exec":{"command":["sh","-c","/scripts/healthcheck.sh"]},"failureThreshold":6,"initialDelaySeconds":10,"periodSeconds":60,"timeoutSeconds":8}` | Readiness probe configuration |
| recreateOnRedeploy | bool | `true` | Whether to recreate pods on every deploy |
| replicaCount | int | `1` | Number of replicas to run |
| resources | object | `{}` | Resource requests and limits for the container |
| secret | object | `{}` | Data to be stored in a Secret and shared with the pod as environment variables |
| service | object | `{"annotations":{},"labels":{},"port":587,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.annotations | object | `{}` | Additional annotations for the service |
| service.labels | object | `{}` | Additional labels for the service |
| service.port | int | `587` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| startupProbe | object | `{"exec":{"command":["sh","-c","ps axf | fgrep -v grep | egrep -q '\\{supervisord\\}|/usr/bin/supervisord' && ps axf | fgrep -v grep | fgrep -q \"postfix-script\" && ps axf | fgrep -v grep | fgrep -q 'opendkim'"]},"failureThreshold":12,"initialDelaySeconds":5,"periodSeconds":5}` | Startup probe configuration |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
