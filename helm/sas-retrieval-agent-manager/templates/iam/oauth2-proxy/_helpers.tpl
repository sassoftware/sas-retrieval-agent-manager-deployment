{{/*
Expand the name of the chart.
*/}}

{{- define "oauth2-proxy.name" -}}
{{- if (index .Values "keycloak").oauthProxy.nameOverride }}
{{- (index .Values "keycloak").oauthProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-oauth2-proxy" (include "sas-retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oauth2-proxy.fullname" -}}
{{- if (index .Values "keycloak").oauthProxy.fullnameOverride }}
{{- (index .Values "keycloak").oauthProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-oauth2-proxy" (include "sas-retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "oauth2-proxy.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "oauth2-proxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "oauth2-proxy.selectorLabels" -}}
app.kubernetes.io/component: oauthProxy
app.kubernetes.io/name: {{ include "oauth2-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "oauth2-proxy.serviceAccountName" -}}
{{- if (index .Values "keycloak").oauthProxy.serviceAccount.create }}
{{- default (include "oauth2-proxy.fullname" .) (index .Values "keycloak").oauthProxy.serviceAccount.name }}
{{- else }}
{{- default "default" (index .Values "keycloak").oauthProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the cookie secret
*/}}
{{- define "oauth2-proxy.cookieSecret" -}}
{{- if .Values.global.configuration.keycloak.cookieSecret -}}
  {{- .Values.global.configuration.keycloak.cookieSecret }}
{{- else -}}
{{- $oauthProxySecretName := include "oauth2-proxy.fullname" . -}}
{{- $oauthProxySecret := lookup "v1" "Secret" .Release.Namespace $oauthProxySecretName -}}
{{- if and $oauthProxySecret (index $oauthProxySecret.data "cookie-secret") -}}
    {{- (index $oauthProxySecret.data "cookie-secret") | b64dec -}}
{{- else -}}
    {{- $newCookieSecret := randAlphaNum 32 | b64enc | replace "+" "-" | replace "/" "_" | replace "=" "" -}}
    {{- $newCookieSecret -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Cluster-internal Keycloak URL */}}
{{ define "keycloak.internalURL" -}}
http://{{ include "keycloak.fullname" . }}:{{ (index .Values "keycloak").service.port }}{{ with (first (index .Values "keycloak").ingress.paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- end }}

{{/* OAuth2 Proxy domain */}}
{{ define "oauth2-proxy.domain" -}}
{{$globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
{{ .Values.global.domain }}
{{- else -}}
{{ with (first .Values.keycloak.oauthProxy.ingress.hosts) }}{{ .host }}{{ end }}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy prefix */}}
{{ define "oauth2-proxy.prefix" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
{{ with (first .Values.keycloak.oauthProxy.ingress.paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}
{{- else -}}
{{ with (first .Values.keycloak.oauthProxy.ingress.hosts) }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end }}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy ingress URL */}}
{{ define "oauth2-proxy.ingressURL" -}}
https://{{ include "oauth2-proxy.domain" . }}{{ include "oauth2-proxy.prefix" . }}
{{- end }}

{{/* Keycloak ingress URL */}}
{{ define "keycloak.ingressURL" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
https://{{ .Values.global.domain }}{{ with (first (index .Values "keycloak").ingress.paths) }}{{ regexReplaceAll "\\(.*" .path "" | trimSuffix "/"  }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- else -}}
https://{{ with (first (index .Values "keycloak").ingress.hosts) }}{{ .host }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- end }}
{{- end }}
