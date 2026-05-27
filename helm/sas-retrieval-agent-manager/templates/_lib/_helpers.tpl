{{/*
Expand the name of the chart.
*/}}
{{- define "retrieval-agent-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "retrieval-agent-manager.fullname" -}}
{{- if .Values.name }}
{{- .Values.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "retrieval-agent-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
connection-validation is to verify that argo is pulling from the correct branch
*/}}
{{- define "retrieval-agent-manager.labels" -}}
helm.sh/chart: {{ include "retrieval-agent-manager.chart" . }}
{{ include "retrieval-agent-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/connection-validation: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "retrieval-agent-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "retrieval-agent-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render a pod security context, stripping runAsUser/runAsGroup/runAsNonRoot on OpenShift
so the SCC assigns them from the namespace UID range automatically.
fsGroup is retained so Kubernetes triggers volume ownership chown on EBS/PVC mounts.
Usage: {{ include "ram.podSecurityContext" (list .Values.X.podSecurityContext .Values.platform) | nindent 8 }}
*/}}
{{- define "ram.podSecurityContext" -}}
{{- $sc := index . 0 -}}
{{- $platform := index . 1 -}}
{{- if eq $platform "openshift" -}}
{{- omit $sc "runAsUser" "runAsGroup" "runAsNonRoot" | toYaml -}}
{{- else -}}
{{- $sc | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Render a container security context, stripping runAsUser/runAsGroup on OpenShift.
Usage: {{ include "ram.securityContext" (list .Values.X.securityContext .Values.platform) | nindent 12 }}
*/}}
{{- define "ram.securityContext" -}}
{{- $sc := index . 0 -}}
{{- $platform := index . 1 -}}
{{- if eq $platform "openshift" -}}
{{- omit $sc "runAsUser" "runAsGroup" "runAsNonRoot" | toYaml -}}
{{- else -}}
{{- $sc | toYaml -}}
{{- end -}}
{{- end -}}
