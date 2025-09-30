# sas-retrieval-agent-manager-api

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for SAS Retrieval Agent Manager API - Backend service with AI/ML capabilities for document retrieval and vectorization

**Homepage:** <https://www.sas.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SAS Institute | <support@sas.com> | <https://www.sas.com> |
| SAS IoT Team | <iot-support@sas.com> | <https://www.sas.com/en_us/software/iot.html> |

## Source Code

* <https://github.com/sas-institute-rnd-internal/tmp-viya-iot-ram-helm>
* <https://cr.sas.com/viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| fullnameOverride | string | `"sas-retrieval-agent-manager-api"` | String to fully override the fullname template with a string |
| global | object | `{"configuration":{"api":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"},"eval":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"},"tag":"1.4.0-20250923.1758633873448"}},"gpg":{"passphrase_path":"/mnt/config/gpg_passphrase","private_key_path":"/mnt/config/gpg_key"},"keycloak":{"secret_path":"/mnt/config/keycloak"},"plugin":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"},"tag":"1.4.1-20250910.1757512703913"}},"swagger":{"enabled":true},"vhub":{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"},"tag":"1.4.0-20250910.1757510909689"},"imagePullSecrets":[],"postgreSQLCertSecret":""}}}` | Global configuration for API and related services |
| global.configuration | object | `{"api":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"},"eval":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"},"tag":"1.4.0-20250923.1758633873448"}},"gpg":{"passphrase_path":"/mnt/config/gpg_passphrase","private_key_path":"/mnt/config/gpg_key"},"keycloak":{"secret_path":"/mnt/config/keycloak"},"plugin":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"},"tag":"1.4.1-20250910.1757512703913"}},"swagger":{"enabled":true},"vhub":{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"},"tag":"1.4.0-20250910.1757510909689"},"imagePullSecrets":[],"postgreSQLCertSecret":""}}` | Configuration settings |
| global.configuration.api | object | `{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"}` | API-specific configuration |
| global.configuration.api.azure_settings | object | `{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}}` | Azure integration settings for API and identity management |
| global.configuration.api.azure_settings.azure_identity | object | `{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"}` | Azure integration settings for identity management |
| global.configuration.api.azure_settings.azure_identity.client_id | string | `""` | Azure AD client ID for authentication (leave blank to disable) |
| global.configuration.api.azure_settings.azure_identity.enabled | bool | `false` | Enable Azure AD identity integration (true/false) |
| global.configuration.api.azure_settings.azure_identity.scope | string | `"https://cognitiveservices.azure.com/.default"` | OAuth2 scope for Azure Cognitive Services authentication |
| global.configuration.api.azure_settings.azure_identity.token_keyword | string | `"AZURE_IDENTITY"` | Keyword used to identify Azure identity tokens in requests |
| global.configuration.api.azure_settings.openAI.default_api_version | string | `"2024-10-21"` | Default API version for Azure OpenAI service (format: YYYY-MM-DD) |
| global.configuration.api.base_path | string | `"/SASRetrievalAgentManager/api"` | Base path for API endpoints |
| global.configuration.api.enable_dev_mode | string | `"False"` | Enable development mode features |
| global.configuration.api.enable_profiling | string | `"False"` | Enable profiling capabilities |
| global.configuration.api.latest_version | string | `"v1"` | Latest API version |
| global.configuration.api.license | string | `""` | License content (if not using secret) |
| global.configuration.api.license_secret | string | `"license-secret"` | Name of the license secret |
| global.configuration.api.license_secret_path | string | `"/mnt/config/license"` | Path to license secret mount |
| global.configuration.api.log_level | string | `"INFO"` | Log level for the API |
| global.configuration.api.num_workers | int | `4` | Number of worker processes |
| global.configuration.api.sslVerify | string | `"True"` | SSL verification setting |
| global.configuration.api.useOldLicense | string | `"False"` | Whether to use old license format |
| global.configuration.eval | object | `{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"},"tag":"1.4.0-20250923.1758633873448"}}` | Evaluation service configuration |
| global.configuration.eval.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"},"tag":"1.4.0-20250923.1758633873448"}` | Container image configuration for evaluation service |
| global.configuration.eval.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for evaluation service |
| global.configuration.eval.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"` | Container image path/name for evaluation service |
| global.configuration.eval.image.tag | string | `"1.4.0-20250923.1758633873448"` | Container image tag for evaluation service |
| global.configuration.gpg | object | `{"passphrase_path":"/mnt/config/gpg_passphrase","private_key_path":"/mnt/config/gpg_key"}` | GPG configuration for encryption/decryption |
| global.configuration.gpg.passphrase_path | string | `"/mnt/config/gpg_passphrase"` | Path to GPG passphrase secret mount |
| global.configuration.gpg.private_key_path | string | `"/mnt/config/gpg_key"` | Path to GPG private key secret mount |
| global.configuration.keycloak | object | `{"secret_path":"/mnt/config/keycloak"}` | Keycloak integration configuration |
| global.configuration.keycloak.secret_path | string | `"/mnt/config/keycloak"` | Path to Keycloak configuration secret mount |
| global.configuration.plugin | object | `{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"},"tag":"1.4.1-20250910.1757512703913"}}` | Plugin agent configuration |
| global.configuration.plugin.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"},"tag":"1.4.1-20250910.1757512703913"}` | Container image configuration for plugin agent |
| global.configuration.plugin.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for plugin agent |
| global.configuration.plugin.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"` | Container image path/name for plugin agent |
| global.configuration.plugin.image.tag | string | `"1.4.1-20250910.1757512703913"` | Container image tag for plugin agent |
| global.configuration.swagger | object | `{"enabled":true}` | Swagger UI configuration |
| global.configuration.swagger.enabled | bool | `true` | Enable Swagger UI for API documentation |
| global.configuration.vhub | object | `{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"},"tag":"1.4.0-20250910.1757510909689"},"imagePullSecrets":[],"postgreSQLCertSecret":""}` | Vectorization Hub (VHub) configuration |
| global.configuration.vhub.availableHardware | object | `{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}}` | Available hardware configuration for processing |
| global.configuration.vhub.availableHardware.execution_providers | list | `["cpu","openvino"]` | Execution providers for ML/AI processing |
| global.configuration.vhub.availableHardware.job_req_cpu | object | `{"default":6,"max":6,"min":1}` | CPU requirements for jobs |
| global.configuration.vhub.availableHardware.job_req_cpu.default | int | `6` | Default CPU allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_cpu.max | int | `6` | Maximum CPU allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_cpu.min | int | `1` | Minimum CPU allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_mem | object | `{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}}` | Memory requirements for jobs |
| global.configuration.vhub.availableHardware.job_req_mem.default | string | `"32Gi"` | Default memory allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_mem.max | string | `"48Gi"` | Maximum memory allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_mem.min | string | `"16Gi"` | Minimum memory allocation for jobs |
| global.configuration.vhub.availableHardware.job_req_mem.model_default | object | `{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}` | Model-specific memory defaults |
| global.configuration.vhub.availableHardware.openvino_device_type | list | `["CPU_FP32"]` | OpenVINO device types supported |
| global.configuration.vhub.availableHardware.plugin_req_cpu | object | `{"default":2,"max":6,"min":1}` | CPU requirements for plugins |
| global.configuration.vhub.availableHardware.plugin_req_cpu.default | int | `2` | Default CPU allocation for plugins |
| global.configuration.vhub.availableHardware.plugin_req_cpu.max | int | `6` | Maximum CPU allocation for plugins |
| global.configuration.vhub.availableHardware.plugin_req_cpu.min | int | `1` | Minimum CPU allocation for plugins |
| global.configuration.vhub.availableHardware.plugin_req_mem | object | `{"default":"4Gi","max":"16Gi","min":"1Gi"}` | Memory requirements for plugins |
| global.configuration.vhub.availableHardware.plugin_req_mem.default | string | `"4Gi"` | Default memory allocation for plugins |
| global.configuration.vhub.availableHardware.plugin_req_mem.max | string | `"16Gi"` | Maximum memory allocation for plugins |
| global.configuration.vhub.availableHardware.plugin_req_mem.min | string | `"1Gi"` | Minimum memory allocation for plugins |
| global.configuration.vhub.availableHardware.supported_ocr_languages | object | `{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}` | Supported OCR languages by engine |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle | list | `["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"]` | Languages supported by PaddleOCR |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract | list | `["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]` | Languages supported by Tesseract |
| global.configuration.vhub.awsCertSecret | string | `""` | AWS certificate secret name (if using AWS) |
| global.configuration.vhub.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"},"tag":"1.4.0-20250910.1757510909689"}` | Container image configuration for vectorization hub |
| global.configuration.vhub.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for vectorization hub |
| global.configuration.vhub.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"` | Container image path/name for vectorization hub |
| global.configuration.vhub.image.tag | string | `"1.4.0-20250910.1757510909689"` | Container image tag for vectorization hub |
| global.configuration.vhub.imagePullSecrets | list | `[]` | Array of imagePullSecrets for vectorization hub |
| global.configuration.vhub.postgreSQLCertSecret | string | `""` | postgres certificate secret name (replaces awsCertSecret) |
| image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager"},"tag":"1.5.0-20250923.1758633906615"}` | Container image configuration for API and related services |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for API container |
| image.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager"}` | Container image configuration for API |
| image.repo.base | string | `"cr.sas.com"` | Container registry base URL |
| image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager"` | Container image path/name for API Image |
| image.tag | string | `"1.5.0-20250923.1758633906615"` | API container image tag |
| imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to API |
| ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization,X-Auth-Request-Access-Token"` | Headers to pass from auth response to backend |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| ingress.className | string | `"nginx"` | Class name of the Ingress |
| ingress.enabled | bool | `true` | Enable ingress for external access to API |
| ingress.hosts | list | `[]` | Hosts configuration (ignored if useGlobal is true) |
| ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Hosts configuration (ignored if useGlobal is true) |
| ingress.tls | list | `[]` | TLS configuration for ingress |
| ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| livenessProbe | object | `{"failureThreshold":15,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for API |
| livenessProbe.failureThreshold | int | `15` | Number of consecutive failures required to mark container as not ready |
| livenessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"}` | HTTP GET probe configuration for liveness |
| livenessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/liveness"` | Path to probe for liveness |
| livenessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| nameOverride | string | `"api"` | String to partially override the fullname template with a string (will prepend the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| podSecurityContext | object | `{"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| podSecurityContext.fsGroup | int | `1001` | Group ID for file system ownership |
| podSecurityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| podSecurityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for API |
| readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| readinessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"}` | HTTP GET probe configuration for readiness |
| readinessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/readiness"` | Path to probe for readiness |
| readinessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| resources | object | `{"limits":{"cpu":6,"memory":"35Gi"},"requests":{"cpu":"500m","memory":"20Gi"}}` | The resources to allocate for the API container |
| resources.limits | object | `{"cpu":6,"memory":"35Gi"}` | Resource limits for the container |
| resources.limits.cpu | int | `6` | CPU limit |
| resources.limits.memory | string | `"35Gi"` | Memory limit |
| resources.requests | object | `{"cpu":"500m","memory":"20Gi"}` | Resource requests for the container |
| resources.requests.cpu | string | `"500m"` | CPU request |
| resources.requests.memory | string | `"20Gi"` | Memory request |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| securityContext.privileged | bool | `false` | Run as non-privileged container |
| securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| securityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| securityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| service.port | int | `80` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for API |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| volumes | list | `[]` | Additional volumes on the output Deployment definition |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
