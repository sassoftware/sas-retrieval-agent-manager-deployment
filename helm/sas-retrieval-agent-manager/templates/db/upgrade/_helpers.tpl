{{/*
Expand the name of the chart.
*/}}
{{- define "upgrade.name" -}}
{{- printf "%s-upgrade" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "upgrade.fullname" -}}
{{- printf "%s-upgrade" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "upgrade.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "upgrade.labels" -}}
helm.sh/chart: {{ include "upgrade.chart" . }}
{{ include "upgrade.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels

Deliberately no `app.kubernetes.io/component` here. The upgrade component has two distinct
workloads, cleanup and validation, and each sets its own component label. Emitting a generic
one here too produced a duplicate mapping key in every rendered object.
*/}}
{{- define "upgrade.selectorLabels" -}}
app.kubernetes.io/name: {{ include "upgrade.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
{{- end }}

{{/*
Create the name of the service account used by the pre-upgrade cleanup job.

This is the only ServiceAccount in the upgrade component, so the name carries the component
it belongs to rather than a "-sa" suffix, matching every other ServiceAccount in the chart
("<fullname>-api", "<fullname>-db-init", and so on). Its Role and RoleBinding share the name.
*/}}
{{- define "upgrade.cleanupServiceAccountName" -}}
{{- if .Values.db.upgrade.serviceAccount.create }}
{{- default (printf "%s-cleanup" (include "upgrade.fullname" .)) .Values.db.upgrade.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.db.upgrade.serviceAccount.name }}
{{- end }}
{{- end }}
