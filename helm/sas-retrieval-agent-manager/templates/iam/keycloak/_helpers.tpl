{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak.name" -}}
{{- printf "%s-keycloak" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak.fullname" -}}
{{- printf "%s-keycloak" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: keycloak
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.iam.keycloak.serviceAccount.create }}
{{- default (include "keycloak.fullname" .) .Values.iam.keycloak.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.iam.keycloak.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the client secret
*/}}
{{- define "keycloak.clientSecret" -}}
{{- if .Values.iam.keycloak.config.clientSecret -}}
  {{- .Values.iam.keycloak.config.clientSecret }}
{{- else -}}
  {{- $clientSecretName := printf "%s-client-secret" (include "keycloak.fullname" .) -}}
  {{- $clientSecret := lookup "v1" "Secret" .Release.Namespace $clientSecretName -}}
  {{- if and $clientSecret (index $clientSecret.data "sv-client-secret") -}}
      {{- (index $clientSecret.data "sv-client-secret") | b64dec -}}
  {{- else -}}
      {{- $newClientSecret := randAlphaNum 32 | b64enc | replace "+" "-" | replace "/" "_" | replace "=" "" -}}
      {{- $newClientSecret -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Check if a nested path exists in .Values.keycloak
Usage: {{ include "testValuesPath" (list .Values.keycloak "x" "y" "z") }}
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
Default startup probe configuration for Keycloak
Note: Keycloak 17+ management interface uses HTTPS on port 9000
*/}}
{{- define "keycloak.defaultStartupProbe" -}}
httpGet:
  path: /health/started
  port: 9000
  scheme: HTTPS
{{- end }}

{{/*
Default liveness probe configuration for Keycloak
*/}}
{{- define "keycloak.defaultLivenessProbe" -}}
httpGet:
  path: /health/live
  port: 9000
  scheme: HTTPS
{{- end }}

{{/*
Default readiness probe configuration for Keycloak
*/}}
{{- define "keycloak.defaultReadinessProbe" -}}
httpGet:
  path: /health/ready
  port: 9000
  scheme: HTTPS
{{- end }}

{{/*
Merged startup probe - combines defaults with user values
*/}}
{{- define "keycloak.startupProbe" -}}
{{- $default := fromYaml (include "keycloak.defaultStartupProbe" .) }}
{{- $custom := .Values.iam.keycloak.startupProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged liveness probe - combines defaults with user values
*/}}
{{- define "keycloak.livenessProbe" -}}
{{- $default := fromYaml (include "keycloak.defaultLivenessProbe" .) }}
{{- $custom := .Values.iam.keycloak.livenessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}

{{/*
Merged readiness probe - combines defaults with user values
*/}}
{{- define "keycloak.readinessProbe" -}}
{{- $default := fromYaml (include "keycloak.defaultReadinessProbe" .) }}
{{- $custom := .Values.iam.keycloak.readinessProbe | default dict }}
{{- toYaml (merge (deepCopy $custom) (deepCopy $default)) }}
{{- end }}
