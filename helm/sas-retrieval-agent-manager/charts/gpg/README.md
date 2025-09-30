# gpg

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.6](https://img.shields.io/badge/AppVersion-1.3.6-informational?style=flat-square)

A Helm chart for GPG key management and cryptographic operations in Kubernetes

**Homepage:** <https://gnupg.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| Vladimir Ghetau | <vladimir@ghetau.org> | <https://github.com/vladgh> |

## Source Code

* <https://github.com/vladgh/docker_base_images>
* <https://gnupg.org/download/>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| fullnameOverride | string | `"sas-retrieval-agent-manager-gpg"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"gpg":{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","privateKey":"","publicKey":""}}}` | Global configuration for GPG operations |
| global.configuration | object | `{"gpg":{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","privateKey":"","publicKey":""}}` | Configuration settings |
| global.configuration.gpg | object | `{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","privateKey":"","publicKey":""}` | GPG-specific configuration |
| global.configuration.gpg.key | object | `{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"}` | Key generation settings (used when publicKey and privateKey are not provided) |
| global.configuration.gpg.key.comment | string | `"RAM GPG Key"` | Comment for the generated GPG key |
| global.configuration.gpg.key.email | string | `"ram@sas.com"` | Email address associated with the generated GPG key |
| global.configuration.gpg.key.expire | string | `"0"` | Key expiration time (0 means never expires) |
| global.configuration.gpg.key.length | int | `4096` | Key length in bits for RSA keys |
| global.configuration.gpg.key.name | string | `"RAM Secrets"` | Name associated with the generated GPG key |
| global.configuration.gpg.passphrase | string | `""` | Passphrase for the GPG key. Required for both existing keys and key generation |
| global.configuration.gpg.privateKey | string | `""` | Existing GPG private key (base64 encoded). Leave empty to generate a new key pair |
| global.configuration.gpg.publicKey | string | `""` | Existing GPG public key (base64 encoded). Leave empty to generate a new key pair |
| image | object | `{"gpg":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"vladgh/gpg"},"tag":"1.3.6"},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"}}` | Container image configuration for GPG and kubectl containers |
| image.gpg | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"vladgh/gpg"},"tag":"1.3.6"}` | Container image configuration for GPG |
| image.gpg.pullPolicy | string | `"IfNotPresent"` | Image pull policy for GPG container |
| image.gpg.repo | object | `{"base":"docker.io","path":"vladgh/gpg"}` | Container image configuration for GPG |
| image.gpg.repo.base | string | `"docker.io"` | Container registry base URL for GPG image |
| image.gpg.repo.path | string | `"vladgh/gpg"` | Container image path/name for GPG |
| image.gpg.tag | string | `"1.3.6"` | GPG container image tag |
| image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"},"tag":"1.31.12"}` | kubectl container image configuration (used for Kubernetes operations) |
| image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl |
| image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl image |
| image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| image.kubectl.tag | string | `"1.31.12"` | kubectl container image tag |
| imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| nameOverride | string | `"gpg"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the container |
| resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| resources.limits.cpu | string | `"200m"` | CPU limit |
| resources.limits.memory | string | `"256Mi"` | Memory limit |
| resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"100m"` | CPU request |
| resources.requests.memory | string | `"128Mi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for GPG operations |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
