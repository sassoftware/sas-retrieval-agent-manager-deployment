{{/*
Expand the name of the chart.
*/}}
{{- define "postgrest.name" -}}
{{- printf "%s-postgrest" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgrest.fullname" -}}
{{- printf "%s-postgrest" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgrest.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "postgrest.labels" -}}
helm.sh/chart: {{ include "postgrest.chart" . }}
{{ include "postgrest.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgrest.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgrest.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: postgrest
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgrest.serviceAccountName" -}}
{{- if .Values.db.rest.serviceAccount.create }}
{{- .Values.db.rest.serviceAccount.name | default (include "postgrest.fullname" .) }}
{{- else }}
{{- .Values.db.rest.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.postgrest
Usage: {{ include "testValuesPath" (list .Values.postgrest "x" "y" "z") }}
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
{{- define "postgrest.defaultLivenessProbe" -}}
# -- HTTP GET probe configuration for liveness
httpGet:
  # -- Path to probe for liveness
  path: /live
  # -- Port to probe on
  port: admin
  # -- HTTP scheme to use
  scheme: HTTP
{{- end }}

{{/*
Default readiness probe configuration for API
*/}}
{{- define "postgrest.defaultLivenessProbeMonitoring" -}}
# -- HTTP GET probe configuration for liveness
httpGet:
  # -- Path to probe for liveness
  path: /live
  # -- Port to probe on
  port: admin-monitor
  # -- HTTP scheme to use
  scheme: HTTP
{{- end }}

{{/*
Default liveness probe configuration for API
*/}}
{{- define "postgrest.defaultReadinessProbe" -}}
# -- HTTP GET probe configuration for readiness
httpGet:
  # -- Path to probe for readiness
  path: /ready
  # -- Port to probe on
  port: admin
  # -- HTTP scheme to use
  scheme: HTTP
{{- end }}

{{/*
Default readiness probe configuration for API
*/}}
{{- define "postgrest.defaultReadinessProbeMonitoring" -}}
# -- HTTP GET probe configuration for readiness
httpGet:
  # -- Path to probe for readiness
  path: /ready
  # -- Port to probe on
  port: admin-monitor
  # -- HTTP scheme to use
  scheme: HTTP
{{- end }}

{{/*
Merged liveness probe - combines defaults with user values
*/}}
{{- define "postgrest.livenessProbe" -}}
{{- $default := fromYaml (include "postgrest.defaultLivenessProbe" .) }}
{{- $custom := .Values.db.rest.livenessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged readiness probe - combines defaults with user values
*/}}
{{- define "postgrest.readinessProbe" -}}
{{- $default := fromYaml (include "postgrest.defaultReadinessProbe" .) }}
{{- $custom := .Values.db.rest.readinessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged liveness probe - combines defaults with user values
*/}}
{{- define "postgrest.livenessProbeMonitoring" -}}
{{- $default := fromYaml (include "postgrest.defaultLivenessProbeMonitoring" .) }}
{{- $custom := .Values.db.rest.livenessProbeMonitoring | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged readiness probe - combines defaults with user values
*/}}
{{- define "postgrest.readinessProbeMonitoring" -}}
{{- $default := fromYaml (include "postgrest.defaultReadinessProbeMonitoring" .) }}
{{- $custom := .Values.db.rest.readinessProbeMonitoring | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}
