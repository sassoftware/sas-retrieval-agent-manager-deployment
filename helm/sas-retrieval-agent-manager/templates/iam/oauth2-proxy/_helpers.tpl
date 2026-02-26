{{/*
Expand the name of the chart.
*/}}
{{- define "oauth2-proxy.name" -}}
{{- printf "%s-oauth2-proxy" (include "retrieval-agent-manager.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oauth2-proxy.fullname" -}}
{{- printf "%s-oauth2-proxy" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" }}
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
{{- if .Values.iam.oauthProxy.serviceAccount.create }}
{{- default (include "oauth2-proxy.fullname" .) .Values.iam.oauthProxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.iam.oauthProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the cookie secret
*/}}
{{- define "oauth2-proxy.cookieSecret" -}}
{{- if .Values.iam.keycloak.config.cookieSecret -}}
  {{- .Values.iam.keycloak.config.cookieSecret }}
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
http://{{ include "keycloak.fullname" . }}:{{ .Values.iam.keycloak.service.port }}{{ first .Values.ingress.keycloak.paths | trimSuffix "/" }}/realms/{{ .Values.iam.keycloak.config.realm }}
{{- end -}}

{{/* OAuth2 Proxy domain */}}
{{ define "oauth2-proxy.domain" -}}
{{ if .Values.ingress.enabled | default false -}}
{{ .Values.ingress.domain | default ""}}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy prefix */}}
{{ define "oauth2-proxy.prefix" -}}
{{ if .Values.ingress.enabled | default false -}}
{{ first .Values.ingress.oauthProxy.paths | trimSuffix "/" }}
{{- end }}
{{- end }}

{{/* OAuth2 Proxy ingress URL */}}
{{ define "oauth2-proxy.ingressURL" -}}
https://{{ include "oauth2-proxy.domain" . }}{{ include "oauth2-proxy.prefix" . }}
{{- end }}

{{/* Keycloak ingress URL */}}
{{- define "keycloak.ingressURL" -}}
{{ if .Values.ingress.enabled | default false -}}
https://{{ .Values.ingress.domain }}{{ first .Values.ingress.keycloak.paths | trimSuffix "/" }}/realms/{{ .Values.iam.keycloak.config.realm }}
{{- end }}
{{- end }}
