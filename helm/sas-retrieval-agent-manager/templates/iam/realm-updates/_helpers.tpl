{{/* Keycloak ingress URL */}}
{{ define "keycloak.internalBaseURL" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
http://{{ include "keycloak.fullname" . }}:{{ (index .Values "keycloak").service.port }}{{ with (first (index .Values "keycloak").ingress.paths) }}{{ regexReplaceAll "\\(.*" .path "" | trimSuffix "/"  }}{{ end -}}
{{ else -}}
http://{{ include "keycloak.fullname" . }}:{{ (index .Values "keycloak").service.port }}{{ with (first (index .Values "keycloak").ingress.hosts) }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end -}}
{{ end -}}
{{- end -}}
