{{/*
Expand the name of the chart.
*/}}
{{- define "ui.name" -}}
{{- printf "%s-app" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ui.fullname" -}}
{{- printf "%s-app" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ui.labels" -}}
helm.sh/chart: {{ include "ui.chart" . }}
{{ include "ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: ui
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ui.serviceAccountName" -}}
{{- if .Values.ui.serviceAccount.create }}
{{- default (include "ui.fullname" .) .Values.ui.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.ui.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.retrieval-agent-manager-app
Usage: {{ include "testValuesPath" (list .Values.retrieval-agent-manager-app "x" "y" "z") }}
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
Resolve UI base path for probes and ingress-aware URLs
*/}}
{{- define "ui.uiPath" -}}
{{- $uiPath := "" -}}

{{- if .Values.ingress.enabled }}
  {{- if .Values.ingress.ui.paths }}
    {{- $uiPath = first .Values.ingress.ui.paths }}
  {{- end }}
{{- end }}

{{- default "" $uiPath -}}
{{- end }}

{{/*
Default liveness probe configuration for UI
*/}}
{{- define "ui.defaultLivenessProbe" -}}
httpGet:
  path: {{ include "ui.uiPath" . }}/health
  port: http
{{- end }}


{{/*
Default readiness probe configuration for UI
*/}}
{{- define "ui.defaultReadinessProbe" -}}
httpGet:
  path: {{ include "ui.uiPath" . }}/health
  port: http
{{- end }}


{{/*
Merged liveness probe - combines defaults with user values
*/}}
{{- define "ui.livenessProbe" -}}
{{- $default := fromYaml (include "ui.defaultLivenessProbe" .) }}
{{- $custom := .Values.ui.livenessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged readiness probe - combines defaults with user values
*/}}
{{- define "ui.readinessProbe" -}}
{{- $default := fromYaml (include "ui.defaultReadinessProbe" .) }}
{{- $custom := .Values.ui.readinessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}
