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

| Repository | Name | Version |
|------------|------|---------|
| file://../filebrowser | filebrowser | 1.0.0 |
| file://../gpg | gpg | 1.1.0 |
| file://../keycloak | keycloak | 1.1.0 |
| file://../postgrest | postgrest | 1.1.0 |
| file://../sas-retrieval-agent-manager-api | sas-retrieval-agent-manager-api | 1.1.0 |
| file://../sas-retrieval-agent-manager-app | sas-retrieval-agent-manager-app | 1.1.0 |
| file://../sas-retrieval-agent-manager-db-init | sas-retrieval-agent-manager-db-init | 1.1.0 |
| file://../sas-retrieval-agent-manager-db-migration | sas-retrieval-agent-manager-db-migration | 1.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraObjects | list | `[]` | Allows deployment of additional secrets, configmaps, or custom resources |
| filebrowser | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"config":{"address":"","baseURL":"/files","database":"/db/filebrowser.db","log":"stdout","port":18080,"root":"/mnt/data"},"db":{"pvc":{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"256Mi","storageClassName":""}},"enabled":false,"fullnameOverride":"sas-retrieval-agent-manager-filebrowser","image":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"filebrowser/filebrowser"}},"imagePullSecrets":[],"ingress":{"annotations":{"nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"paths":[{"path":"/SASRetrievalAgentManager/files(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"initContainers":[],"livenessProbe":{},"nameOverride":"filebrowser","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"readinessProbe":{"httpGet":{"path":"/health","port":"http"}},"replicaCount":1,"rootDir":{"hostPath":{"path":"/mnt/data"},"pvc":{"accessModes":["ReadWriteOnce"],"createStorageClass":true,"name":"vhub-pv","size":"20Gi","storageClassName":"azurefile-sas"},"readOnly":false,"type":"pvc"},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"strategy":{"type":"Recreate"},"tolerations":[]}` | Provides a secure web UI for browsing, uploading, and managing files |
| filebrowser.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| filebrowser.config | object | `{"address":"","baseURL":"/files","database":"/db/filebrowser.db","log":"stdout","port":18080,"root":"/mnt/data"}` | File Browser application specific configuration |
| filebrowser.config.address | string | `""` | Address to bind the server to (empty means all interfaces) |
| filebrowser.config.baseURL | string | `"/files"` | Base URL path for the filebrowser application |
| filebrowser.config.database | string | `"/db/filebrowser.db"` | Path to the SQLite database file for storing filebrowser configuration |
| filebrowser.config.log | string | `"stdout"` | Log output destination (stdout, stderr, or file path) |
| filebrowser.config.port | int | `18080` | Port on which the filebrowser application listens inside the container |
| filebrowser.config.root | string | `"/mnt/data"` | Root directory that filebrowser will serve and manage files from |
| filebrowser.db | object | `{"pvc":{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"256Mi","storageClassName":""}}` | Database configuration for Filebrowser |
| filebrowser.db.pvc | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"256Mi","storageClassName":""}` | Database persistence configuration |
| filebrowser.db.pvc.accessModes | list | `["ReadWriteOnce"]` | Access modes for the database PVC |
| filebrowser.db.pvc.enabled | bool | `true` | Enable persistence for database |
| filebrowser.db.pvc.size | string | `"256Mi"` | Size for the database PVC |
| filebrowser.db.pvc.storageClassName | string | `""` | Storage class name for the database PVC |
| filebrowser.enabled | bool | `false` | Enable the actual filebrowser deployment. Set to true to deploy the filebrowser component |
| filebrowser.fullnameOverride | string | `"sas-retrieval-agent-manager-filebrowser"` | String to fully override the fullname template with a string |
| filebrowser.image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"filebrowser/filebrowser"}}` | Container image configuration for Filebrowser and related services |
| filebrowser.image.pullPolicy | string | `"IfNotPresent"` | Container image pull policy |
| filebrowser.image.repo | object | `{"base":"docker.io","path":"filebrowser/filebrowser"}` | Container image configuration |
| filebrowser.image.repo.base | string | `"docker.io"` | Container registry base URL |
| filebrowser.image.repo.path | string | `"filebrowser/filebrowser"` | Container image path/name |
| filebrowser.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images |
| filebrowser.ingress | object | `{"annotations":{"nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"paths":[{"path":"/SASRetrievalAgentManager/files(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to Filebrowser |
| filebrowser.ingress.annotations | object | `{"nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body (for file uploads) |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response received from proxied server |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| filebrowser.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| filebrowser.ingress.className | string | `"nginx"` | Class name of the Ingress |
| filebrowser.ingress.enabled | bool | `true` | Enable ingress for external access to API |
| filebrowser.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/files(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Ingress path configuration when useGlobal is true |
| filebrowser.ingress.tls | list | `[]` | TLS configuration for ingress |
| filebrowser.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| filebrowser.initContainers | list | `[]` | Set of initContainers for the deployment |
| filebrowser.livenessProbe | object | `{}` | Liveness probe configuration (disabled by default, enable if needed) |
| filebrowser.nameOverride | string | `"filebrowser"` | String to partially override the fullname template with a string (will prepend the release name) |
| filebrowser.nodeSelector | object | `{}` | Node labels for pod assignment |
| filebrowser.podAnnotations | object | `{}` | Annotations to add to the pods |
| filebrowser.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| filebrowser.readinessProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Readiness probe configuration |
| filebrowser.replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| filebrowser.rootDir.hostPath | object | `{"path":"/mnt/data"}` | Host path configuration (only used when type is 'hostPath') |
| filebrowser.rootDir.hostPath.path | string | `"/mnt/data"` | Path on the host to mount |
| filebrowser.rootDir.pvc | object | `{"accessModes":["ReadWriteOnce"],"createStorageClass":true,"name":"vhub-pv","size":"20Gi","storageClassName":"azurefile-sas"}` | Persistent Volume Claim configuration (only used when type is 'pvc') |
| filebrowser.rootDir.pvc.accessModes | list | `["ReadWriteOnce"]` | Access modes for the root directory PVC |
| filebrowser.rootDir.pvc.createStorageClass | bool | `true` | Whether to create the storage class if it doesn't exist |
| filebrowser.rootDir.pvc.name | string | `"vhub-pv"` | Name for the PVC |
| filebrowser.rootDir.pvc.size | string | `"20Gi"` | Size for the root directory PVC |
| filebrowser.rootDir.pvc.storageClassName | string | `"azurefile-sas"` | Storage class name for the root directory PVC |
| filebrowser.rootDir.readOnly | bool | `false` | Mount the root directory in read-only mode |
| filebrowser.rootDir.type | string | `"pvc"` | Type of rootDir mount. Valid values are [pvc, hostPath, emptyDir] |
| filebrowser.service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| filebrowser.service.port | int | `80` | Kubernetes Service port |
| filebrowser.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| filebrowser.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration for API |
| filebrowser.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| filebrowser.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| filebrowser.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| filebrowser.strategy | object | `{"type":"Recreate"}` | Deployment strategy to use (Recreate is recommended for stateful applications) |
| filebrowser.tolerations | list | `[]` | Tolerations for pod assignment |
| fullnameOverride | string | `"sas-retrieval-agent-manager"` | This becomes the prefix for all Kubernetes resource names |
| global | object | `{"configuration":{"api":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"},"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"database":{"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"},"eval":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"}}},"gpg":{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","passphrase_path":"/mnt/config/gpg_passphrase","privateKey":"","private_key_path":"/mnt/config/gpg_key","publicKey":""},"keycloak":{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","password":"","proxy":"edge","realm":"sas-iot","schema":"keycloak","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","user":"sas_keycloak_user","userRole":"sas-iot-user"},"kueue":{"cpuQuota":"32","memoryQuota":"128Gi","podQuota":6},"migration":{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"},"plugin":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"}}},"postgrest":{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000},"swagger":{"enabled":false},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"},"vectorizationJob":{"password":"","user":"sas_ram_vectorization_user"},"vhub":{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"}},"imagePullSecrets":[]},"weaviate":{"enabled":false}},"domain":"","image":{"repo":{"base":""}},"imagePullSecrets":[],"ingress":{"className":"nginx","enabled":true,"secretname":"","tls":{"enabled":true}}}` | Sub-charts with useGlobal=true inherit these values |
| global.configuration | object | `{"api":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"},"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"database":{"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"},"eval":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"}}},"gpg":{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","passphrase_path":"/mnt/config/gpg_passphrase","privateKey":"","private_key_path":"/mnt/config/gpg_key","publicKey":""},"keycloak":{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","password":"","proxy":"edge","realm":"sas-iot","schema":"keycloak","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","user":"sas_keycloak_user","userRole":"sas-iot-user"},"kueue":{"cpuQuota":"32","memoryQuota":"128Gi","podQuota":6},"migration":{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"},"plugin":{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"}}},"postgrest":{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000},"swagger":{"enabled":false},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"},"vectorizationJob":{"password":"","user":"sas_ram_vectorization_user"},"vhub":{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"}},"imagePullSecrets":[]},"weaviate":{"enabled":false}}` | Configuration settings |
| global.configuration.api | object | `{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"}` | Controls the core RAM backend service behavior |
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
| global.configuration.eval | object | `{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"}}}` | Evaluation service configuration |
| global.configuration.eval.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"}}` | Container image configuration for evaluation service |
| global.configuration.eval.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for evaluation service |
| global.configuration.eval.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-evaluation"` | Container image path/name for evaluation service |
| global.configuration.gpg | object | `{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","passphrase_path":"/mnt/config/gpg_passphrase","privateKey":"","private_key_path":"/mnt/config/gpg_key","publicKey":""}` | Controls encryption/decryption operations for secure data handling |
| global.configuration.gpg.key | object | `{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"}` | Key generation settings (used when publicKey and privateKey are not provided) |
| global.configuration.gpg.key.comment | string | `"RAM GPG Key"` | Comment for the generated GPG key |
| global.configuration.gpg.key.email | string | `"ram@sas.com"` | Email address associated with the generated GPG key |
| global.configuration.gpg.key.expire | string | `"0"` | Key expiration time (0 means never expires) |
| global.configuration.gpg.key.length | int | `4096` | Key length in bits for RSA keys |
| global.configuration.gpg.key.name | string | `"RAM Secrets"` | Name associated with the generated GPG key |
| global.configuration.gpg.passphrase | string | `""` | Passphrase for the GPG key. Required for both existing keys and key generation |
| global.configuration.gpg.passphrase_path | string | `"/mnt/config/gpg_passphrase"` | Path to GPG passphrase secret mount |
| global.configuration.gpg.privateKey | string | `""` | Existing GPG private key (base64 encoded). Leave empty to generate a new key pair |
| global.configuration.gpg.private_key_path | string | `"/mnt/config/gpg_key"` | Path to GPG private key secret mount |
| global.configuration.gpg.publicKey | string | `""` | Existing GPG public key (base64 encoded). Leave empty to generate a new key pair |
| global.configuration.keycloak | object | `{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","password":"","proxy":"edge","realm":"sas-iot","schema":"keycloak","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","user":"sas_keycloak_user","userRole":"sas-iot-user"}` | Defines authentication server settings and user management |
| global.configuration.keycloak.adminRole | string | `"sas-iot-admin"` | Admin role name in Keycloak |
| global.configuration.keycloak.appAdmin | string | `"AppAdmin"` | Application admin username |
| global.configuration.keycloak.appAdminPassword | string | `""` | Application admin password |
| global.configuration.keycloak.clientId | string | `"sas-ram-app"` | OAuth2 client ID for the application |
| global.configuration.keycloak.clientSecret | string | `""` | OAuth2 client secret for the application |
| global.configuration.keycloak.createDB | bool | `true` | Whether to create Keycloak database |
| global.configuration.keycloak.createSchema | bool | `true` | Whether to create Keycloak schema |
| global.configuration.keycloak.createUser | bool | `true` | Whether to create Keycloak user |
| global.configuration.keycloak.db | string | `"SASRetrievalAgentManagerIAM"` | Keycloak database name |
| global.configuration.keycloak.keycloakAdmin | string | `"kcAdmin"` | Keycloak admin username |
| global.configuration.keycloak.keycloakAdminPassword | string | `""` | Keycloak admin password |
| global.configuration.keycloak.password | string | `""` | Keycloak database user password |
| global.configuration.keycloak.proxy | string | `"edge"` | Proxy mode configuration (edge, reencrypt, or passthrough) |
| global.configuration.keycloak.realm | string | `"sas-iot"` | Keycloak realm name for the application |
| global.configuration.keycloak.schema | string | `"keycloak"` | Keycloak schema name |
| global.configuration.keycloak.secret_path | string | `"/mnt/config/keycloak"` | Path to Keycloak configuration secret mount |
| global.configuration.keycloak.serviceaccountsEnabled | bool | `false` | Whether service accounts are enabled in Keycloak |
| global.configuration.keycloak.strictHostname | bool | `true` | Whether to enforce strict hostname checking |
| global.configuration.keycloak.theme | string | `"sasblue"` | Keycloak theme to use |
| global.configuration.keycloak.user | string | `"sas_keycloak_user"` | Keycloak database user name |
| global.configuration.keycloak.userRole | string | `"sas-iot-user"` | User role name in Keycloak |
| global.configuration.kueue | object | `{"cpuQuota":"32","memoryQuota":"128Gi","podQuota":6}` | Kueue configuration |
| global.configuration.kueue.cpuQuota | string | `"32"` | Kueue CPU quota |
| global.configuration.kueue.memoryQuota | string | `"128Gi"` | Kueue memory quota |
| global.configuration.kueue.podQuota | int | `6` | Kueue pod quota |
| global.configuration.migration | object | `{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"}` | Controls database schema migration operations using Goose migration tool |
| global.configuration.migration.createUser | bool | `true` | Whether to create migration user |
| global.configuration.migration.dbMigrationPassword | string | `""` | Database migration user password (should be provided via secret) |
| global.configuration.migration.dbMigrationUser | string | `"sas_iot_migration"` | Database migration user name |
| global.configuration.plugin | object | `{"image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"}}}` | Plugin agent configuration |
| global.configuration.plugin.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"}}` | Container image configuration for plugin agent |
| global.configuration.plugin.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for plugin agent |
| global.configuration.plugin.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-agent"` | Container image path/name for plugin agent |
| global.configuration.postgrest | object | `{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000}` | Controls REST API generation from PostgreSQL database |
| global.configuration.postgrest.admin-server-port | int | `3001` | Port for PostgREST admin server |
| global.configuration.postgrest.jwt-role-claim-key | string | `".resource_access.\"sas-ram-app\".roles[0]"` | JWT role claim key configuration (uses value from keycloak.clientId) |
| global.configuration.postgrest.log-level | string | `"info"` | Log level for PostgREST (info, warn, etc.) |
| global.configuration.postgrest.openapi-mode | string | `"follow-privileges"` | OpenAPI mode configuration |
| global.configuration.postgrest.openapi-security-active | bool | `true` | Whether OpenAPI security is active |
| global.configuration.postgrest.server-port | int | `3000` | Port for PostgREST main server |
| global.configuration.swagger | object | `{"enabled":false}` | Controls API documentation generation and access |
| global.configuration.swagger.enabled | bool | `false` | Enable Swagger UI for API documentation |
| global.configuration.vectorStore | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"}` | Controls vector database setup for AI/ML embeddings and similarity search |
| global.configuration.vectorStore.createDB | bool | `true` | Whether to create vector store database |
| global.configuration.vectorStore.createSchema | bool | `true` | Whether to create vector store schema |
| global.configuration.vectorStore.createUser | bool | `true` | Whether to create vector store user |
| global.configuration.vectorStore.db | string | `"SASRetrievalAgentManagerVector"` | Vector store database name |
| global.configuration.vectorStore.enabled | bool | `true` | Whether vector store is enabled |
| global.configuration.vectorStore.password | string | `""` | Vector store database user password |
| global.configuration.vectorStore.schema | string | `"vectorstore"` | Vector store schema name |
| global.configuration.vectorStore.user | string | `"vector_store_user"` | Vector store database user name |
| global.configuration.vectorizationJob | object | `{"password":"","user":"sas_ram_vectorization_user"}` | Controls user authentication for vectorization processing jobs |
| global.configuration.vectorizationJob.password | string | `""` | Vectorization job user password |
| global.configuration.vectorizationJob.user | string | `"sas_ram_vectorization_user"` | Vectorization job user name |
| global.configuration.vhub | object | `{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"awsCertSecret":"","image":{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"}},"imagePullSecrets":[]}` | Vectorization Hub (VHub) configuration |
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
| global.configuration.vhub.image | object | `{"repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"}}` | Container image configuration for vectorization hub |
| global.configuration.vhub.image.repo.base | string | `"cr.sas.com"` | Container registry base URL for vectorization hub |
| global.configuration.vhub.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-vectorization-hub"` | Container image path/name for vectorization hub |
| global.configuration.vhub.imagePullSecrets | list | `[]` | Array of imagePullSecrets for vectorization hub |
| global.configuration.weaviate | object | `{"enabled":false}` | weaviate settings |
| global.configuration.weaviate.enabled | bool | `false` | Enable hydration for local Weaviate installation |
| global.domain | string | `""` | If not set, each chart uses its own host configuration |
| global.image | object | `{"repo":{"base":""}}` | When image.repo.base has content, subchart images are pulled from this base repository |
| global.image.repo | object | `{"base":""}` | Image repository details (useful for private registries) |
| global.image.repo.base | string | `""` | Base container registry URL (SAS Container Registry) |
| global.imagePullSecrets | list | `[]` | Applied to all sub-charts that reference private registries |
| global.ingress | object | `{"className":"nginx","enabled":true,"secretname":"","tls":{"enabled":true}}` | Provides consistent external access patterns across all services |
| global.ingress.className | string | `"nginx"` | Ingress controller class |
| global.ingress.enabled | bool | `true` | Enable ingress resources globally |
| global.ingress.secretname | string | `""` | Name of TLS secret |
| global.ingress.tls.enabled | bool | `true` | Enable TLS/SSL termination |
| gpg | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"fullnameOverride":"sas-retrieval-agent-manager-gpg","image":{"gpg":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"vladgh/gpg"}},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}}},"imagePullSecrets":[],"nameOverride":"gpg","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[]}` | Provides GPG encryption/decryption capabilities for secure data handling |
| gpg.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| gpg.fullnameOverride | string | `"sas-retrieval-agent-manager-gpg"` | String to fully override the fullname template with a string |
| gpg.image | object | `{"gpg":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"vladgh/gpg"}},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}}}` | Container image configuration for GPG and kubectl containers |
| gpg.image.gpg | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"vladgh/gpg"}}` | Container image configuration for GPG |
| gpg.image.gpg.pullPolicy | string | `"IfNotPresent"` | Image pull policy for GPG container |
| gpg.image.gpg.repo | object | `{"base":"docker.io","path":"vladgh/gpg"}` | Container image configuration for GPG |
| gpg.image.gpg.repo.base | string | `"docker.io"` | Container registry base URL for GPG image |
| gpg.image.gpg.repo.path | string | `"vladgh/gpg"` | Container image path/name for GPG |
| gpg.image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}}` | kubectl container image configuration (used for Kubernetes operations) |
| gpg.image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| gpg.image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl |
| gpg.image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl image |
| gpg.image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| gpg.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| gpg.nameOverride | string | `"gpg"` | String to partially override the fullname template with a string (will prepend the release name) |
| gpg.nodeSelector | object | `{}` | Node labels for pod assignment |
| gpg.podAnnotations | object | `{}` | Annotations to add to the pods |
| gpg.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| gpg.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| gpg.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| gpg.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| gpg.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| gpg.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| gpg.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| gpg.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the container |
| gpg.resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| gpg.resources.limits.cpu | string | `"200m"` | CPU limit |
| gpg.resources.limits.memory | string | `"256Mi"` | Memory limit |
| gpg.resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| gpg.resources.requests.cpu | string | `"100m"` | CPU request |
| gpg.resources.requests.memory | string | `"128Mi"` | Memory request |
| gpg.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| gpg.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| gpg.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| gpg.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| gpg.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| gpg.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| gpg.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| gpg.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| gpg.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for GPG operations |
| gpg.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| gpg.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| gpg.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| gpg.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| gpg.tolerations | list | `[]` | Tolerations for pod assignment |
| keycloak | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-keycloak","image":{"keycloak":{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"}},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}},"theme":{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}}},"imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"admin":{"enabled":true,"host":"","path":"/SASRetrievalAgentManager/auth/admin","pathType":"Prefix","sourceRange":[]},"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/auth(/(realms|resources)/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30},"mail":{"config":{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}},"container":{"postfix":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}},"enabled":false,"fullnameOverride":"mail","persistence":{"enabled":false},"pod":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}},"nameOverride":"keycloak","nodeSelector":{},"oauthProxy":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-oauth2-proxy","image":{"pullPolicy":"Always","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"},"imagePullSecrets":[{"name":"acr-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"logoutPaths":[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}],"paths":[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/ping","port":"http"}},"nameOverride":"oauth2-proxy","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/ping","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":4180,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"},"tolerations":[],"volumeMounts":[],"volumes":[]},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30},"replicaCount":1,"resources":{"limits":{"cpu":"500m","memory":"768Mi"},"requests":{"cpu":"50m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Provides authentication, authorization, and user management |
| keycloak.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| keycloak.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| keycloak.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| keycloak.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| keycloak.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| keycloak.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| keycloak.fullnameOverride | string | `"sas-retrieval-agent-manager-keycloak"` | String to fully override the fullname template with a string |
| keycloak.image | object | `{"keycloak":{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"}},"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}},"theme":{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}}}` | Container image configuration for Keycloak and related services |
| keycloak.image.keycloak | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"quay.io","path":"keycloak/keycloak"}}` | Container image configuration for Keycloak |
| keycloak.image.keycloak.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Keycloak container |
| keycloak.image.keycloak.repo | object | `{"base":"quay.io","path":"keycloak/keycloak"}` | Container image configuration for Keycloak |
| keycloak.image.keycloak.repo.base | string | `"quay.io"` | Container registry base URL for Keycloak |
| keycloak.image.keycloak.repo.path | string | `"keycloak/keycloak"` | Container image path/name for Keycloak |
| keycloak.image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}}` | kubectl container image configuration (used for Kubernetes operations) |
| keycloak.image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| keycloak.image.kubectl.repo | object | `{"base":"docker.io","path":"alpine/k8s"}` | Container image configuration for kubectl container |
| keycloak.image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl |
| keycloak.image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| keycloak.image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}}` | PostgreSQL database container image configuration |
| keycloak.image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| keycloak.image.postgres.repo | object | `{"base":"docker.io","path":"postgres"}` | Container image configuration for Postgres |
| keycloak.image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| keycloak.image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| keycloak.image.theme | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}}` | Custom theme container image configuration |
| keycloak.image.theme.pullPolicy | string | `"IfNotPresent"` | Image pull policy for theme container |
| keycloak.image.theme.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"}` | Container image configuration for the SAS Keycloak theme |
| keycloak.image.theme.repo.base | string | `"cr.sas.com"` | Container registry base URL for theme |
| keycloak.image.theme.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-iot-keycloak-theme"` | Container image path/name for theme |
| keycloak.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| keycloak.ingress | object | `{"admin":{"enabled":true,"host":"","path":"/SASRetrievalAgentManager/auth/admin","pathType":"Prefix","sourceRange":[]},"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/auth(/(realms|resources)/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to Keycloak |
| keycloak.ingress.admin | object | `{"enabled":true,"host":"","path":"/SASRetrievalAgentManager/auth/admin","pathType":"Prefix","sourceRange":[]}` | Admin interface ingress configuration |
| keycloak.ingress.admin.enabled | bool | `true` | Enable admin interface access via ingress. If false, admin console is only accessible via port forwarding |
| keycloak.ingress.admin.host | string | `""` | Admin interface host (ignored if useGlobal is true) |
| keycloak.ingress.admin.path | string | `"/SASRetrievalAgentManager/auth/admin"` | Admin interface path |
| keycloak.ingress.admin.pathType | string | `"Prefix"` | Admin interface path type |
| keycloak.ingress.admin.sourceRange | list | `[]` | IP addresses or CIDR blocks allowed to access admin interface. Empty means allow all |
| keycloak.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| keycloak.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| keycloak.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response received from proxied server |
| keycloak.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| keycloak.ingress.className | string | `"nginx"` | Class name of the Ingress |
| keycloak.ingress.enabled | bool | `true` | Enable ingress for external access to Keycloak |
| keycloak.ingress.hosts | list | `[]` | Hosts configuration (ignored if useGlobal is true) |
| keycloak.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/auth(/(realms|resources)/(.*))$","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| keycloak.ingress.tls | list | `[]` | TLS configuration for ingress |
| keycloak.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| keycloak.livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30}` | Liveness probe configuration for Keycloak |
| keycloak.livenessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| keycloak.livenessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"}` | HTTP GET probe configuration |
| keycloak.livenessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/auth/realms/master"` | Path to probe for liveness |
| keycloak.livenessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| keycloak.livenessProbe.periodSeconds | int | `30` | How often to perform the probe |
| keycloak.mail | object | `{"config":{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}},"container":{"postfix":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}},"enabled":false,"fullnameOverride":"mail","persistence":{"enabled":false},"pod":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}}` | Mail server configuration (optional email service for development) |
| keycloak.mail.config | object | `{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}}` | Mail server configuration settings |
| keycloak.mail.config.general | object | `{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"}` | General mail server settings |
| keycloak.mail.config.general.ALLOW_EMPTY_SENDER_DOMAINS | string | `"true"` | Allow empty sender domains |
| keycloak.mail.config.general.TZ | string | `"UTC"` | Timezone for mail server |
| keycloak.mail.config.postfix | object | `{"myhostname":"","mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}` | Postfix-specific configuration |
| keycloak.mail.config.postfix.myhostname | string | `""` | Mail server hostname |
| keycloak.mail.config.postfix.mynetworks | string | `"10.0.0.0/8, 127.0.0.0/8"` | Trusted networks for mail relay |
| keycloak.mail.config.postfix.smtpd_recipient_restrictions | string | `"permit_mynetworks, reject_unauth_destination"` | SMTP recipient restrictions |
| keycloak.mail.container | object | `{"postfix":{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}}` | Container configuration for mail server |
| keycloak.mail.container.postfix | object | `{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}` | Postfix container configuration |
| keycloak.mail.container.postfix.securityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for postfix container |
| keycloak.mail.container.postfix.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for postfix container |
| keycloak.mail.enabled | bool | `false` | Enable mail server deployment |
| keycloak.mail.fullnameOverride | string | `"mail"` | Full name override for mail service |
| keycloak.mail.persistence | object | `{"enabled":false}` | Persistence configuration for mail server |
| keycloak.mail.persistence.enabled | bool | `false` | Enable persistence for mail server |
| keycloak.mail.pod | object | `{"securityContext":{"seccompProfile":{"type":"RuntimeDefault"}}}` | Pod configuration for mail server |
| keycloak.mail.pod.securityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for mail server pod |
| keycloak.mail.pod.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for mail server pod |
| keycloak.nameOverride | string | `"keycloak"` | String to partially override the fullname template with a string (will prepend the release name) |
| keycloak.nodeSelector | object | `{}` | Node labels for pod assignment |
| keycloak.oauthProxy | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-oauth2-proxy","image":{"pullPolicy":"Always","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"},"imagePullSecrets":[{"name":"acr-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"logoutPaths":[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}],"paths":[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/ping","port":"http"}},"nameOverride":"oauth2-proxy","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/ping","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":4180,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"},"tolerations":[],"volumeMounts":[],"volumes":[]}` | OAuth2 Proxy configuration for authentication |
| keycloak.oauthProxy.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities for OAuth2 Proxy |
| keycloak.oauthProxy.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration for OAuth2 Proxy |
| keycloak.oauthProxy.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling for OAuth2 Proxy |
| keycloak.oauthProxy.autoscaling.maxReplicas | int | `100` | Maximum number of replicas for OAuth2 Proxy |
| keycloak.oauthProxy.autoscaling.minReplicas | int | `1` | Minimum number of replicas for OAuth2 Proxy |
| keycloak.oauthProxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for OAuth2 Proxy scaling |
| keycloak.oauthProxy.fullnameOverride | string | `"sas-retrieval-agent-manager-oauth2-proxy"` | String to fully override the OAuth2 Proxy fullname template |
| keycloak.oauthProxy.image | object | `{"pullPolicy":"Always","repo":{"base":"quay.io","path":"oauth2-proxy/oauth2-proxy"},"tag":"v7.12.0"}` | OAuth2 Proxy container image configuration |
| keycloak.oauthProxy.image.pullPolicy | string | `"Always"` | Image pull policy for OAuth2 Proxy container |
| keycloak.oauthProxy.image.repo.base | string | `"quay.io"` | Container registry base URL for OAuth2 Proxy |
| keycloak.oauthProxy.image.repo.path | string | `"oauth2-proxy/oauth2-proxy"` | Container image path/name for OAuth2 Proxy |
| keycloak.oauthProxy.image.tag | string | `"v7.12.0"` | OAuth2 Proxy container image tag |
| keycloak.oauthProxy.imagePullSecrets | list | `[{"name":"acr-secret"}]` | Array of imagePullSecrets for OAuth2 Proxy |
| keycloak.oauthProxy.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"logoutPaths":[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}],"paths":[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | OAuth2 Proxy ingress configuration |
| keycloak.oauthProxy.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","nginx.ingress.kubernetes.io/enable-cors":"true","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/session-cookie-samesite":"lax","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the OAuth2 Proxy Ingress |
| keycloak.oauthProxy.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| keycloak.oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` | Enable CORS for OAuth2 Proxy |
| keycloak.oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| keycloak.oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/session-cookie-samesite" | string | `"lax"` | Session cookie SameSite attribute |
| keycloak.oauthProxy.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| keycloak.oauthProxy.ingress.className | string | `"nginx"` | Class name of the OAuth2 Proxy Ingress |
| keycloak.oauthProxy.ingress.enabled | bool | `true` | Enable ingress for OAuth2 Proxy |
| keycloak.oauthProxy.ingress.hosts | list | `[]` | Hosts configuration for OAuth2 Proxy (ignored if useGlobal is true) |
| keycloak.oauthProxy.ingress.logoutPaths | list | `[{"path":"/SASRetrievalAgentManager/logout(/(.*))?$","pathType":"ImplementationSpecific"}]` | OAuth2 logout paths |
| keycloak.oauthProxy.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/oauth2(/|/(.*))$","pathType":"ImplementationSpecific"}]` | OAuth2 authentication paths |
| keycloak.oauthProxy.ingress.tls | list | `[]` | TLS configuration for OAuth2 Proxy ingress |
| keycloak.oauthProxy.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts for OAuth2 Proxy |
| keycloak.oauthProxy.livenessProbe | object | `{"httpGet":{"path":"/ping","port":"http"}}` | Liveness probe configuration for OAuth2 Proxy |
| keycloak.oauthProxy.livenessProbe.httpGet | object | `{"path":"/ping","port":"http"}` | HTTP GET probe configuration for liveness |
| keycloak.oauthProxy.livenessProbe.httpGet.path | string | `"/ping"` | Path to probe for liveness |
| keycloak.oauthProxy.nameOverride | string | `"oauth2-proxy"` | String to partially override the OAuth2 Proxy fullname template |
| keycloak.oauthProxy.nodeSelector | object | `{}` | Node labels for OAuth2 Proxy pod assignment |
| keycloak.oauthProxy.podAnnotations | object | `{}` | Annotations to add to the OAuth2 Proxy pods |
| keycloak.oauthProxy.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the OAuth2 Proxy pods |
| keycloak.oauthProxy.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the OAuth2 Proxy pods |
| keycloak.oauthProxy.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| keycloak.oauthProxy.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| keycloak.oauthProxy.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| keycloak.oauthProxy.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| keycloak.oauthProxy.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the OAuth2 Proxy pod |
| keycloak.oauthProxy.readinessProbe | object | `{"httpGet":{"path":"/ping","port":"http"}}` | Readiness probe configuration for OAuth2 Proxy |
| keycloak.oauthProxy.readinessProbe.httpGet | object | `{"path":"/ping","port":"http"}` | HTTP GET probe configuration for readiness |
| keycloak.oauthProxy.readinessProbe.httpGet.path | string | `"/ping"` | Path to probe for readiness |
| keycloak.oauthProxy.replicaCount | int | `1` | Number of OAuth2 Proxy replicas |
| keycloak.oauthProxy.resources | object | `{"limits":{"cpu":"100m","memory":"64Mi"},"requests":{"cpu":"50m","memory":"32Mi"}}` | The resources to allocate for the OAuth2 Proxy container |
| keycloak.oauthProxy.resources.limits | object | `{"cpu":"100m","memory":"64Mi"}` | Resource limits for the OAuth2 Proxy container |
| keycloak.oauthProxy.resources.limits.cpu | string | `"100m"` | CPU limit |
| keycloak.oauthProxy.resources.limits.memory | string | `"64Mi"` | Memory limit |
| keycloak.oauthProxy.resources.requests | object | `{"cpu":"50m","memory":"32Mi"}` | Resource requests for the OAuth2 Proxy container |
| keycloak.oauthProxy.resources.requests.cpu | string | `"50m"` | CPU request |
| keycloak.oauthProxy.resources.requests.memory | string | `"32Mi"` | Memory request |
| keycloak.oauthProxy.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the OAuth2 Proxy application container |
| keycloak.oauthProxy.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| keycloak.oauthProxy.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the OAuth2 Proxy container |
| keycloak.oauthProxy.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| keycloak.oauthProxy.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| keycloak.oauthProxy.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| keycloak.oauthProxy.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| keycloak.oauthProxy.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the OAuth2 Proxy container |
| keycloak.oauthProxy.service | object | `{"port":4180,"type":"ClusterIP"}` | OAuth2 Proxy service configuration |
| keycloak.oauthProxy.service.port | int | `4180` | Kubernetes Service port for OAuth2 Proxy |
| keycloak.oauthProxy.service.type | string | `"ClusterIP"` | Kubernetes Service type for OAuth2 Proxy |
| keycloak.oauthProxy.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":"oauth2-proxy"}` | OAuth2 Proxy service account configuration |
| keycloak.oauthProxy.serviceAccount.annotations | object | `{}` | Annotations to add to the OAuth2 Proxy service account |
| keycloak.oauthProxy.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials for OAuth2 Proxy |
| keycloak.oauthProxy.serviceAccount.create | bool | `true` | Specifies whether a service account should be created for OAuth2 Proxy |
| keycloak.oauthProxy.serviceAccount.name | string | `"oauth2-proxy"` | The name of the service account to use for OAuth2 Proxy |
| keycloak.oauthProxy.tolerations | list | `[]` | Tolerations for OAuth2 Proxy pod assignment |
| keycloak.oauthProxy.volumeMounts | list | `[]` | Additional volumeMounts on the OAuth2 Proxy Deployment definition |
| keycloak.oauthProxy.volumes | list | `[]` | Additional volumes on the OAuth2 Proxy Deployment definition |
| keycloak.podAnnotations | object | `{}` | Annotations to add to the pods |
| keycloak.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| keycloak.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| keycloak.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| keycloak.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| keycloak.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| keycloak.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| keycloak.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| keycloak.readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"},"initialDelaySeconds":240,"periodSeconds":30}` | Readiness probe configuration for Keycloak |
| keycloak.readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| keycloak.readinessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/auth/realms/master","port":"http"}` | HTTP GET probe configuration |
| keycloak.readinessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/auth/realms/master"` | Path to probe for readiness |
| keycloak.readinessProbe.initialDelaySeconds | int | `240` | Initial delay before starting probes |
| keycloak.readinessProbe.periodSeconds | int | `30` | How often to perform the probe |
| keycloak.replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| keycloak.resources | object | `{"limits":{"cpu":"500m","memory":"768Mi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | The resources to allocate for the Keycloak container |
| keycloak.resources.limits | object | `{"cpu":"500m","memory":"768Mi"}` | Resource limits for the container |
| keycloak.resources.limits.cpu | string | `"500m"` | CPU limit |
| keycloak.resources.limits.memory | string | `"768Mi"` | Memory limit |
| keycloak.resources.requests | object | `{"cpu":"50m","memory":"256Mi"}` | Resource requests for the container |
| keycloak.resources.requests.cpu | string | `"50m"` | CPU request |
| keycloak.resources.requests.memory | string | `"256Mi"` | Memory request |
| keycloak.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| keycloak.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| keycloak.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| keycloak.securityContext.privileged | bool | `false` | Whether the container runs in privileged mode |
| keycloak.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| keycloak.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| keycloak.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| keycloak.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| keycloak.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| keycloak.service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| keycloak.service.port | int | `8080` | Kubernetes Service port |
| keycloak.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| keycloak.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for Keycloak |
| keycloak.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| keycloak.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| keycloak.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| keycloak.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| keycloak.tolerations | list | `[]` | Tolerations for pod assignment |
| keycloak.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| keycloak.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| postgrest | object | `{"adminService":{"port":3001,"type":"ClusterIP"},"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-postgrest","image":{"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}},"postgrest":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"}}},"imagePullSecrets":[],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[{"host":"chart-example.local","paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]}],"paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"failureThreshold":3,"httpGet":{"path":"/live","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"postgrest","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":3,"httpGet":{"path":"/ready","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"resources":{"limits":{"cpu":2,"memory":"1Gi"},"requests":{"cpu":"100m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":3000,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"swagger":{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":false,"fullnameOverride":"","image":{"pullPolicy":"IfNotPresent","repo":{"base":"swaggerapi","path":"swagger-ui"},"tag":"v5.17.14"},"imagePullSecrets":[],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/","port":"http"}},"nameOverride":"swagger","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"200m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Automatically generates REST endpoints from database schema |
| postgrest.adminService | object | `{"port":3001,"type":"ClusterIP"}` | Admin service configuration for PostgREST management |
| postgrest.adminService.port | int | `3001` | Kubernetes Service port for PostgREST admin interface |
| postgrest.adminService.type | string | `"ClusterIP"` | Kubernetes Service type for PostgREST admin interface |
| postgrest.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| postgrest.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| postgrest.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| postgrest.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| postgrest.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| postgrest.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| postgrest.fullnameOverride | string | `"sas-retrieval-agent-manager-postgrest"` | String to fully override the fullname template with a string |
| postgrest.image | object | `{"kubectl":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}},"postgres":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}},"postgrest":{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"}}}` | PostgREST container image configuration |
| postgrest.image.kubectl | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"alpine/k8s"}}` | kubectl container image configuration (used for Kubernetes operations) |
| postgrest.image.kubectl.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kubectl container |
| postgrest.image.kubectl.repo.base | string | `"docker.io"` | Container registry base URL for kubectl |
| postgrest.image.kubectl.repo.path | string | `"alpine/k8s"` | Container image path/name for kubectl |
| postgrest.image.postgres | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgres"}}` | PostgreSQL binary container image configuration |
| postgrest.image.postgres.pullPolicy | string | `"IfNotPresent"` | Image pull policy for PostgreSQL container |
| postgrest.image.postgres.repo.base | string | `"docker.io"` | Container registry base URL for PostgreSQL |
| postgrest.image.postgres.repo.path | string | `"postgres"` | Container image path/name for PostgreSQL |
| postgrest.image.postgrest | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"docker.io","path":"postgrest/postgrest"}}` | PostgREST main container image configuration |
| postgrest.image.postgrest.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| postgrest.image.postgrest.repo.base | string | `"docker.io"` | PostgREST registry |
| postgrest.image.postgrest.repo.path | string | `"postgrest/postgrest"` | Official PostgREST image |
| postgrest.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| postgrest.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[{"host":"chart-example.local","paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]}],"paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to PostgREST |
| postgrest.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| postgrest.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| postgrest.ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| postgrest.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| postgrest.ingress.className | string | `"nginx"` | Class name of the Ingress |
| postgrest.ingress.enabled | bool | `true` | Enable ingress for external access |
| postgrest.ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]}]` | Hosts configuration (used when useGlobal is false) |
| postgrest.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/postgrest(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| postgrest.ingress.tls | list | `[]` | TLS configuration for ingress |
| postgrest.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| postgrest.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/live","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for PostgREST |
| postgrest.livenessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| postgrest.livenessProbe.httpGet | object | `{"path":"/live","port":"admin","scheme":"HTTP"}` | HTTP GET probe configuration for liveness |
| postgrest.livenessProbe.httpGet.path | string | `"/live"` | Path to probe for liveness |
| postgrest.livenessProbe.httpGet.port | string | `"admin"` | Port to probe on |
| postgrest.livenessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme to use |
| postgrest.livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| postgrest.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| postgrest.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| postgrest.nameOverride | string | `"postgrest"` | String to partially override the fullname template with a string (will prepend the release name) |
| postgrest.nodeSelector | object | `{}` | Node labels for pod assignment |
| postgrest.podAnnotations | object | `{}` | Annotations to add to the pods |
| postgrest.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| postgrest.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| postgrest.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| postgrest.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| postgrest.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| postgrest.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| postgrest.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| postgrest.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/ready","port":"admin","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for PostgREST |
| postgrest.readinessProbe.failureThreshold | int | `3` | Number of consecutive failures required to mark container as not ready |
| postgrest.readinessProbe.httpGet | object | `{"path":"/ready","port":"admin","scheme":"HTTP"}` | HTTP GET probe configuration for readiness |
| postgrest.readinessProbe.httpGet.path | string | `"/ready"` | Path to probe for readiness |
| postgrest.readinessProbe.httpGet.port | string | `"admin"` | Port to probe on |
| postgrest.readinessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme to use |
| postgrest.readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| postgrest.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| postgrest.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| postgrest.replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| postgrest.resources | object | `{"limits":{"cpu":2,"memory":"1Gi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the PostgREST container |
| postgrest.resources.limits | object | `{"cpu":2,"memory":"1Gi"}` | Resource limits for the container |
| postgrest.resources.limits.cpu | int | `2` | CPU limit |
| postgrest.resources.limits.memory | string | `"1Gi"` | Memory limit |
| postgrest.resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| postgrest.resources.requests.cpu | string | `"100m"` | CPU request |
| postgrest.resources.requests.memory | string | `"128Mi"` | Memory request |
| postgrest.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| postgrest.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| postgrest.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| postgrest.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| postgrest.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| postgrest.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| postgrest.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| postgrest.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| postgrest.service | object | `{"port":3000,"type":"ClusterIP"}` | Kubernetes Service configuration |
| postgrest.service.port | int | `3000` | Kubernetes Service port |
| postgrest.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| postgrest.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| postgrest.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| postgrest.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| postgrest.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| postgrest.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| postgrest.swagger | object | `{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":false,"fullnameOverride":"","image":{"pullPolicy":"IfNotPresent","repo":{"base":"swaggerapi","path":"swagger-ui"},"tag":"v5.17.14"},"imagePullSecrets":[],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"httpGet":{"path":"/","port":"http"}},"nameOverride":"swagger","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"httpGet":{"path":"/","port":"http"}},"replicaCount":1,"resources":{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"200m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Swagger UI configuration for API documentation |
| postgrest.swagger.affinity | object | `{}` | Map of node/pod affinities for Swagger UI |
| postgrest.swagger.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration for Swagger UI |
| postgrest.swagger.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling for Swagger UI |
| postgrest.swagger.autoscaling.maxReplicas | int | `100` | Maximum number of replicas for Swagger UI |
| postgrest.swagger.autoscaling.minReplicas | int | `1` | Minimum number of replicas for Swagger UI |
| postgrest.swagger.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for Swagger UI scaling |
| postgrest.swagger.enabled | bool | `false` | Enable Swagger UI deployment |
| postgrest.swagger.fullnameOverride | string | `""` | String to fully override the Swagger UI fullname template |
| postgrest.swagger.image | object | `{"pullPolicy":"IfNotPresent","repo":{"base":"swaggerapi","path":"swagger-ui"},"tag":"v5.17.14"}` | Swagger UI container image configuration |
| postgrest.swagger.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for Swagger UI container |
| postgrest.swagger.image.repo | object | `{"base":"swaggerapi","path":"swagger-ui"}` | Container image configuration for Swagger |
| postgrest.swagger.image.repo.base | string | `"swaggerapi"` | Container registry base URL for Swagger UI |
| postgrest.swagger.image.repo.path | string | `"swagger-ui"` | Container image path/name for Swagger UI |
| postgrest.swagger.image.tag | string | `"v5.17.14"` | Swagger UI container image tag |
| postgrest.swagger.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| postgrest.swagger.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Swagger UI ingress configuration |
| postgrest.swagger.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/rewrite-target":"/$2","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Swagger UI Ingress |
| postgrest.swagger.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| postgrest.swagger.ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` | URL rewrite rule to strip the prefix path |
| postgrest.swagger.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| postgrest.swagger.ingress.className | string | `"nginx"` | Class name of the Ingress |
| postgrest.swagger.ingress.enabled | bool | `true` | Enable ingress for external access |
| postgrest.swagger.ingress.hosts | list | `[]` | Hosts configuration for Swagger UI (ignored if useGlobal is true) |
| postgrest.swagger.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/swagger(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Swagger UI paths configuration |
| postgrest.swagger.ingress.tls | list | `[]` | TLS configuration for Swagger UI ingress |
| postgrest.swagger.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| postgrest.swagger.livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Liveness probe configuration for Swagger UI |
| postgrest.swagger.livenessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for liveness |
| postgrest.swagger.livenessProbe.httpGet.path | string | `"/"` | Path to probe for liveness |
| postgrest.swagger.nameOverride | string | `"swagger"` | String to partially override the Swagger UI fullname template |
| postgrest.swagger.nodeSelector | object | `{}` | Node labels for pod assignment |
| postgrest.swagger.podAnnotations | object | `{}` | Annotations to add to the Swagger UI pods |
| postgrest.swagger.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| postgrest.swagger.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| postgrest.swagger.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| postgrest.swagger.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| postgrest.swagger.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| postgrest.swagger.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| postgrest.swagger.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| postgrest.swagger.readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Readiness probe configuration for Swagger UI |
| postgrest.swagger.readinessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for readiness |
| postgrest.swagger.readinessProbe.httpGet.path | string | `"/"` | Path to probe for readiness |
| postgrest.swagger.replicaCount | int | `1` | Number of Swagger UI replicas |
| postgrest.swagger.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"200m","memory":"256Mi"}}` | The resources to allocate for the Swagger UI container |
| postgrest.swagger.resources.limits | object | `{"cpu":"100m","memory":"128Mi"}` | Resource limits for the Swagger UI container |
| postgrest.swagger.resources.limits.cpu | string | `"100m"` | CPU limit |
| postgrest.swagger.resources.limits.memory | string | `"128Mi"` | Memory limit |
| postgrest.swagger.resources.requests | object | `{"cpu":"200m","memory":"256Mi"}` | Resource requests for the Swagger UI container |
| postgrest.swagger.resources.requests.cpu | string | `"200m"` | CPU request |
| postgrest.swagger.resources.requests.memory | string | `"256Mi"` | Memory request |
| postgrest.swagger.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| postgrest.swagger.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| postgrest.swagger.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| postgrest.swagger.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| postgrest.swagger.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| postgrest.swagger.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| postgrest.swagger.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| postgrest.swagger.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| postgrest.swagger.service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| postgrest.swagger.service.port | int | `80` | Kubernetes Service port |
| postgrest.swagger.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| postgrest.swagger.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| postgrest.swagger.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| postgrest.swagger.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| postgrest.swagger.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| postgrest.swagger.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| postgrest.swagger.tolerations | list | `[]` | Tolerations for pod assignment |
| postgrest.swagger.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| postgrest.swagger.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| postgrest.tolerations | list | `[]` | Tolerations for pod assignment |
| postgrest.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| postgrest.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| sas-retrieval-agent-manager-api | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-api","imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"failureThreshold":15,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"api","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"resources":{"limits":{"cpu":6,"memory":"35Gi"},"requests":{"cpu":"500m","memory":"20Gi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Provides REST API endpoints and AI/ML processing capabilities |
| sas-retrieval-agent-manager-api.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| sas-retrieval-agent-manager-api.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| sas-retrieval-agent-manager-api.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| sas-retrieval-agent-manager-api.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| sas-retrieval-agent-manager-api.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| sas-retrieval-agent-manager-api.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| sas-retrieval-agent-manager-api.fullnameOverride | string | `"sas-retrieval-agent-manager-api"` | String to fully override the fullname template with a string |
| sas-retrieval-agent-manager-api.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| sas-retrieval-agent-manager-api.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to API |
| sas-retrieval-agent-manager-api.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| sas-retrieval-agent-manager-api.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| sas-retrieval-agent-manager-api.ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization,X-Auth-Request-Access-Token"` | Headers to pass from auth response to backend |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| sas-retrieval-agent-manager-api.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| sas-retrieval-agent-manager-api.ingress.className | string | `"nginx"` | Class name of the Ingress |
| sas-retrieval-agent-manager-api.ingress.enabled | bool | `true` | Enable ingress for external access to API |
| sas-retrieval-agent-manager-api.ingress.hosts | list | `[]` | Hosts configuration (ignored if useGlobal is true) |
| sas-retrieval-agent-manager-api.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Hosts configuration (ignored if useGlobal is true) |
| sas-retrieval-agent-manager-api.ingress.tls | list | `[]` | TLS configuration for ingress |
| sas-retrieval-agent-manager-api.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| sas-retrieval-agent-manager-api.livenessProbe | object | `{"failureThreshold":15,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration for API |
| sas-retrieval-agent-manager-api.livenessProbe.failureThreshold | int | `15` | Number of consecutive failures required to mark container as not ready |
| sas-retrieval-agent-manager-api.livenessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"}` | HTTP GET probe configuration for liveness |
| sas-retrieval-agent-manager-api.livenessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/liveness"` | Path to probe for liveness |
| sas-retrieval-agent-manager-api.livenessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| sas-retrieval-agent-manager-api.livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| sas-retrieval-agent-manager-api.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| sas-retrieval-agent-manager-api.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| sas-retrieval-agent-manager-api.nameOverride | string | `"api"` | String to partially override the fullname template with a string (will prepend the release name) |
| sas-retrieval-agent-manager-api.nodeSelector | object | `{}` | Node labels for pod assignment |
| sas-retrieval-agent-manager-api.podAnnotations | object | `{}` | Annotations to add to the pods |
| sas-retrieval-agent-manager-api.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| sas-retrieval-agent-manager-api.podSecurityContext | object | `{"fsGroup":1001,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| sas-retrieval-agent-manager-api.podSecurityContext.fsGroup | int | `1001` | Group ID for file system ownership |
| sas-retrieval-agent-manager-api.podSecurityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-api.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| sas-retrieval-agent-manager-api.podSecurityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-api.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| sas-retrieval-agent-manager-api.readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration for API |
| sas-retrieval-agent-manager-api.readinessProbe.failureThreshold | int | `5` | Number of consecutive failures required to mark container as not ready |
| sas-retrieval-agent-manager-api.readinessProbe.httpGet | object | `{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"}` | HTTP GET probe configuration for readiness |
| sas-retrieval-agent-manager-api.readinessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/readiness"` | Path to probe for readiness |
| sas-retrieval-agent-manager-api.readinessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| sas-retrieval-agent-manager-api.readinessProbe.periodSeconds | int | `10` | How often to perform the probe |
| sas-retrieval-agent-manager-api.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| sas-retrieval-agent-manager-api.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| sas-retrieval-agent-manager-api.replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| sas-retrieval-agent-manager-api.resources | object | `{"limits":{"cpu":6,"memory":"35Gi"},"requests":{"cpu":"500m","memory":"20Gi"}}` | The resources to allocate for the API container |
| sas-retrieval-agent-manager-api.resources.limits | object | `{"cpu":6,"memory":"35Gi"}` | Resource limits for the container |
| sas-retrieval-agent-manager-api.resources.limits.cpu | int | `6` | CPU limit |
| sas-retrieval-agent-manager-api.resources.limits.memory | string | `"35Gi"` | Memory limit |
| sas-retrieval-agent-manager-api.resources.requests | object | `{"cpu":"500m","memory":"20Gi"}` | Resource requests for the container |
| sas-retrieval-agent-manager-api.resources.requests.cpu | string | `"500m"` | CPU request |
| sas-retrieval-agent-manager-api.resources.requests.memory | string | `"20Gi"` | Memory request |
| sas-retrieval-agent-manager-api.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| sas-retrieval-agent-manager-api.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| sas-retrieval-agent-manager-api.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| sas-retrieval-agent-manager-api.securityContext.privileged | bool | `false` | Run as non-privileged container |
| sas-retrieval-agent-manager-api.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| sas-retrieval-agent-manager-api.securityContext.runAsGroup | int | `1001` | Group ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-api.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| sas-retrieval-agent-manager-api.securityContext.runAsUser | int | `1001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-api.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| sas-retrieval-agent-manager-api.service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes Service configuration |
| sas-retrieval-agent-manager-api.service.port | int | `80` | Kubernetes Service port |
| sas-retrieval-agent-manager-api.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| sas-retrieval-agent-manager-api.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for API |
| sas-retrieval-agent-manager-api.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| sas-retrieval-agent-manager-api.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| sas-retrieval-agent-manager-api.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| sas-retrieval-agent-manager-api.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| sas-retrieval-agent-manager-api.tolerations | list | `[]` | Tolerations for pod assignment |
| sas-retrieval-agent-manager-api.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| sas-retrieval-agent-manager-api.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| sas-retrieval-agent-manager-app | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-app","image":{"pullPolicy":"IfNotPresent","repo":{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"}},"imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false},"livenessProbe":{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"app","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"readinessProbe":{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"resources":{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":"50m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Frontend user interface for the platform |
| sas-retrieval-agent-manager-app.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| sas-retrieval-agent-manager-app.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal Pod Autoscaler configuration |
| sas-retrieval-agent-manager-app.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| sas-retrieval-agent-manager-app.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| sas-retrieval-agent-manager-app.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| sas-retrieval-agent-manager-app.autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage for scaling |
| sas-retrieval-agent-manager-app.fullnameOverride | string | `"sas-retrieval-agent-manager-app"` | String to fully override the fullname template with a string |
| sas-retrieval-agent-manager-app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for API container |
| sas-retrieval-agent-manager-app.image.repo | object | `{"base":"cr.sas.com","path":"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"}` | Container image configuration for API |
| sas-retrieval-agent-manager-app.image.repo.base | string | `"cr.sas.com"` | Container registry base URL |
| sas-retrieval-agent-manager-app.image.repo.path | string | `"viya-4-x64_oci_linux_2-docker/sas-retrieval-agent-manager-app"` | Container image path/name |
| sas-retrieval-agent-manager-app.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| sas-retrieval-agent-manager-app.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":false}` | Ingress configuration for external access to the web application |
| sas-retrieval-agent-manager-app.ingress.annotations | object | `{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"}` | Annotations for the Ingress |
| sas-retrieval-agent-manager-app.ingress.annotations."kubernetes.io/ingress.allow-http" | string | `"false"` | Disallow HTTP traffic, force HTTPS only |
| sas-retrieval-agent-manager-app.ingress.annotations."kubernetes.io/tls-acme" | string | `"true"` | Enable TLS certificate management via cert-manager |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/auth-response-headers" | string | `"Authorization"` | Headers to pass from auth response to backend |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/auth-signin" | string | `"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri"` | OAuth2 authentication sign-in URL |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/auth-url" | string | `"https://$host/SASRetrievalAgentManager/oauth2/auth"` | OAuth2 authentication validation URL |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | Maximum allowed size of client request body |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/proxy-buffer-size" | string | `"16k"` | Size of buffer used for reading the first part of response |
| sas-retrieval-agent-manager-app.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"true"` | Force SSL redirect |
| sas-retrieval-agent-manager-app.ingress.className | string | `"nginx"` | Class name of the Ingress |
| sas-retrieval-agent-manager-app.ingress.enabled | bool | `true` | Enable ingress for external access |
| sas-retrieval-agent-manager-app.ingress.hosts | list | `[]` | Hosts configuration (used when useGlobal is false) |
| sas-retrieval-agent-manager-app.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| sas-retrieval-agent-manager-app.ingress.tls | list | `[]` | TLS configuration for ingress |
| sas-retrieval-agent-manager-app.ingress.useGlobal | bool | `false` | Use global ingress configuration instead of local hosts configuration |
| sas-retrieval-agent-manager-app.livenessProbe | object | `{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration |
| sas-retrieval-agent-manager-app.livenessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| sas-retrieval-agent-manager-app.livenessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for liveness |
| sas-retrieval-agent-manager-app.livenessProbe.httpGet.path | string | `"/"` | Path to probe for liveness |
| sas-retrieval-agent-manager-app.livenessProbe.periodSeconds | int | `15` | How often to perform the probe |
| sas-retrieval-agent-manager-app.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| sas-retrieval-agent-manager-app.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| sas-retrieval-agent-manager-app.nameOverride | string | `"app"` | String to partially override the fullname template with a string (will prepend the release name) |
| sas-retrieval-agent-manager-app.nodeSelector | object | `{}` | Node labels for pod assignment |
| sas-retrieval-agent-manager-app.podAnnotations | object | `{}` | Annotations to add to the pods |
| sas-retrieval-agent-manager-app.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| sas-retrieval-agent-manager-app.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| sas-retrieval-agent-manager-app.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| sas-retrieval-agent-manager-app.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-app.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| sas-retrieval-agent-manager-app.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-app.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| sas-retrieval-agent-manager-app.readinessProbe | object | `{"failureThreshold":9,"httpGet":{"path":"/","port":"http"},"periodSeconds":15,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration |
| sas-retrieval-agent-manager-app.readinessProbe.failureThreshold | int | `9` | Number of consecutive failures required to mark container as not ready |
| sas-retrieval-agent-manager-app.readinessProbe.httpGet | object | `{"path":"/","port":"http"}` | HTTP GET probe configuration for readiness |
| sas-retrieval-agent-manager-app.readinessProbe.httpGet.path | string | `"/"` | Path to probe for readiness |
| sas-retrieval-agent-manager-app.readinessProbe.periodSeconds | int | `15` | How often to perform the probe |
| sas-retrieval-agent-manager-app.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| sas-retrieval-agent-manager-app.readinessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| sas-retrieval-agent-manager-app.replicaCount | int | `1` | Number of replicas to run. Chart is not designed to scale horizontally, use at your own risk |
| sas-retrieval-agent-manager-app.resources | object | `{"limits":{"cpu":1,"memory":"512Mi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | The resources to allocate for the container |
| sas-retrieval-agent-manager-app.resources.limits | object | `{"cpu":1,"memory":"512Mi"}` | Resource limits for the container |
| sas-retrieval-agent-manager-app.resources.limits.cpu | int | `1` | CPU limit |
| sas-retrieval-agent-manager-app.resources.limits.memory | string | `"512Mi"` | Memory limit |
| sas-retrieval-agent-manager-app.resources.requests | object | `{"cpu":"50m","memory":"256Mi"}` | Resource requests for the container |
| sas-retrieval-agent-manager-app.resources.requests.cpu | string | `"50m"` | CPU request |
| sas-retrieval-agent-manager-app.resources.requests.memory | string | `"256Mi"` | Memory request |
| sas-retrieval-agent-manager-app.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| sas-retrieval-agent-manager-app.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| sas-retrieval-agent-manager-app.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| sas-retrieval-agent-manager-app.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| sas-retrieval-agent-manager-app.securityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-app.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| sas-retrieval-agent-manager-app.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-app.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| sas-retrieval-agent-manager-app.service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration |
| sas-retrieval-agent-manager-app.service.port | int | `8080` | Kubernetes Service port |
| sas-retrieval-agent-manager-app.service.type | string | `"ClusterIP"` | Kubernetes Service type |
| sas-retrieval-agent-manager-app.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration |
| sas-retrieval-agent-manager-app.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| sas-retrieval-agent-manager-app.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| sas-retrieval-agent-manager-app.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| sas-retrieval-agent-manager-app.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| sas-retrieval-agent-manager-app.tolerations | list | `[]` | Tolerations for pod assignment |
| sas-retrieval-agent-manager-app.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| sas-retrieval-agent-manager-app.volumes | list | `[]` | Additional volumes on the output Deployment definition |
| sas-retrieval-agent-manager-db-init | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"fullnameOverride":"sas-retrieval-agent-manager-db-init","imagePullSecrets":[],"nameOverride":"initialization","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"automount":true,"create":true,"name":""},"tolerations":[]}` | Initializes databases and schemas for the entire platform |
| sas-retrieval-agent-manager-db-init.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Map of node/pod affinities |
| sas-retrieval-agent-manager-db-init.fullnameOverride | string | `"sas-retrieval-agent-manager-db-init"` | String to fully override the fullname template with a string |
| sas-retrieval-agent-manager-db-init.imagePullSecrets | list | `[]` | Array of imagePullSecrets in the namespace for pulling images from private registries |
| sas-retrieval-agent-manager-db-init.nameOverride | string | `"initialization"` | String to partially override the fullname template with a string (will prepend the release name) |
| sas-retrieval-agent-manager-db-init.nodeSelector | object | `{}` | Node labels for pod assignment |
| sas-retrieval-agent-manager-db-init.podAnnotations | object | `{}` | Annotations to add to the pods |
| sas-retrieval-agent-manager-db-init.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels to add to the pods |
| sas-retrieval-agent-manager-db-init.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the pods |
| sas-retrieval-agent-manager-db-init.podSecurityContext.fsGroup | int | `10001` | Group ID for file system ownership |
| sas-retrieval-agent-manager-db-init.podSecurityContext.runAsGroup | int | `10001` | Group ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-db-init.podSecurityContext.runAsNonRoot | bool | `true` | Indicates that the container must be run as a non-root user |
| sas-retrieval-agent-manager-db-init.podSecurityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-db-init.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the pod |
| sas-retrieval-agent-manager-db-init.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | The resources to allocate for the database initialization container |
| sas-retrieval-agent-manager-db-init.resources.limits | object | `{"cpu":"200m","memory":"256Mi"}` | Resource limits for the container |
| sas-retrieval-agent-manager-db-init.resources.limits.cpu | string | `"200m"` | CPU limit |
| sas-retrieval-agent-manager-db-init.resources.limits.memory | string | `"256Mi"` | Memory limit |
| sas-retrieval-agent-manager-db-init.resources.requests | object | `{"cpu":"100m","memory":"128Mi"}` | Resource requests for the container |
| sas-retrieval-agent-manager-db-init.resources.requests.cpu | string | `"100m"` | CPU request |
| sas-retrieval-agent-manager-db-init.resources.requests.memory | string | `"128Mi"` | Memory request |
| sas-retrieval-agent-manager-db-init.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":[],"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | The security context for the application container |
| sas-retrieval-agent-manager-db-init.securityContext.allowPrivilegeEscalation | bool | `false` | Whether a process can gain more privileges than its parent process |
| sas-retrieval-agent-manager-db-init.securityContext.capabilities | object | `{"add":[],"drop":["ALL"]}` | Linux capabilities to add/drop for the container |
| sas-retrieval-agent-manager-db-init.securityContext.readOnlyRootFilesystem | bool | `true` | Whether the container has a read-only root filesystem |
| sas-retrieval-agent-manager-db-init.securityContext.runAsNonRoot | bool | `true` | Whether the container must be run as a non-root user |
| sas-retrieval-agent-manager-db-init.securityContext.runAsUser | int | `10001` | User ID to run the entrypoint of the container process |
| sas-retrieval-agent-manager-db-init.securityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | Seccomp profile for the container |
| sas-retrieval-agent-manager-db-init.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account configuration for database initialization |
| sas-retrieval-agent-manager-db-init.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| sas-retrieval-agent-manager-db-init.serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials |
| sas-retrieval-agent-manager-db-init.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| sas-retrieval-agent-manager-db-init.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| sas-retrieval-agent-manager-db-init.tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
