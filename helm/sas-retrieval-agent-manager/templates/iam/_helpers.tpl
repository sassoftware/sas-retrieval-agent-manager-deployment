{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak.name" -}}
{{- if .Values.keycloak.nameOverride }}
{{- .Values.keycloak.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-keycloak" (include "sas-retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak.fullname" -}}
{{- if .Values.keycloak.fullnameOverride }}
{{- .Values.keycloak.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-keycloak" (include "sas-retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
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
app.kubernetes.io/component: keycloak
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if (index .Values "keycloak").serviceAccount.create }}
{{- default (include "keycloak.fullname" .) (index .Values "keycloak").serviceAccount.name }}
{{- else }}
{{- default "default" (index .Values "keycloak").serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the client secret
*/}}
{{- define "keycloak.clientSecret" -}}
{{- if .Values.global.configuration.keycloak.clientSecret -}}
  {{- .Values.global.configuration.keycloak.clientSecret }}
{{- else -}}
  {{- $clientSecretName := "keycloak-client-secret" -}}
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
