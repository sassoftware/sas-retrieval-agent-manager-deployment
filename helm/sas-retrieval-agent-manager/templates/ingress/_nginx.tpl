{{/*
Generic Ingress template for nginx ingress controller.
Usage: {{ include "nginx.ingress" (dict "ctx" . "config" $ingressConfig) }}

Config parameters:
  - name: The ingress name (required)
  - serviceName: The service name (optional, defaults to name)
  - labels: The labels template name to use (required)
  - annotationsPath: Path in values for component-specific annotations (e.g., "api", "keycloak")
  - servicePort: The service port number (required)
  - pathsKey: The key in ingress values for paths (e.g., "api", "ui", "keycloak")
  - monitoringPort: Optional monitoring port for postgrest-style routing
  - enableAppRoot: Whether to set nginx app-root annotation (for ui)
  - appRootDefault: Default app root path if enableAppRoot is true
*/}}

{{/*
Default nginx ingress annotations.
These can be overridden by setting the same keys in ingress.annotations or component-specific annotations.
*/}}
{{- define "nginx.default.annotations" -}}
kubernetes.io/ingress.allow-http: 'false'
nginx.ingress.kubernetes.io/proxy-body-size: 500m
nginx.ingress.kubernetes.io/proxy-buffer-size: 16k
nginx.ingress.kubernetes.io/ssl-redirect: 'true'
nginx.ingress.kubernetes.io/enable-cors: 'true'
nginx.ingress.kubernetes.io/session-cookie-samesite: lax
nginx.ingress.kubernetes.io/use-regex: 'true'
{{- end -}}

{{/*
Default annotations for API ingress.
*/}}
{{- define "nginx.default.annotations.api" -}}
nginx.ingress.kubernetes.io/auth-response-headers: Authorization,X-Auth-Request-Access-Token
kubernetes.io/tls-acme: 'true'
{{- end -}}

{{/*
Default annotations for UI ingress.
*/}}
{{- define "nginx.default.annotations.ui" -}}
nginx.ingress.kubernetes.io/auth-response-headers: Authorization
kubernetes.io/tls-acme: 'true'
{{- end -}}

{{/*
Default annotations for PostgREST ingress.
*/}}
{{- define "nginx.default.annotations.postgrest" -}}
nginx.ingress.kubernetes.io/auth-response-headers: Authorization
nginx.ingress.kubernetes.io/rewrite-target: /$2
kubernetes.io/tls-acme: 'true'
{{- end -}}

{{/*
Get component-specific default annotations by pathsKey.
Returns empty dict for components without specific defaults (keycloak, keycloakAdmin, oauthProxy).
*/}}
{{- define "nginx.default.annotations.component" -}}
{{- $pathsKey := . -}}
{{- if eq $pathsKey "api" -}}
{{- include "nginx.default.annotations.api" . -}}
{{- else if eq $pathsKey "ui" -}}
{{- include "nginx.default.annotations.ui" . -}}
{{- else if eq $pathsKey "postgrest" -}}
{{- include "nginx.default.annotations.postgrest" . -}}
{{- end -}}
{{- end -}}

{{- define "nginx.ingress" -}}
{{- $ctx := .ctx -}}
{{- $config := .config -}}
{{- $fullName := $config.name | lower -}}
{{- $serviceName := ($config.serviceName | default $config.name) | lower -}}
{{- $svcPort := $config.servicePort -}}
{{- $pathsKey := $config.pathsKey -}}
{{- $annotationsPath := $config.annotationsPath | default $pathsKey -}}

{{- /* Start with default nginx annotations */ -}}
{{- $annotations := include "nginx.default.annotations" $ctx | fromYaml -}}

{{- /* Merge component-specific default annotations */ -}}
{{- $componentDefaults := include "nginx.default.annotations.component" $annotationsPath -}}
{{- if $componentDefaults -}}
  {{- $annotations = merge ($componentDefaults | fromYaml) $annotations -}}
{{- end -}}

{{- /* Merge global annotations from values (allows overriding defaults) */ -}}
{{- if $ctx.Values.ingress.annotations -}}
  {{- $annotations = merge (deepCopy $ctx.Values.ingress.annotations) $annotations -}}
{{- end -}}

{{- /* Merge component-specific annotations if they exist (highest priority) */ -}}
{{- if $annotationsPath -}}
  {{- $componentIngress := index $ctx.Values.ingress $annotationsPath -}}
  {{- if and $componentIngress (hasKey $componentIngress "annotations") -}}
    {{- $annotations = merge (deepCopy $componentIngress.annotations) $annotations -}}
  {{- end -}}
{{- end -}}

{{- /* Handle app-root annotation for UI ingress */ -}}
{{- if $config.enableAppRoot -}}
  {{- $rawPath := $config.appRootDefault | default "/SASRetrievalAgentManager" -}}
  {{- $componentPaths := index $ctx.Values.ingress $pathsKey -}}
  {{- if and $componentPaths (hasKey $componentPaths "paths") -}}
    {{- $paths := $componentPaths.paths -}}
    {{- if and $paths (gt (len $paths) 0) -}}
      {{- $rawPath = index $paths 0 -}}
    {{- end -}}
  {{- end -}}
  {{- /* Use path directly since it's now a simple string */ -}}
  {{- $basePath := $rawPath -}}
  {{- if and (ne $basePath "/") (hasSuffix $basePath "/") -}}
    {{- $basePath = trimSuffix $basePath "/" -}}
  {{- end -}}
  {{- $_ := set $annotations "nginx.ingress.kubernetes.io/app-root" $basePath -}}
{{- end -}}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include $config.labels $ctx | nindent 4 }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ include "retrieval-agent-manager.ingressClassName" $ctx }}
  {{- if and ((include "testValuesPath" (list $ctx.Values "ingress" "tls" "enabled")) | eq "true" | default false) ($ctx.Values.ingress.tls.enabled | default false) }}
  tls:
    - hosts:
      - {{ $ctx.Values.ingress.domain | quote }}
      {{- if ((include "testValuesPath" (list $ctx.Values "ingress" "tls" "enabled")) | eq "true") }}
      secretName: {{ $ctx.Values.ingress.tls.secretName | default "" }}
      {{- end }}
  {{- end }}
  rules:
    - host: {{ $ctx.Values.ingress.domain | quote }}
      http:
        paths:
          {{- $componentIngress := index $ctx.Values.ingress $pathsKey -}}
          {{- range $componentIngress.paths }}
          {{- if and $config.monitoringPort (contains "/monitoring" .) }}
          - path: {{ . }}(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: {{ $serviceName }}
                port:
                  number: {{ $config.monitoringPort }}
          {{- else }}
          - path: {{ . }}(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: {{ $serviceName }}
                port:
                  number: {{ $svcPort }}
          {{- end }}
          {{- end }}
{{- end -}}
