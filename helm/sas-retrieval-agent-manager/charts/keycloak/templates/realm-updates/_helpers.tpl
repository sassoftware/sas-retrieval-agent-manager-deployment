{{/* Keycloak ingress URL */}}
{{ define "keycloak.internalBaseURL" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
http://{{ include "keycloak.fullname" . }}:{{ .Values.service.port }}{{ with (first .Values.ingress.paths) }}{{ regexReplaceAll "\\(.*" .path "" | trimSuffix "/"  }}{{ end -}}
{{ else -}}
http://{{ include "keycloak.fullname" . }}:{{ .Values.service.port }}{{ with (first .Values.ingress.hosts) }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end -}}
{{ end -}}
{{- end -}}
