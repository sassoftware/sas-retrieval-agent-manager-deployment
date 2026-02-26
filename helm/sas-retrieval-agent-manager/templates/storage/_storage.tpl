
{{/*
Expand the name of the chart.
*/}}
{{- define "storage.name" -}}
{{- printf "%s-storage" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "storage.fullname" -}}
{{- printf "%s-storage" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "storage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "storage.labels" -}}
helm.sh/chart: {{ include "storage.chart" . }}
{{ include "storage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "storage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "storage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: storage
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Check if a nested path exists in .Values.storage
Usage: {{ include "testValuesPath" (list .Values.storage "x" "y" "z") }}
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
