{{/*
Expand the name of the chart.
*/}}
{{- define "api.name" -}}
{{- printf "%s-api" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "api.fullname" -}}
{{- printf "%s-api" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "api.labels" -}}
helm.sh/chart: {{ include "api.chart" . }}
{{ include "api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: api
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api.serviceAccountName" -}}
{{- if .Values.api.serviceAccount.create }}
{{- default (include "api.fullname" .) .Values.api.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.api.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api.spawn.serviceAccountName" -}}
{{- if .Values.api.spawn.serviceAccount.create }}
{{- default (printf "%s-spawn" (include "api.fullname" .)) .Values.api.spawn.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.api.spawn.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.api
Usage: {{ include "testValuesPath" (list .Values.api "x" "y" "z") }}
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

{{/*
Default liveness probe configuration for API
*/}}
{{- define "api.defaultLivenessProbe" -}}
httpGet:
  path: {{ first .Values.ingress.api.paths }}/v1/health/liveness
  port: http
  scheme: HTTP
{{- end }}

{{/*
Default readiness probe configuration for API
*/}}
{{- define "api.defaultReadinessProbe" -}}
httpGet:
  path: {{ first .Values.ingress.api.paths }}/v1/health/readiness
  port: http
  scheme: HTTP
{{- end }}

{{/*
Merged liveness probe - combines defaults with user values
*/}}
{{- define "api.livenessProbe" -}}
{{- $default := fromYaml (include "api.defaultLivenessProbe" .) }}
{{- $custom := .Values.api.livenessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged readiness probe - combines defaults with user values
*/}}
{{- define "api.readinessProbe" -}}
{{- $default := fromYaml (include "api.defaultReadinessProbe" .) }}
{{- $custom := .Values.api.readinessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}
