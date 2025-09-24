{{/*
Expand the name of the chart.
*/}}
{{- define "postgrest.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "postgrest.swagger.name" -}}
{{- $defaultPostgrestName := printf "swagger-%s" .Chart.Name -}}
{{- default $defaultPostgrestName .Values.swagger.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgrest.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "postgrest.swagger.fullname" -}}
{{- if .Values.swagger.fullnameOverride }}
{{- .Values.swagger.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $defaultPostgrestName := printf "swagger-%s" .Chart.Name -}}
{{- $swaggerName := default $defaultPostgrestName .Values.swagger.nameOverride }}
{{- if printf "swagger-%s" .Release.Name | contains $swaggerName }}
{{- printf "swagger-%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "swagger-%s-%s" $swaggerName .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
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

{{- define "postgrest.swagger.labels" -}}
helm.sh/chart: {{ include "postgrest.chart" . }}
{{ include "postgrest.swagger.selectorLabels" . }}
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
{{- end }}

{{- define "postgrest.swagger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgrest.swagger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgrest.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgrest.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgrest.swagger.serviceAccountName" -}}
{{- if .Values.swagger.serviceAccount.create }}
{{- default (include "postgrest.swagger.fullname" .) .Values.swagger.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.swagger.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values
Usage: {{ include "testValuesPath" (list .Values "x" "y" "z") }}
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
