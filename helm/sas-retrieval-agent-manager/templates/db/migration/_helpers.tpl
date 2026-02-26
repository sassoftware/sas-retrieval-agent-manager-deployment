{{/*
Expand the name of the chart.
*/}}
{{- define "db-migration.name" -}}
{{- printf "%s-db-migration" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "db-migration.fullname" -}}
{{- printf "%s-db-migration" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "db-migration.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "db-migration.labels" -}}
helm.sh/chart: {{ include "db-migration.chart" . }}
{{ include "db-migration.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "db-migration.selectorLabels" -}}
app.kubernetes.io/name: {{ include "db-migration.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: db-migration
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "db-migration.serviceAccountName" -}}
{{- if .Values.db.migration.serviceAccount.create }}
{{- default (include "db-migration.fullname" .) .Values.db.migration.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.db.migration.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.db-migration
Usage: {{ include "testValuesPath" (list .Values.db-migration "x" "y" "z") }}
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
