{{/*
Expand the name of the chart.
*/}}

{{- define "keycloak.oauthProxy.name" -}}
{{- default (printf "oauth2-%s" .Chart.Name) .Values.oauthProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak.oauthProxy.fullname" -}}
{{- if .Values.oauthProxy.fullnameOverride }}
{{- .Values.oauthProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $oauthProxyName := default (printf "oauth2-%s" .Chart.Name) .Values.oauthProxy.nameOverride }}
{{- if contains $oauthProxyName .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $oauthProxyName | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak.oauthProxy.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.oauthProxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak.oauthProxy.selectorLabels" -}}
app.kubernetes.io/component: oauthProxy
app.kubernetes.io/name: {{ include "keycloak.oauthProxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.oauthProxy.serviceAccountName" -}}
{{- if .Values.oauthProxy.serviceAccount.create }}
{{- default (include "keycloak.oauthProxy.fullname" .) .Values.oauthProxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.oauthProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the cookie secret
*/}}
{{- define "keycloak.oauthProxy.cookieSecret" -}}
{{- if .Values.global.configuration.keycloak.cookieSecret -}}
  {{- .Values.global.configuration.keycloak.cookieSecret }}
{{- else -}}
{{- $oauthProxySecretName := include "keycloak.oauthProxy.fullname" . -}}
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
http://{{ include "keycloak.fullname" . }}:{{ .Values.service.port }}{{ with (first .Values.ingress.paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- end }}

{{/* OAuth2 Proxy domain */}}
{{ define "keycloak.oauthProxy.domain" -}}
{{$globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
{{ .Values.global.domain }}
{{- else -}}
{{ with (first .Values.oauthProxy.ingress.hosts) }}{{ .host }}{{ end }}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy prefix */}}
{{ define "keycloak.oauthProxy.prefix" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
{{ with (first .Values.oauthProxy.ingress.paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}
{{- else -}}
{{ with (first .Values.oauthProxy.ingress.hosts) }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end }}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy ingress URL */}}
{{ define "keycloak.oauthProxy.ingressURL" -}}
https://{{ include "keycloak.oauthProxy.domain" . }}{{ include "keycloak.oauthProxy.prefix" . }}
{{- end }}

{{/* Keycloak ingress URL */}}
{{ define "keycloak.ingressURL" -}}
{{ $globalEnabled := (((.Values.global).ingress).enabled | default false) -}}
{{ if $globalEnabled -}}
https://{{ .Values.global.domain }}{{ with (first .Values.ingress.paths) }}{{ regexReplaceAll "\\(.*" .path "" | trimSuffix "/"  }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- else -}}
https://{{ with (first .Values.ingress.hosts) }}{{ .host }}{{ with (first .paths) }}{{  regexReplaceAll "\\(.*" .path "" | trimSuffix "/" }}{{ end }}{{ end }}/realms/{{ .Values.global.configuration.keycloak.realm }}
{{- end }}
{{- end }}
