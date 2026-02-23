{{/*
Expand the name of the chart.
*/}}
{{- define "db-initialization.name" -}}
{{- printf "%s-db-init" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "db-initialization.fullname" -}}
{{- printf "%s-db-init" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "db-initialization.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "db-initialization.labels" -}}
helm.sh/chart: {{ include "db-initialization.chart" . }}
{{ include "db-initialization.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "db-initialization.selectorLabels" -}}
app.kubernetes.io/name: {{ include "db-initialization.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: db-init
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "db-initialization.serviceAccountName" -}}
{{- if .Values.db.init.serviceAccount.create }}
{{- default (include "db-initialization.fullname" .) .Values.db.init.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.db.init.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.db-initialization
Usage: {{ include "testValuesPath" (list .Values.db-initialization "x" "y" "z") }}
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
