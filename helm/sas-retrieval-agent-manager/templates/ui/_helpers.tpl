{{/*
Expand the name of the chart.
*/}}
{{- define "sas-retrieval-agent-manager-ui.name" -}}
{{- if (index .Values "sas-retrieval-agent-manager-app").nameOverride }}
{{- (index .Values "sas-retrieval-agent-manager-app").nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-app" (include "sas-retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sas-retrieval-agent-manager-ui.fullname" -}}
{{- if (index .Values "sas-retrieval-agent-manager-app").fullnameOverride }}
{{- (index .Values "sas-retrieval-agent-manager-app").fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-app" (include "sas-retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sas-retrieval-agent-manager-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sas-retrieval-agent-manager-ui.labels" -}}
helm.sh/chart: {{ include "sas-retrieval-agent-manager-ui.chart" . }}
{{ include "sas-retrieval-agent-manager-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sas-retrieval-agent-manager-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sas-retrieval-agent-manager-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sas-retrieval-agent-manager-ui.serviceAccountName" -}}
{{- if (index .Values "sas-retrieval-agent-manager-app").serviceAccount.create }}
{{- default (include "sas-retrieval-agent-manager-ui.fullname" .) (index .Values "sas-retrieval-agent-manager-app").serviceAccount.name }}
{{- else }}
{{- default "default" (index .Values "sas-retrieval-agent-manager-app").serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.sas-retrieval-agent-manager-app
Usage: {{ include "testValuesPath" (list .Values.sas-retrieval-agent-manager-app "x" "y" "z") }}
*/}}
{{- define "testValuesPath" -}}
{{- $root := index . 0 -}}
{{- $keys := rest . -}}
{{- $current := $root -}}
{{- $exists := true -}}
{{- range $key := $keys }}
  {{- if and $exists (kindIs "map" $current) (hasKey $current $key) }}
    {{- $current = index $current $key -}}
  {{- else }}
    {{- $exists = false -}}
  {{- end }}
{{- end }}
{{- $exists }}
{{- end }}
