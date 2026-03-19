{{/*
_defaults.tpl - Set default values based on platform
*/}}

{{/*
Get the ingress class type based on platform.
Priority:
  1. If platform is openshift: "route"
  2. .Values.ingress.classType if set
  3. Infer from .Values.ingress.className if it matches a known type (contour, route, nginx)
  4. Default: "nginx"
Returns: nginx, contour, or route
*/}}
{{- define "retrieval-agent-manager.ingressClassType" -}}
{{- if and (eq .Values.platform "openshift") (not .Values.ingress.classType) -}}
route
{{- else if .Values.ingress.classType -}}
{{- .Values.ingress.classType -}}
{{- else if and .Values.ingress.className (eq .Values.ingress.className "contour") -}}
contour
{{- else if and .Values.ingress.className (eq .Values.ingress.className "route") -}}
route
{{- else -}}
nginx
{{- end -}}
{{- end -}}

{{/*
Get the ingress class name for the Kubernetes resource.
If .Values.ingress.className is set, use it.
Otherwise, default based on classType:
  - nginx: "nginx"
  - contour: "contour"
  - route: (not used, OpenShift Routes don't have ingressClassName)
*/}}
{{- define "retrieval-agent-manager.ingressClassName" -}}
{{- if .Values.ingress.className -}}
{{- .Values.ingress.className -}}
{{- else -}}
{{- include "retrieval-agent-manager.ingressClassType" . -}}
{{- end -}}
{{- end -}}

{{/*
Get the storage class name based on platform.
If .Values.storage.storageClassName is set, use it.
Otherwise, default based on .Values.platform:
  - azure: "azurefile-sas"
  - aws: "efs-sc"
  - kubernetes, openshift: "nfs-client"
*/}}
{{- define "retrieval-agent-manager.defaultStorageClassName" -}}
{{- if eq .Values.platform "azure" -}}
{{- if .Values.storage.customStorageClass.create -}}
{{- .Values.storage.customStorageClass.name -}}
{{- else -}}
azurefile-sas
{{- end -}}
{{- else if eq .Values.platform "aws" -}}
efs-sc
{{- else -}}
nfs-client
{{- end -}}
{{- end -}}

{{/*
Determine whether to create the storage class based on platform.
If .Values.storage.createStorageClass is set, use it.
Otherwise, default based on .Values.platform:
  - azure: true
  - aws, kubernetes, openshift: false
*/}}
{{- define "retrieval-agent-manager.createStorageClass" -}}
{{- if not (kindIs "invalid" .Values.storage.customStorageClass.create) -}}
{{- .Values.storage.customStorageClass.create -}}
{{- else -}}
{{- if eq .Values.platform "azure" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
{{- end -}}
