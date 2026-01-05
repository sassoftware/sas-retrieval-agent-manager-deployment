{{/*
Expand the name of the chart.
*/}}
{{- define "gpg.name" -}}
{{- if .Values.gpg.nameOverride }}
{{- .Values.gpg.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-gpg" (include "sas-retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gpg.fullname" -}}
{{- if .Values.gpg.fullnameOverride }}
{{- .Values.gpg.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-gpg" (include "sas-retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
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
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gpg.serviceAccountName" -}}
{{- if (index .Values "gpg").serviceAccount.create }}
{{- default (include "gpg.fullname" .) (index .Values "gpg").serviceAccount.name }}
{{- else }}
{{- default "default" (index .Values "gpg").serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.gpg
Usage: {{ include "testValuesPath" (list .Values.gpg "x" "y" "z") }}
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
{{- if (include "testValuesPath" (list .Values.gpg "global" "configuration" "gpg" "publicKey")) | eq "true" -}}
  {{- if ne .Values.global.configuration.gpg.publicKey "" -}}
    {{- $publicKey = .Values.global.configuration.gpg.publicKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.gpg "global" "configuration" "gpg" "privateKey")) | eq "true" -}}
  {{- if ne .Values.global.configuration.gpg.privateKey "" -}}
    {{- $privateKey = .Values.global.configuration.gpg.privateKey -}}
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
{{- if (include "testValuesPath" (list .Values.gpg "global" "configuration" "gpg" "publicKey")) | eq "true" -}}
  {{- if ne .Values.global.configuration.gpg.publicKey "" -}}
    {{- $publicKey = .Values.global.configuration.gpg.publicKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.gpg "gpg" "publicKey")) | eq "true" -}}
  {{- if ne .Values.gpg.publicKey "" -}}
    {{- $publicKey = .Values.gpg.publicKey -}}
  {{- end -}}
{{- end -}}
{{- ne $publicKey "" -}}
{{- end }}

{{/*
Check if existing GPG private key is available (non-empty)
*/}}
{{- define "gpg.hasPrivateKey" -}}
{{- $privateKey := "" -}}
{{- if (include "testValuesPath" (list .Values.gpg "global" "configuration" "gpg" "privateKey")) | eq "true" -}}
  {{- if ne .Values.global.configuration.gpg.privateKey "" -}}
    {{- $privateKey = .Values.global.configuration.gpg.privateKey -}}
  {{- end -}}
{{- end -}}
{{- if (include "testValuesPath" (list .Values.gpg "gpg" "privateKey")) | eq "true" -}}
  {{- if ne .Values.gpg.privateKey "" -}}
    {{- $privateKey = .Values.gpg.privateKey -}}
  {{- end -}}
{{- end -}}
{{- ne $privateKey "" -}}
{{- end }}
