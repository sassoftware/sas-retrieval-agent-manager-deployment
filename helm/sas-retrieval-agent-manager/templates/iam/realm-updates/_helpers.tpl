{{/* Keycloak ingress URL */}}
{{ define "keycloak.internalBaseURL" -}}
{{ if .Values.ingress.enabled | default false -}}
http://{{ include "keycloak.fullname" . }}:{{ .Values.iam.keycloak.service.port }}{{ first .Values.ingress.keycloak.paths | trimSuffix "/" -}}
{{ end -}}
{{- end -}}
