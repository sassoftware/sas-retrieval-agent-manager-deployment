{{/*
Expand the name of the chart.
*/}}
{{- define "gpg.name" -}}
{{- printf "%s-gpg" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
If security.gpg.nameOverride is set, it replaces the chart fullname as the
base, producing: <nameOverride>-gpg
Otherwise falls through to the standard chart fullname: <fullname>-gpg
Must match the BASE_NAME / GPG_FULLNAME logic in bootstrap-gpg.sh exactly.
*/}}
{{- define "gpg.fullname" -}}
{{- if and .Values.security.gpg.nameOverride (ne .Values.security.gpg.nameOverride "") -}}
{{- printf "%s-gpg" .Values.security.gpg.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{- printf "%s-gpg" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}
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
