{{/*
Expand the name of the chart.
*/}}
{{- define "sas-retrieval-agent-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sas-retrieval-agent-manager.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sas-retrieval-agent-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
connection-validation is to verify that argo is pulling from the correct branch
*/}}
{{- define "sas-retrieval-agent-manager.labels" -}}
helm.sh/chart: {{ include "sas-retrieval-agent-manager.chart" . }}
{{ include "sas-retrieval-agent-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/connection-validation: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sas-retrieval-agent-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sas-retrieval-agent-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sas-retrieval-agent-manager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sas-retrieval-agent-manager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a full repo from repo_base and repo_path, can have it default to something in the future
*/}}
{{- define "sas-retrieval-agent-manager.repository" -}}
{{- if and .Values.global.repo_base .Values.global.repo_path -}}
{{- printf "%s/%s" .Values.global.repo_base .Values.global.repo_path -}}
{{- else -}}
{{- fail "Both repo_base and repo_path must be provided" -}}
{{- end -}}
{{- end -}}