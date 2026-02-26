{{/*
Expand the name of the chart.
*/}}
{{- define "gpg.name" -}}
{{- printf "%s-gpg" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gpg.fullname" -}}
{{- printf "%s-gpg" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gpg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gpg.labels" -}}
helm.sh/chart: {{ include "gpg.chart" . }}
{{ include "gpg.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gpg.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gpg.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: gpg
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gpg.serviceAccountName" -}}
{{- if .Values.security.gpg.serviceAccount.create }}
{{- default (include "gpg.fullname" .) .Values.security.gpg.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.security.gpg.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.security.gpg
Usage: {{ include "testValuesPath" (list .Values.security.gpg "x" "y" "z") }}
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
Check if GPG keys need to be generated (when both keys are not provided, or only one is provided)
*/}}
{{- define "gpg.shouldGenerateKeys" -}}
{{- $publicKey := "" -}}
{{- $privateKey := "" -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "security" "gpg" "config" "publicKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.publicKey "" -}}
    {{- $publicKey = .Values.security.gpg.config.publicKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "security" "gpg" "config" "privateKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.privateKey "" -}}
    {{- $privateKey = .Values.security.gpg.config.privateKey -}}
  {{- end -}}
{{- end -}}
{{- $hasPublic := ne $publicKey "" -}}
{{- $hasPrivate := ne $privateKey "" -}}
{{- not (and $hasPublic $hasPrivate) -}}
{{- end }}

{{/*
Check if existing GPG public key is available (non-empty)
*/}}
{{- define "gpg.hasPublicKey" -}}
{{- $publicKey := "" -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "security" "gpg" "config" "publicKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.publicKey "" -}}
    {{- $publicKey = .Values.security.gpg.config.publicKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "config" "publicKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.publicKey "" -}}
    {{- $publicKey = .Values.security.gpg.config.publicKey -}}
  {{- end -}}
{{- end -}}
{{- ne $publicKey "" -}}
{{- end }}

{{/*
Check if existing GPG private key is available (non-empty)
*/}}
{{- define "gpg.hasPrivateKey" -}}
{{- $privateKey := "" -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "security" "gpg" "config" "privateKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.privateKey "" -}}
    {{- $privateKey = .Values.security.gpg.config.privateKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.security.gpg "config" "privateKey")) | eq "true" -}}
  {{- if ne .Values.security.gpg.config.privateKey "" -}}
    {{- $privateKey = .Values.security.gpg.config.privateKey -}}
  {{- end -}}
{{- end -}}
{{- ne $privateKey "" -}}
{{- end }}
