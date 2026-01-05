
{{/*
Expand the name of the chart.
*/}}
{{- define "storage.name" -}}
{{- if .Values.filebrowser.nameOverride }}
{{- .Values.filebrowser.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-filebrowser" (include "sas-retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "storage.fullname" -}}
{{- if .Values.filebrowser.fullnameOverride }}
{{- .Values.filebrowser.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-storage" (include "sas-retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
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
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "storage.serviceAccountName" -}}
{{- if (index .Values "filebrowser").serviceAccount.create }}
{{- default (include "storage.fullname" .) (index .Values "filebrowser").serviceAccount.name }}
{{- else }}
{{- default "default" (index .Values "filebrowser").serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if a nested path exists in .Values.filebrowser
Usage: {{ include "testValuesPath" (list .Values.filebrowser "x" "y" "z") }}
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
Implement logic to determine storage class
and whether to create it based on target platform
*/}}
{{- define "storage.storageConfig" -}}
{{- $platform := .Values.global.targetPlatform }}
{{- $userSC := (index .Values "filebrowser").rootDir.pvc.storageClassName | default "" }}
{{- $storageClass := $userSC }}
{{- $createSC := (index .Values "filebrowser").rootDir.pvc.createStorageClass | default false }}

{{- if or (eq $userSC "") (eq $userSC nil) }}
  {{- if eq $platform "azure" }}
    {{- $storageClass = "azurefile-sas" }}
    {{- $createSC = true }}
  {{- else if or (eq $platform "openshift") (eq $platform "kubernetes") }}
    {{- $storageClass = "nfs-client" }}
    {{- $createSC = false }}
  {{- else if eq $platform "aws" }}
    {{- $storageClass = "efs" }}
    {{- $createSC = false }}
  {{- else if eq $platform "gcp" }}
    {{- $storageClass = "filestore" }}
    {{- $createSC = false }}
  {{- end }}
{{- end }}

{{- printf "%s|%t" $storageClass $createSC }}
{{- end }}
