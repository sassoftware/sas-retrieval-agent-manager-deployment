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
| filebrowser | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"config":{"port":18080,"root":"/mnt/data"},"db":{"pvc":{"accessModes":["ReadWriteOnce"],"size":"1Gi","storageClassName":""}},"enabled":false,"fullnameOverride":"sas-retrieval-agent-manager-filebrowser","imagePullSecrets":[],"ingress":{"useGlobal":true},"initContainers":[],"livenessProbe":{},"nameOverride":"filebrowser","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{},"readinessProbe":{"httpGet":{"path":"/health","port":"http"}},"replicaCount":1,"resources":{},"rootDir":{"accessModes":["ReadWriteOnce"],"size":"10Gi","storageClassName":"","type":"pvc"},"securityContext":{},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":false,"name":""},"strategy":{"type":"Recreate"},"tolerations":[]}` | Integrates with OAuth2 proxy for authentication |
| filebrowser.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Advanced pod scheduling rules |
| filebrowser.config | object | `{"port":18080,"root":"/mnt/data"}` | FileBrowser application-specific configuration |
| filebrowser.config.port | int | `18080` | Internal port for FileBrowser service |
| filebrowser.config.root | string | `"/mnt/data"` | Root directory for file browsing |
| filebrowser.db | object | `{"pvc":{"accessModes":["ReadWriteOnce"],"size":"1Gi","storageClassName":""}}` | Database storage configuration for FileBrowser metadata |
| filebrowser.db.pvc.accessModes | list | `["ReadWriteOnce"]` | Access mode for database volume |
| filebrowser.db.pvc.size | string | `"1Gi"` | Size of database volume |
| filebrowser.db.pvc.storageClassName | string | `""` | Storage class for database PVC |
| filebrowser.enabled | bool | `false` | Disabled by default for security |
| filebrowser.fullnameOverride | string | `"sas-retrieval-agent-manager-filebrowser"` | Override full resource names |
| filebrowser.imagePullSecrets | list | `[]` | Empty for public Docker Hub images |
| filebrowser.ingress | object | `{"useGlobal":true}` | Provides HTTP/HTTPS access to the file browser interface |
| filebrowser.ingress.useGlobal | bool | `true` | Use global ingress configuration from parent chart |
| filebrowser.livenessProbe | object | `{}` | Check if container is alive (restart if fails) |
| filebrowser.nameOverride | string | `"filebrowser"` | Override default name prefix |
| filebrowser.nodeSelector | object | `{}` | Schedule pods on nodes with specific labels |
| filebrowser.podAnnotations | object | `{}` | Annotations applied to FileBrowser pods |
| filebrowser.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels applied to FileBrowser pods |
| filebrowser.podSecurityContext | object | `{}` | Security context for the entire pod |
| filebrowser.readinessProbe | object | `{"httpGet":{"path":"/health","port":"http"}}` | Check if container is ready to serve traffic |
| filebrowser.readinessProbe.httpGet.path | string | `"/health"` | Health check endpoint |
| filebrowser.readinessProbe.httpGet.port | string | `"http"` | Use the http port defined in service |
| filebrowser.replicaCount | int | `1` | FileBrowser is not designed for horizontal scaling, keep at 1 |
| filebrowser.resources | object | `{}` | CPU and memory limits/requests (empty = no limits) |
| filebrowser.rootDir | object | `{"accessModes":["ReadWriteOnce"],"size":"10Gi","storageClassName":"","type":"pvc"}` | Storage configuration for file browser root directory |
| filebrowser.rootDir.accessModes[0] | string | `"ReadWriteOnce"` | Access mode for the volume |
| filebrowser.rootDir.size | string | `"10Gi"` | Size of the persistent volume |
| filebrowser.rootDir.storageClassName | string | `""` | Storage class for PVC (empty = default) |
| filebrowser.rootDir.type | string | `"pvc"` | Storage type (pvc, hostPath, emptyDir) |
| filebrowser.securityContext | object | `{}` | Security context for the FileBrowser container |
| filebrowser.service | object | `{"port":80,"type":"ClusterIP"}` | Defines how FileBrowser is exposed within the cluster |
| filebrowser.service.port | int | `80` | Service port number |
| filebrowser.service.type | string | `"ClusterIP"` | Service type (ClusterIP, NodePort, LoadBalancer) |
| filebrowser.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Controls the Kubernetes service account used by FileBrowser pods |
| filebrowser.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| filebrowser.serviceAccount.create | bool | `false` | Create a new service account for this deployment |
| filebrowser.serviceAccount.name | string | `""` | Service account name (auto-generated if empty and create=true) |
| filebrowser.strategy | object | `{"type":"Recreate"}` | Recreate ensures only one instance during updates (important for file consistency) |
| filebrowser.strategy.type | string | `"Recreate"` | Deployment strategy (Recreate vs RollingUpdate) |
| filebrowser.tolerations | list | `[]` | Allow pods on nodes with matching taints |
| fullnameOverride | string | `"sas-retrieval-agent-manager"` | This becomes the prefix for all Kubernetes resource names |
| global.configuration | object | `{"api":{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"},"application":{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"},"database":{"createSchema":true,"createUsers":true,"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"},"gpg":{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","passphrase_path":"/mnt/config/gpg_passphrase","privateKey":"","private_key_path":"/mnt/config/gpg_key","publicKey":""},"keycloak":{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","cookieSecret":"","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","password":"","proxy":"edge","realm":"sas-iot","schema":"keycloak","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","user":"sas_keycloak_user","userRole":"sas-iot-user"},"kueue":{"cpuQuota":"32","memoryQuota":"128Gi","podQuota":6},"migration":{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"},"postgrest":{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000},"swagger":{"enabled":false},"vectorStore":{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"},"vectorizationJob":{"password":"","user":"sas_ram_vectorization_user"},"vhub":{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"imagePullSecrets":[]},"weaviate":{"enabled":false}}` | Contains database, authentication, and service-specific settings |
| global.configuration.api | object | `{"azure_settings":{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}},"base_path":"/SASRetrievalAgentManager/api","enable_dev_mode":"False","enable_profiling":"False","latest_version":"v1","license":"","license_secret":"license-secret","license_secret_path":"/mnt/config/license","log_level":"INFO","num_workers":4,"sslVerify":"True","useOldLicense":"False"}` | Controls the core RAM backend service behavior |
| global.configuration.api.azure_settings | object | `{"azure_identity":{"client_id":"","enabled":false,"scope":"https://cognitiveservices.azure.com/.default","token_keyword":"AZURE_IDENTITY"},"openAI":{"default_api_version":"2024-10-21"}}` | Azure integration settings for API and identity management |
| global.configuration.api.azure_settings.azure_identity.client_id | string | `""` | Azure AD client ID for authentication (leave blank to disable) |
| global.configuration.api.azure_settings.azure_identity.enabled | bool | `false` | Enable Azure AD identity integration (true/false) |
| global.configuration.api.azure_settings.azure_identity.scope | string | `"https://cognitiveservices.azure.com/.default"` | OAuth2 scope for Azure Cognitive Services authentication |
| global.configuration.api.azure_settings.azure_identity.token_keyword | string | `"AZURE_IDENTITY"` | Keyword used to identify Azure identity tokens in requests |
| global.configuration.api.azure_settings.openAI.default_api_version | string | `"2024-10-21"` | Default API version for Azure OpenAI service (format: YYYY-MM-DD) |
| global.configuration.api.base_path | string | `"/SASRetrievalAgentManager/api"` | Base URL path for API endpoints |
| global.configuration.api.enable_dev_mode | string | `"False"` | Enable experimental/development features |
| global.configuration.api.enable_profiling | string | `"False"` | Enable performance profiling and metrics |
| global.configuration.api.latest_version | string | `"v1"` | Latest API version identifier |
| global.configuration.api.license | string | `""` | SAS license content |
| global.configuration.api.license_secret | string | `"license-secret"` | Name of Kubernetes secret containing license |
| global.configuration.api.license_secret_path | string | `"/mnt/config/license"` | Path where license secret is mounted |
| global.configuration.api.log_level | string | `"INFO"` | Logging level (DEBUG, INFO, WARN, ERROR) |
| global.configuration.api.num_workers | int | `4` | Number of worker processes for handling requests |
| global.configuration.api.sslVerify | string | `"True"` | Verify SSL certificates for external API calls |
| global.configuration.api.useOldLicense | string | `"False"` | Use legacy license format compatibility |
| global.configuration.application | object | `{"adminRole":"sas_ram_admin_role","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManager","password":"","schema":"retagentmgr","user":"sas_ram_pgrest_user","userRole":"sas_ram_user_role"}` | Defines the main application database and user roles |
| global.configuration.application.adminRole | string | `"sas_ram_admin_role"` | Administrator role name |
| global.configuration.application.createDB | bool | `true` | Create application database during initialization |
| global.configuration.application.createSchema | bool | `true` | Create application schema |
| global.configuration.application.createUser | bool | `true` | Create application database user |
| global.configuration.application.db | string | `"SASRetrievalAgentManager"` | Application database name |
| global.configuration.application.password | string | `""` | User password |
| global.configuration.application.schema | string | `"retagentmgr"` | Application schema name |
| global.configuration.application.user | string | `"sas_ram_pgrest_user"` | Application database user name |
| global.configuration.application.userRole | string | `"sas_ram_user_role"` | Regular user role name |
| global.configuration.database | object | `{"createSchema":true,"createUsers":true,"host":"","initAdminPassword":"","initAdminRole":"azure_pg_admin","initializeDb":"true","port":"5432","sslmode":"require"}` | Controls initial database setup and connection parameters |
| global.configuration.database.createSchema | bool | `true` | Create database schemas during initialization |
| global.configuration.database.createUsers | bool | `true` | Create database users during initialization |
| global.configuration.database.host | string | `""` | PostgreSQL server hostname/IP (required for external DB) |
| global.configuration.database.initAdminPassword | string | `""` | Password for initial admin user |
| global.configuration.database.initAdminRole | string | `"azure_pg_admin"` | Initial admin role for database setup |
| global.configuration.database.initializeDb | string | `"true"` | Whether to initialize the database on first deployment |
| global.configuration.database.port | string | `"5432"` | PostgreSQL server port |
| global.configuration.database.sslmode | string | `"require"` | SSL connection mode (disable, allow, prefer, require, verify-ca, verify-full) |
| global.configuration.gpg | object | `{"key":{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"},"passphrase":"","passphrase_path":"/mnt/config/gpg_passphrase","privateKey":"","private_key_path":"/mnt/config/gpg_key","publicKey":""}` | Controls encryption/decryption operations for secure data handling |
| global.configuration.gpg.key | object | `{"comment":"RAM GPG Key","email":"ram@sas.com","expire":"0","length":4096,"name":"RAM Secrets"}` | Automatic key generation settings (used when publicKey/privateKey are empty) |
| global.configuration.gpg.key.comment | string | `"RAM GPG Key"` | Key comment/description |
| global.configuration.gpg.key.email | string | `"ram@sas.com"` | Key owner email address |
| global.configuration.gpg.key.expire | string | `"0"` | Key expiration (0 = never expires) |
| global.configuration.gpg.key.length | int | `4096` | Key length in bits (2048, 4096) |
| global.configuration.gpg.key.name | string | `"RAM Secrets"` | Key owner name |
| global.configuration.gpg.passphrase | string | `""` | GPG key passphrase |
| global.configuration.gpg.passphrase_path | string | `"/mnt/config/gpg_passphrase"` | Path to GPG passphrase secret mount |
| global.configuration.gpg.privateKey | string | `""` | Existing GPG private key |
| global.configuration.gpg.private_key_path | string | `"/mnt/config/gpg_key"` | Path to GPG private key secret mount |
| global.configuration.gpg.publicKey | string | `""` | Existing GPG public key |
| global.configuration.keycloak | object | `{"adminRole":"sas-iot-admin","appAdmin":"AppAdmin","appAdminPassword":"","clientId":"sas-ram-app","clientSecret":"","cookieSecret":"","createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerIAM","keycloakAdmin":"kcAdmin","keycloakAdminPassword":"","password":"","proxy":"edge","realm":"sas-iot","schema":"keycloak","secret_path":"/mnt/config/keycloak","serviceaccountsEnabled":false,"strictHostname":true,"theme":"sasblue","user":"sas_keycloak_user","userRole":"sas-iot-user"}` | Defines authentication server settings and user management |
| global.configuration.keycloak.adminRole | string | `"sas-iot-admin"` | Administrator role in Keycloak |
| global.configuration.keycloak.appAdmin | string | `"AppAdmin"` | Application administrator username |
| global.configuration.keycloak.appAdminPassword | string | `""` | Application admin password |
| global.configuration.keycloak.clientId | string | `"sas-ram-app"` | OAuth2 client ID for application |
| global.configuration.keycloak.clientSecret | string | `""` | OAuth2 client secret |
| global.configuration.keycloak.cookieSecret | string | `""` | OAuth2 cookie secret |
| global.configuration.keycloak.createDB | bool | `true` | Create Keycloak database during initialization |
| global.configuration.keycloak.createSchema | bool | `true` | Create Keycloak schema |
| global.configuration.keycloak.createUser | bool | `true` | Create Keycloak database user |
| global.configuration.keycloak.db | string | `"SASRetrievalAgentManagerIAM"` | Keycloak database name |
| global.configuration.keycloak.keycloakAdmin | string | `"kcAdmin"` | Keycloak system administrator username |
| global.configuration.keycloak.keycloakAdminPassword | string | `""` | Keycloak admin password |
| global.configuration.keycloak.password | string | `""` | Database user password |
| global.configuration.keycloak.proxy | string | `"edge"` | Proxy mode (edge, reencrypt, passthrough) |
| global.configuration.keycloak.realm | string | `"sas-iot"` | Keycloak realm name for authentication context |
| global.configuration.keycloak.schema | string | `"keycloak"` | Keycloak schema name |
| global.configuration.keycloak.secret_path | string | `"/mnt/config/keycloak"` | Path to Keycloak secrets for API integration |
| global.configuration.keycloak.serviceaccountsEnabled | bool | `false` | Enable service account authentication |
| global.configuration.keycloak.strictHostname | bool | `true` | Enforce strict hostname checking |
| global.configuration.keycloak.theme | string | `"sasblue"` | Keycloak UI theme (sasblue for SAS branding) |
| global.configuration.keycloak.user | string | `"sas_keycloak_user"` | Keycloak database user name |
| global.configuration.keycloak.userRole | string | `"sas-iot-user"` | Regular user role in Keycloak |
| global.configuration.kueue | object | `{"cpuQuota":"32","memoryQuota":"128Gi","podQuota":6}` | Kueue configuration |
| global.configuration.kueue.cpuQuota | string | `"32"` | Kueue CPU quota |
| global.configuration.kueue.memoryQuota | string | `"128Gi"` | Kueue memory quota |
| global.configuration.kueue.podQuota | int | `6` | Kueue pod quota |
| global.configuration.migration | object | `{"createUser":true,"dbMigrationPassword":"","dbMigrationUser":"sas_iot_migration"}` | Controls database schema migration operations using Goose migration tool |
| global.configuration.migration.createUser | bool | `true` | Create database migration user during initialization |
| global.configuration.migration.dbMigrationPassword | string | `""` | Database migration user password |
| global.configuration.migration.dbMigrationUser | string | `"sas_iot_migration"` | Database migration user name |
| global.configuration.postgrest | object | `{"admin-server-port":3001,"jwt-role-claim-key":".resource_access.\"sas-ram-app\".roles[0]","log-level":"info","openapi-mode":"follow-privileges","openapi-security-active":true,"server-port":3000}` | Controls REST API generation from PostgreSQL database |
| global.configuration.postgrest.admin-server-port | int | `3001` | Port for PostgREST admin server |
| global.configuration.postgrest.jwt-role-claim-key | string | `".resource_access.\"sas-ram-app\".roles[0]"` | JWT role claim key configuration (uses value from keycloak.clientId) |
| global.configuration.postgrest.log-level | string | `"info"` | Log level for PostgREST (info, debug, etc.) |
| global.configuration.postgrest.openapi-mode | string | `"follow-privileges"` | OpenAPI mode configuration |
| global.configuration.postgrest.openapi-security-active | bool | `true` | Whether OpenAPI security is active |
| global.configuration.postgrest.server-port | int | `3000` | Port for PostgREST main server |
| global.configuration.swagger | object | `{"enabled":false}` | Controls API documentation generation and access |
| global.configuration.swagger.enabled | bool | `false` | Enable Swagger UI for API documentation |
| global.configuration.vectorStore | object | `{"createDB":true,"createSchema":true,"createUser":true,"db":"SASRetrievalAgentManagerVector","enabled":true,"password":"","schema":"vectorstore","user":"vector_store_user"}` | Controls vector database setup for AI/ML embeddings and similarity search |
| global.configuration.vectorStore.createDB | bool | `true` | Create vector store database during initialization |
| global.configuration.vectorStore.createSchema | bool | `true` | Create vector store schema |
| global.configuration.vectorStore.createUser | bool | `true` | Create vector store database user |
| global.configuration.vectorStore.db | string | `"SASRetrievalAgentManagerVector"` | Vector store database name |
| global.configuration.vectorStore.enabled | bool | `true` | Enable vector store functionality |
| global.configuration.vectorStore.password | string | `""` | Vector store user password |
| global.configuration.vectorStore.schema | string | `"vectorstore"` | Vector store schema name |
| global.configuration.vectorStore.user | string | `"vector_store_user"` | Vector store database user name |
| global.configuration.vectorizationJob | object | `{"password":"","user":"sas_ram_vectorization_user"}` | Controls user authentication for vectorization processing jobs |
| global.configuration.vectorizationJob.password | string | `""` | Vectorization job user password |
| global.configuration.vectorizationJob.user | string | `"sas_ram_vectorization_user"` | Vectorization job user name |
| global.configuration.vhub | object | `{"availableHardware":{"execution_providers":["cpu","openvino"],"job_req_cpu":{"default":6,"max":6,"min":1},"job_req_mem":{"default":"32Gi","max":"48Gi","min":"16Gi","model_default":{"GTE-ModernColBERT-v1":"24Gi","all-MiniLM-L6-v2":"16Gi","distiluse-base-multilingual-cased-v2":"16Gi","nomic-embed-text-v2-moe":"32Gi"}},"openvino_device_type":["CPU_FP32"],"plugin_req_cpu":{"default":2,"max":6,"min":1},"plugin_req_mem":{"default":"4Gi","max":"16Gi","min":"1Gi"},"supported_ocr_languages":{"paddle":["eng","chi_tra","dan","deu","spa","fra","ita","nld","pol","por"],"tesseract":["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]}},"imagePullSecrets":[]}` | Vectorization Hub (VHub) configuration |
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
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[0] | string | `"eng"` | English |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[1] | string | `"chi_tra"` | Chinese Traditional |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[2] | string | `"dan"` | Danish |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[3] | string | `"deu"` | German (Deutsch) |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[4] | string | `"spa"` | Spanish |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[5] | string | `"fra"` | French |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[6] | string | `"ita"` | Italian |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[7] | string | `"nld"` | Dutch (Nederlands) |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[8] | string | `"pol"` | Polish |
| global.configuration.vhub.availableHardware.supported_ocr_languages.paddle[9] | string | `"por"` | Portuguese |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract | list | `["eng","chi_tra","jpn","dan","deu","spa","fra","ita","nld","pol","por","chi_sim","osd","equ"]` | Languages supported by Tesseract |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[0] | string | `"eng"` | English |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[10] | string | `"por"` | Portuguese |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[11] | string | `"chi_sim"` | Chinese Simplified |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[12] | string | `"osd"` | Orientation and Script Detection |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[13] | string | `"equ"` | Math/Equation Detection |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[1] | string | `"chi_tra"` | Chinese Traditional |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[2] | string | `"jpn"` | Japanese |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[3] | string | `"dan"` | Danish |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[4] | string | `"deu"` | German (Deutsch) |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[5] | string | `"spa"` | Spanish |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[6] | string | `"fra"` | French |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[7] | string | `"ita"` | Italian |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[8] | string | `"nld"` | Dutch (Nederlands) |
| global.configuration.vhub.availableHardware.supported_ocr_languages.tesseract[9] | string | `"pol"` | Polish |
| global.configuration.vhub.imagePullSecrets | list | `[]` | Array of imagePullSecrets for vectorization hub |
| global.configuration.weaviate | object | `{"enabled":false}` | weaviate settings |
| global.configuration.weaviate.enabled | bool | `false` | Enable hydration for local Weaviate installation |
| global.image | object | `{"repo":{"base":"cr.sas.com"}}` | When sub-charts have useGlobal=true, images are pulled from this base repository |
| global.image.repo.base | string | `"cr.sas.com"` | Base container registry URL (SAS Container Registry) |
| global.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Applied to all sub-charts that reference private registries |
| global.ingress | object | `{"className":"nginx","enabled":true,"tls":{"enabled":true}}` | Provides consistent external access patterns across all services |
| global.ingress.className | string | `"nginx"` | Ingress controller class |
| global.ingress.enabled | bool | `true` | Enable ingress resources globally |
| global.ingress.tls.enabled | bool | `true` | Enable TLS/SSL termination |
| gpg | object | `{"fullnameOverride":"sas-retrieval-agent-manager-gpg","imagePullSecrets":[],"nameOverride":"gpg","podAnnotations":{"linkerd.io/inject":"enabled"},"podSecurityContext":{"fsGroup":10001},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"create":true,"name":""}}` | Provides GPG encryption/decryption capabilities for secure data handling |
| gpg.fullnameOverride | string | `"sas-retrieval-agent-manager-gpg"` | Full resource name |
| gpg.imagePullSecrets | list | `[]` | No secrets needed for public registry |
| gpg.nameOverride | string | `"gpg"` | Override default resource name prefix |
| gpg.podAnnotations | object | `{"linkerd.io/inject":"enabled"}` | Pod metadata configuration |
| gpg.podAnnotations."linkerd.io/inject" | string | `"enabled"` | Enable service mesh integration |
| gpg.podSecurityContext | object | `{"fsGroup":10001}` | Pod and container security configuration |
| gpg.podSecurityContext.fsGroup | int | `10001` | File system group for volume permissions |
| gpg.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| gpg.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| gpg.securityContext.privileged | bool | `false` | Run as non-privileged container |
| gpg.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for GPG operations |
| gpg.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| gpg.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| gpg.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| gpg.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| gpg.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| gpg.serviceAccount.annotations | object | `{}` | Service account annotations |
| gpg.serviceAccount.create | bool | `true` | Create a service account for GPG operations |
| gpg.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| keycloak | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"fullnameOverride":"sas-retrieval-agent-manager-keycloak","imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"useGlobal":true},"mail":{"config":{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}},"enabled":false,"fullnameOverride":"mail","persistence":{"enabled":false},"pod":{"annotations":{"linkerd.io/inject":"enabled"}}},"nameOverride":"keycloak","nodeSelector":{},"oauthProxy":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"","imagePullSecrets":[{"name":"acr-secret"}],"ingress":{"useGlobal":true},"livenessProbe":{"httpGet":{"path":"/ping","port":"http"}},"nameOverride":"oauth2-proxy","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"readinessProbe":{"httpGet":{"path":"/ping","port":"http"}},"replicaCount":1,"resources":{},"tolerations":[],"volumeMounts":[],"volumes":[]},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsUser":10001},"replicaCount":1,"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Provides authentication, authorization, and user management |
| keycloak.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Advanced pod scheduling rules |
| keycloak.fullnameOverride | string | `"sas-retrieval-agent-manager-keycloak"` | Full resource name override |
| keycloak.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Image pull secrets for private registry access |
| keycloak.imagePullSecrets[0] | object | `{"name":"cr-sas-secret"}` | Secret for accessing SAS container registry |
| keycloak.ingress | object | `{"useGlobal":true}` | Ingress configuration for external access |
| keycloak.ingress.useGlobal | bool | `true` | Use global ingress configuration from parent chart |
| keycloak.mail | object | `{"config":{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}},"enabled":false,"fullnameOverride":"mail","persistence":{"enabled":false},"pod":{"annotations":{"linkerd.io/inject":"enabled"}}}` | This should not be used for production workloads! |
| keycloak.mail.config | object | `{"general":{"ALLOW_EMPTY_SENDER_DOMAINS":"true","TZ":"UTC"},"postfix":{"mynetworks":"10.0.0.0/8, 127.0.0.0/8","smtpd_recipient_restrictions":"permit_mynetworks, reject_unauth_destination"}}` | Mail server application configuration |
| keycloak.mail.config.general.ALLOW_EMPTY_SENDER_DOMAINS | string | `"true"` | Allow empty sender domains |
| keycloak.mail.config.general.TZ | string | `"UTC"` | Timezone setting |
| keycloak.mail.config.postfix.mynetworks | string | `"10.0.0.0/8, 127.0.0.0/8"` | Trusted networks |
| keycloak.mail.config.postfix.smtpd_recipient_restrictions | string | `"permit_mynetworks, reject_unauth_destination"` | SMTP restrictions |
| keycloak.mail.enabled | bool | `false` | Enable mail server integration |
| keycloak.mail.fullnameOverride | string | `"mail"` | Mail server resource name |
| keycloak.mail.persistence | object | `{"enabled":false}` | Persistent storage for mail server |
| keycloak.mail.persistence.enabled | bool | `false` | Enable persistent storage for mail |
| keycloak.mail.pod | object | `{"annotations":{"linkerd.io/inject":"enabled"}}` | Mail server pod configuration |
| keycloak.nameOverride | string | `"keycloak"` | Override default resource name prefix |
| keycloak.nodeSelector | object | `{}` | Schedule pods on nodes with specific labels |
| keycloak.oauthProxy | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"","imagePullSecrets":[{"name":"acr-secret"}],"ingress":{"useGlobal":true},"livenessProbe":{"httpGet":{"path":"/ping","port":"http"}},"nameOverride":"oauth2-proxy","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"readinessProbe":{"httpGet":{"path":"/ping","port":"http"}},"replicaCount":1,"resources":{},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Provides OAuth2/OIDC authentication middleware |
| keycloak.oauthProxy.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Pod affinity rules |
| keycloak.oauthProxy.autoscaling.enabled | bool | `false` | Enable horizontal pod autoscaling |
| keycloak.oauthProxy.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| keycloak.oauthProxy.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| keycloak.oauthProxy.autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling |
| keycloak.oauthProxy.fullnameOverride | string | `""` | Full name override for OAuth2 proxy |
| keycloak.oauthProxy.imagePullSecrets | list | `[{"name":"acr-secret"}]` | Image pull secrets for OAuth2 proxy |
| keycloak.oauthProxy.imagePullSecrets[0] | object | `{"name":"acr-secret"}` | Secret for accessing container registry |
| keycloak.oauthProxy.ingress | object | `{"useGlobal":true}` | Ingress configuration for OAuth2 proxy |
| keycloak.oauthProxy.ingress.useGlobal | bool | `true` | Use global ingress configuration |
| keycloak.oauthProxy.livenessProbe | object | `{"httpGet":{"path":"/ping","port":"http"}}` | Health check probes for OAuth2 proxy |
| keycloak.oauthProxy.livenessProbe.httpGet.path | string | `"/ping"` | OAuth2 proxy health endpoint |
| keycloak.oauthProxy.livenessProbe.httpGet.port | string | `"http"` | Use the http port |
| keycloak.oauthProxy.nameOverride | string | `"oauth2-proxy"` | OAuth2 proxy resource name |
| keycloak.oauthProxy.nodeSelector | object | `{}` | Node selection constraints |
| keycloak.oauthProxy.podAnnotations | object | `{}` | Pod annotations |
| keycloak.oauthProxy.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod labels |
| keycloak.oauthProxy.readinessProbe.httpGet.path | string | `"/ping"` | OAuth2 proxy readiness endpoint |
| keycloak.oauthProxy.readinessProbe.httpGet.port | string | `"http"` | Use the http port |
| keycloak.oauthProxy.replicaCount | int | `1` | Number of OAuth2 proxy replicas |
| keycloak.oauthProxy.resources | object | `{}` | CPU and memory limits/requests |
| keycloak.oauthProxy.tolerations | list | `[]` | Node tolerations |
| keycloak.oauthProxy.volumeMounts | list | `[]` | Additional volume mounts |
| keycloak.oauthProxy.volumes | list | `[]` | Additional volumes |
| keycloak.podAnnotations | object | `{}` | Annotations applied to Keycloak pods |
| keycloak.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Labels applied to Keycloak pods |
| keycloak.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsUser":10001}` | Pod security context (applies to entire pod) |
| keycloak.podSecurityContext.fsGroup | int | `10001` | File system group ownership |
| keycloak.podSecurityContext.runAsGroup | int | `10001` | Run as non-root group |
| keycloak.podSecurityContext.runAsUser | int | `10001` | Run as non-root user |
| keycloak.replicaCount | int | `1` | Single instance for simplicity (can be scaled for HA) |
| keycloak.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to Keycloak container) |
| keycloak.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| keycloak.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| keycloak.securityContext.privileged | bool | `false` | Run as non-privileged container |
| keycloak.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes to container filesystem |
| keycloak.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| keycloak.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| keycloak.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| keycloak.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| keycloak.service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes service configuration |
| keycloak.service.port | int | `8080` | Keycloak service port |
| keycloak.service.type | string | `"ClusterIP"` | Service type (internal cluster access) |
| keycloak.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| keycloak.serviceAccount.annotations | object | `{}` | Service account annotations |
| keycloak.serviceAccount.create | bool | `true` | Create a service account for Keycloak |
| keycloak.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| keycloak.tolerations | list | `[]` | Allow pods on nodes with matching taints |
| keycloak.volumeMounts | list | `[]` | Additional volume mounts for containers |
| keycloak.volumes | list | `[]` | Additional volumes for the deployment |
| postgrest | object | `{"adminService":{"port":3001,"type":"ClusterIP"},"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-postgrest","imagePullSecrets":[],"ingress":{"useGlobal":true},"livenessProbe":{"failureThreshold":3,"httpGet":{"path":"/live","port":3001,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"postgrest","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001},"postgrest":null,"readinessProbe":{"failureThreshold":3,"httpGet":{"path":"/ready","port":3001,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":3000,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"swagger":{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":false,"fullnameOverride":"","imagePullSecrets":[],"ingress":{"useGlobal":true},"livenessProbe":{"httpGet":{"path":"/","port":"http"}},"nameOverride":"swagger","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"readinessProbe":{"httpGet":{"path":"/","port":"http"}},"replicaCount":1,"resources":{},"tolerations":[],"volumeMounts":[],"volumes":[]},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Automatically generates REST endpoints from database schema |
| postgrest.adminService | object | `{"port":3001,"type":"ClusterIP"}` | Admin service configuration (for administrative operations) |
| postgrest.adminService.port | int | `3001` | PostgREST admin port |
| postgrest.adminService.type | string | `"ClusterIP"` | Admin service type |
| postgrest.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Advanced pod scheduling rules |
| postgrest.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Resource allocation and horizontal pod autoscaling resources:   limits:     # -- Maximum CPU allocation     cpu: ""     # -- Maximum memory allocation     memory: ""   requests:     # -- Requested CPU allocation     cpu: ""     # -- Requested memory allocation     memory: "" |
| postgrest.autoscaling.enabled | bool | `false` | Disable horizontal pod autoscaling by default |
| postgrest.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| postgrest.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| postgrest.autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling |
| postgrest.fullnameOverride | string | `"sas-retrieval-agent-manager-postgrest"` | Full resource name |
| postgrest.imagePullSecrets | list | `[]` | No secrets needed for public registry |
| postgrest.ingress | object | `{"useGlobal":true}` | Ingress configuration for external API access |
| postgrest.ingress.useGlobal | bool | `true` | Use global ingress configuration from parent chart |
| postgrest.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/live","port":3001,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Health check probes for container lifecycle management |
| postgrest.livenessProbe.failureThreshold | int | `3` | Failure threshold before restart |
| postgrest.livenessProbe.httpGet.path | string | `"/live"` | PostgREST liveness endpoint |
| postgrest.livenessProbe.httpGet.port | int | `3001` | Use admin port |
| postgrest.livenessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| postgrest.livenessProbe.periodSeconds | int | `10` | Probe frequency |
| postgrest.livenessProbe.successThreshold | int | `1` | Success threshold |
| postgrest.nameOverride | string | `"postgrest"` | Override default resource name prefix |
| postgrest.nodeSelector | object | `{}` | Schedule pods on nodes with specific labels |
| postgrest.podAnnotations | object | `{}` | Pod annotations |
| postgrest.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod labels |
| postgrest.podSecurityContext | object | `{"fsGroup":10001}` | Pod security context (applies to entire pod) |
| postgrest.podSecurityContext.fsGroup | int | `10001` | File system group for volume permissions |
| postgrest.postgrest | string | `nil` | PostgREST container image configuration |
| postgrest.readinessProbe.failureThreshold | int | `3` | Failure threshold before marking not ready |
| postgrest.readinessProbe.httpGet.path | string | `"/ready"` | PostgREST readiness endpoint |
| postgrest.readinessProbe.httpGet.port | int | `3001` | Use admin port |
| postgrest.readinessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| postgrest.readinessProbe.periodSeconds | int | `10` | Probe frequency |
| postgrest.readinessProbe.successThreshold | int | `1` | Success threshold |
| postgrest.readinessProbe.timeoutSeconds | int | `1` | Probe timeout |
| postgrest.replicaCount | int | `1` | Single instance (can be scaled for higher load) |
| postgrest.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to PostgREST container) |
| postgrest.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| postgrest.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| postgrest.securityContext.privileged | bool | `false` | Run as non-privileged container |
| postgrest.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for configuration |
| postgrest.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| postgrest.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| postgrest.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| postgrest.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| postgrest.service | object | `{"port":3000,"type":"ClusterIP"}` | Kubernetes service configuration |
| postgrest.service.port | int | `3000` | PostgREST API port |
| postgrest.service.type | string | `"ClusterIP"` | Service type (internal cluster access) |
| postgrest.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| postgrest.serviceAccount.annotations | object | `{}` | Service account annotations |
| postgrest.serviceAccount.create | bool | `true` | Create a service account for PostgREST |
| postgrest.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| postgrest.swagger | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":false,"fullnameOverride":"","imagePullSecrets":[],"ingress":{"useGlobal":true},"livenessProbe":{"httpGet":{"path":"/","port":"http"}},"nameOverride":"swagger","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"readinessProbe":{"httpGet":{"path":"/","port":"http"}},"replicaCount":1,"resources":{},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Swagger UI integration for API documentation |
| postgrest.swagger.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Pod affinity rules |
| postgrest.swagger.autoscaling.enabled | bool | `false` | Disable horizontal pod autoscaling |
| postgrest.swagger.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| postgrest.swagger.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| postgrest.swagger.autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling |
| postgrest.swagger.enabled | bool | `false` | Enable Swagger UI for PostgREST API |
| postgrest.swagger.fullnameOverride | string | `""` | Full name override |
| postgrest.swagger.imagePullSecrets | list | `[]` | Image pull secrets for Swagger UI |
| postgrest.swagger.ingress | object | `{"useGlobal":true}` | Ingress configuration for Swagger UI |
| postgrest.swagger.ingress.useGlobal | bool | `true` | Use global ingress configuration |
| postgrest.swagger.livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | Health check probes for Swagger UI |
| postgrest.swagger.livenessProbe.httpGet.path | string | `"/"` | Swagger UI health endpoint |
| postgrest.swagger.livenessProbe.httpGet.port | string | `"http"` | Use the http port |
| postgrest.swagger.nameOverride | string | `"swagger"` | Override default name prefix |
| postgrest.swagger.nodeSelector | object | `{}` | Node selection constraints |
| postgrest.swagger.podAnnotations | object | `{}` | Pod annotations |
| postgrest.swagger.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod labels |
| postgrest.swagger.readinessProbe.httpGet.path | string | `"/"` | Swagger UI readiness endpoint |
| postgrest.swagger.readinessProbe.httpGet.port | string | `"http"` | Use the http port |
| postgrest.swagger.replicaCount | int | `1` | Number of Swagger UI replicas |
| postgrest.swagger.resources | object | `{}` | CPU and memory limits/requests |
| postgrest.swagger.tolerations | list | `[]` | Node tolerations |
| postgrest.swagger.volumeMounts | list | `[]` | Additional volume mounts |
| postgrest.swagger.volumes | list | `[]` | Additional volumes |
| postgrest.tolerations | list | `[]` | Allow pods on nodes with matching taints |
| postgrest.volumeMounts | list | `[]` | Additional volume mounts for containers |
| postgrest.volumes | list | `[]` | Additional volumes for the deployment |
| sas-retrieval-agent-manager-api | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-api","imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":true},"livenessProbe":{"failureThreshold":15,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"api","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":1001},"readinessProbe":{"failureThreshold":5,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/readiness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":80,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Provides REST API endpoints and AI/ML processing capabilities |
| sas-retrieval-agent-manager-api.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Advanced pod scheduling rules |
| sas-retrieval-agent-manager-api.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Resource allocation and horizontal pod autoscaling resources:   limits:     # -- Maximum CPU allocation (2 cores)     cpu: ""     # -- Maximum memory allocation     memory: ""   requests:     # -- Requested CPU allocation     cpu: ""     # -- Requested memory allocation     memory: "" |
| sas-retrieval-agent-manager-api.autoscaling.enabled | bool | `false` | Disable horizontal pod autoscaling by default |
| sas-retrieval-agent-manager-api.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| sas-retrieval-agent-manager-api.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| sas-retrieval-agent-manager-api.autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling |
| sas-retrieval-agent-manager-api.fullnameOverride | string | `"sas-retrieval-agent-manager-api"` | Full resource name |
| sas-retrieval-agent-manager-api.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Image pull secrets for private registry access |
| sas-retrieval-agent-manager-api.imagePullSecrets[0] | object | `{"name":"cr-sas-secret"}` | Secret for accessing SAS container registry |
| sas-retrieval-agent-manager-api.ingress | object | `{"annotations":{"kubernetes.io/ingress.allow-http":"false","kubernetes.io/tls-acme":"true","nginx.ingress.kubernetes.io/auth-response-headers":"Authorization,X-Auth-Request-Access-Token","nginx.ingress.kubernetes.io/auth-signin":"https://$host/SASRetrievalAgentManager/oauth2/start?rd=$escaped_request_uri","nginx.ingress.kubernetes.io/auth-url":"https://$host/SASRetrievalAgentManager/oauth2/auth","nginx.ingress.kubernetes.io/proxy-body-size":"500m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k","nginx.ingress.kubernetes.io/ssl-redirect":"true"},"className":"nginx","enabled":true,"hosts":[],"paths":[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}],"tls":[],"useGlobal":true}` | Ingress configuration for external API access |
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
| sas-retrieval-agent-manager-api.ingress.enabled | bool | `true` | Enable ingress for external access |
| sas-retrieval-agent-manager-api.ingress.hosts | list | `[]` | Hosts configuration (used when useGlobal is false) |
| sas-retrieval-agent-manager-api.ingress.paths | list | `[{"path":"/SASRetrievalAgentManager/api(/|$)(.*)","pathType":"ImplementationSpecific"}]` | Paths configuration (used when useGlobal is true) |
| sas-retrieval-agent-manager-api.ingress.tls | list | `[]` | TLS configuration for ingress |
| sas-retrieval-agent-manager-api.ingress.useGlobal | bool | `true` | Use global ingress configuration instead of local hosts configuration |
| sas-retrieval-agent-manager-api.livenessProbe | object | `{"failureThreshold":15,"httpGet":{"path":"/SASRetrievalAgentManager/api/v1/health/liveness","port":"http","scheme":"HTTP"},"initialDelaySeconds":120,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Health check probes for container lifecycle management |
| sas-retrieval-agent-manager-api.livenessProbe.failureThreshold | int | `15` | High threshold for slow startup |
| sas-retrieval-agent-manager-api.livenessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/liveness"` | API liveness endpoint |
| sas-retrieval-agent-manager-api.livenessProbe.httpGet.port | string | `"http"` | Use the http port |
| sas-retrieval-agent-manager-api.livenessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| sas-retrieval-agent-manager-api.livenessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| sas-retrieval-agent-manager-api.livenessProbe.periodSeconds | int | `10` | How often to perform the probe |
| sas-retrieval-agent-manager-api.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful |
| sas-retrieval-agent-manager-api.livenessProbe.timeoutSeconds | int | `1` | Timeout for the probe |
| sas-retrieval-agent-manager-api.nameOverride | string | `"api"` | Short name for resources |
| sas-retrieval-agent-manager-api.nodeSelector | object | `{}` | Schedule pods on nodes with specific labels |
| sas-retrieval-agent-manager-api.podAnnotations | object | `{}` | Pod-level annotations |
| sas-retrieval-agent-manager-api.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod-level labels |
| sas-retrieval-agent-manager-api.podSecurityContext | object | `{"fsGroup":1001}` | Pod security context (applies to entire pod) |
| sas-retrieval-agent-manager-api.podSecurityContext.fsGroup | int | `1001` | File system group ID for volume permissions |
| sas-retrieval-agent-manager-api.readinessProbe.failureThreshold | int | `5` | Readiness failure threshold |
| sas-retrieval-agent-manager-api.readinessProbe.httpGet.path | string | `"/SASRetrievalAgentManager/api/v1/health/readiness"` | API readiness endpoint |
| sas-retrieval-agent-manager-api.readinessProbe.httpGet.port | string | `"http"` | Use the http port |
| sas-retrieval-agent-manager-api.readinessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| sas-retrieval-agent-manager-api.readinessProbe.initialDelaySeconds | int | `120` | Initial delay before starting probes |
| sas-retrieval-agent-manager-api.readinessProbe.periodSeconds | int | `10` | Probe frequency |
| sas-retrieval-agent-manager-api.readinessProbe.successThreshold | int | `1` | Success threshold |
| sas-retrieval-agent-manager-api.readinessProbe.timeoutSeconds | int | `1` | Probe timeout |
| sas-retrieval-agent-manager-api.replicaCount | int | `1` | Single instance (scale based on load requirements) |
| sas-retrieval-agent-manager-api.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":1001,"runAsNonRoot":true,"runAsUser":1001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to API container) |
| sas-retrieval-agent-manager-api.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| sas-retrieval-agent-manager-api.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| sas-retrieval-agent-manager-api.securityContext.privileged | bool | `false` | Run as non-privileged container |
| sas-retrieval-agent-manager-api.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for application data |
| sas-retrieval-agent-manager-api.securityContext.runAsGroup | int | `1001` | Run as specific non-root group |
| sas-retrieval-agent-manager-api.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| sas-retrieval-agent-manager-api.securityContext.runAsUser | int | `1001` | Run as specific non-root user |
| sas-retrieval-agent-manager-api.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| sas-retrieval-agent-manager-api.service | object | `{"port":80,"type":"ClusterIP"}` | Kubernetes service configuration |
| sas-retrieval-agent-manager-api.service.port | int | `80` | API service port |
| sas-retrieval-agent-manager-api.service.type | string | `"ClusterIP"` | Service type (internal cluster access) |
| sas-retrieval-agent-manager-api.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| sas-retrieval-agent-manager-api.serviceAccount.annotations | object | `{}` | Service account annotations |
| sas-retrieval-agent-manager-api.serviceAccount.create | bool | `true` | Create a service account for the API |
| sas-retrieval-agent-manager-api.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| sas-retrieval-agent-manager-api.tolerations | list | `[]` | Allow pods on nodes with matching taints |
| sas-retrieval-agent-manager-api.volumeMounts | list | `[]` | Additional volume mounts for containers |
| sas-retrieval-agent-manager-api.volumes | list | `[]` | Additional volumes for the deployment |
| sas-retrieval-agent-manager-app | object | `{"affinity":{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"fullnameOverride":"sas-retrieval-agent-manager-app","imagePullSecrets":[{"name":"cr-sas-secret"}],"ingress":{"useGlobal":true},"livenessProbe":{"failureThreshold":9,"httpGet":{"path":"/health","port":"http","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"nameOverride":"app","nodeSelector":{},"podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001},"readinessProbe":{"failureThreshold":9,"httpGet":{"path":"/health","port":"http","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"replicaCount":1,"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"service":{"port":8080,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":true,"name":""},"tolerations":[],"volumeMounts":[],"volumes":[]}` | Frontend user interface for the platform |
| sas-retrieval-agent-manager-app.affinity | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"preference":{"matchExpressions":[{"key":"sas.com/deployment","operator":"In","values":["sas-retrieval-agent-manager"]}]},"weight":1},{"preference":{"matchExpressions":[{"key":"workload.sas.com/class","operator":"In","values":["ram"]}]},"weight":2}]}}` | Advanced pod scheduling rules |
| sas-retrieval-agent-manager-app.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Resource allocation and horizontal pod autoscaling resources:   limits:     # -- Maximum CPU allocation     cpu: ""     # -- Maximum memory allocation     memory: ""   requests:     # -- Requested CPU allocation     cpu: ""     # -- Requested memory allocation     memory: "" |
| sas-retrieval-agent-manager-app.autoscaling.enabled | bool | `false` | Disable horizontal pod autoscaling by default |
| sas-retrieval-agent-manager-app.autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| sas-retrieval-agent-manager-app.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| sas-retrieval-agent-manager-app.autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling |
| sas-retrieval-agent-manager-app.fullnameOverride | string | `"sas-retrieval-agent-manager-app"` | Full resource name |
| sas-retrieval-agent-manager-app.imagePullSecrets | list | `[{"name":"cr-sas-secret"}]` | Image pull secrets for private registry access |
| sas-retrieval-agent-manager-app.ingress | object | `{"useGlobal":true}` | Ingress configuration for external web access |
| sas-retrieval-agent-manager-app.ingress.useGlobal | bool | `true` | Use global ingress configuration from parent chart |
| sas-retrieval-agent-manager-app.livenessProbe | object | `{"failureThreshold":9,"httpGet":{"path":"/health","port":"http","scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Health check probes for container lifecycle management |
| sas-retrieval-agent-manager-app.livenessProbe.failureThreshold | int | `9` | Failure threshold before restart |
| sas-retrieval-agent-manager-app.livenessProbe.httpGet.path | string | `"/health"` | Web app liveness endpoint |
| sas-retrieval-agent-manager-app.livenessProbe.httpGet.port | string | `"http"` | Use the http port |
| sas-retrieval-agent-manager-app.livenessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| sas-retrieval-agent-manager-app.livenessProbe.periodSeconds | int | `10` | Probe frequency |
| sas-retrieval-agent-manager-app.livenessProbe.successThreshold | int | `1` | Success threshold |
| sas-retrieval-agent-manager-app.livenessProbe.timeoutSeconds | int | `1` | Probe timeout |
| sas-retrieval-agent-manager-app.nameOverride | string | `"app"` | Short name for resources |
| sas-retrieval-agent-manager-app.nodeSelector | object | `{}` | Schedule pods on nodes with specific labels |
| sas-retrieval-agent-manager-app.podAnnotations | object | `{}` | Pod-level annotations |
| sas-retrieval-agent-manager-app.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod-level labels |
| sas-retrieval-agent-manager-app.podSecurityContext | object | `{"fsGroup":10001}` | Pod security context (applies to entire pod) |
| sas-retrieval-agent-manager-app.podSecurityContext.fsGroup | int | `10001` | File system group for volume permissions |
| sas-retrieval-agent-manager-app.readinessProbe.failureThreshold | int | `9` | Failure threshold before marking not ready |
| sas-retrieval-agent-manager-app.readinessProbe.httpGet.path | string | `"/health"` | Web app readiness endpoint |
| sas-retrieval-agent-manager-app.readinessProbe.httpGet.port | string | `"http"` | Use the http port |
| sas-retrieval-agent-manager-app.readinessProbe.httpGet.scheme | string | `"HTTP"` | HTTP scheme |
| sas-retrieval-agent-manager-app.readinessProbe.periodSeconds | int | `10` | Probe frequency |
| sas-retrieval-agent-manager-app.readinessProbe.successThreshold | int | `1` | Success threshold |
| sas-retrieval-agent-manager-app.readinessProbe.timeoutSeconds | int | `1` | Probe timeout |
| sas-retrieval-agent-manager-app.replicaCount | int | `1` | Single instance (can be scaled for higher availability) |
| sas-retrieval-agent-manager-app.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to web app container) |
| sas-retrieval-agent-manager-app.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| sas-retrieval-agent-manager-app.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| sas-retrieval-agent-manager-app.securityContext.privileged | bool | `false` | Run as non-privileged container |
| sas-retrieval-agent-manager-app.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for application data |
| sas-retrieval-agent-manager-app.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| sas-retrieval-agent-manager-app.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| sas-retrieval-agent-manager-app.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| sas-retrieval-agent-manager-app.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| sas-retrieval-agent-manager-app.service | object | `{"port":8080,"type":"ClusterIP"}` | Kubernetes service configuration |
| sas-retrieval-agent-manager-app.service.port | int | `8080` | Web application service port |
| sas-retrieval-agent-manager-app.service.type | string | `"ClusterIP"` | Service type (internal cluster access) |
| sas-retrieval-agent-manager-app.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| sas-retrieval-agent-manager-app.serviceAccount.annotations | object | `{}` | Service account annotations |
| sas-retrieval-agent-manager-app.serviceAccount.create | bool | `true` | Create a service account for the web app |
| sas-retrieval-agent-manager-app.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| sas-retrieval-agent-manager-app.tolerations | list | `[]` | Allow pods on nodes with matching taints |
| sas-retrieval-agent-manager-app.volumeMounts | list | `[]` | Additional volume mounts for containers |
| sas-retrieval-agent-manager-app.volumes | list | `[]` | Additional volumes for the deployment |
| sas-retrieval-agent-manager-db-init | object | `{"fullnameOverride":"sas-retrieval-agent-manager-db-init","imagePullSecrets":[],"nameOverride":"initialization","podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"create":true,"name":""}}` | Initializes databases and schemas for the entire platform |
| sas-retrieval-agent-manager-db-init.fullnameOverride | string | `"sas-retrieval-agent-manager-db-init"` | Full resource name |
| sas-retrieval-agent-manager-db-init.imagePullSecrets | list | `[]` | Image pull secrets for private registry access |
| sas-retrieval-agent-manager-db-init.nameOverride | string | `"initialization"` | Override default resource name prefix |
| sas-retrieval-agent-manager-db-init.podAnnotations | object | `{}` | Pod-level annotations |
| sas-retrieval-agent-manager-db-init.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod-level labels |
| sas-retrieval-agent-manager-db-init.podSecurityContext | object | `{"fsGroup":10001}` | Pod security context (applies to entire pod) |
| sas-retrieval-agent-manager-db-init.podSecurityContext.fsGroup | int | `10001` | File system group for volume permissions |
| sas-retrieval-agent-manager-db-init.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to init containers) |
| sas-retrieval-agent-manager-db-init.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| sas-retrieval-agent-manager-db-init.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| sas-retrieval-agent-manager-db-init.securityContext.privileged | bool | `false` | Run as non-privileged container |
| sas-retrieval-agent-manager-db-init.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for database operations |
| sas-retrieval-agent-manager-db-init.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| sas-retrieval-agent-manager-db-init.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| sas-retrieval-agent-manager-db-init.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| sas-retrieval-agent-manager-db-init.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| sas-retrieval-agent-manager-db-init.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| sas-retrieval-agent-manager-db-init.serviceAccount.annotations | object | `{}` | Service account annotations |
| sas-retrieval-agent-manager-db-init.serviceAccount.create | bool | `true` | Create a service account for database operations |
| sas-retrieval-agent-manager-db-init.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |
| sas-retrieval-agent-manager-db-migration | object | `{"fullnameOverride":"sas-retrieval-agent-manager-db-migration","imagePullSecrets":[],"nameOverride":"db-migration","podAnnotations":{},"podLabels":{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"},"podSecurityContext":{"fsGroup":10001},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"create":true,"name":""}}` | Manages database schema migrations using Goose migration tool |
| sas-retrieval-agent-manager-db-migration.fullnameOverride | string | `"sas-retrieval-agent-manager-db-migration"` | Full resource name |
| sas-retrieval-agent-manager-db-migration.imagePullSecrets | list | `[]` | Image pull secrets for private registry access |
| sas-retrieval-agent-manager-db-migration.nameOverride | string | `"db-migration"` | Override default resource name prefix |
| sas-retrieval-agent-manager-db-migration.podAnnotations | object | `{}` | Pod-level annotations |
| sas-retrieval-agent-manager-db-migration.podLabels | object | `{"sas.com/deployment":"sas-retrieval-agent-manager","workload.sas.com/class":"ram"}` | Pod-level labels |
| sas-retrieval-agent-manager-db-migration.podSecurityContext | object | `{"fsGroup":10001}` | Pod security context (applies to entire pod) |
| sas-retrieval-agent-manager-db-migration.podSecurityContext.fsGroup | int | `10001` | File system group for volume permissions |
| sas-retrieval-agent-manager-db-migration.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":false,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context (applies to migration containers) |
| sas-retrieval-agent-manager-db-migration.securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| sas-retrieval-agent-manager-db-migration.securityContext.capabilities.drop | list | `["ALL"]` | Drop all Linux capabilities |
| sas-retrieval-agent-manager-db-migration.securityContext.privileged | bool | `false` | Run as non-privileged container |
| sas-retrieval-agent-manager-db-migration.securityContext.readOnlyRootFilesystem | bool | `false` | Allow writes for migration operations |
| sas-retrieval-agent-manager-db-migration.securityContext.runAsGroup | int | `10001` | Run as specific non-root group |
| sas-retrieval-agent-manager-db-migration.securityContext.runAsNonRoot | bool | `true` | Ensure container runs as non-root |
| sas-retrieval-agent-manager-db-migration.securityContext.runAsUser | int | `10001` | Run as specific non-root user |
| sas-retrieval-agent-manager-db-migration.securityContext.seccompProfile.type | string | `"RuntimeDefault"` | Use default seccomp profile |
| sas-retrieval-agent-manager-db-migration.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service account configuration |
| sas-retrieval-agent-manager-db-migration.serviceAccount.annotations | object | `{}` | Service account annotations |
| sas-retrieval-agent-manager-db-migration.serviceAccount.create | bool | `true` | Create a service account for migration operations |
| sas-retrieval-agent-manager-db-migration.serviceAccount.name | string | `""` | Service account name (auto-generated if empty) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
