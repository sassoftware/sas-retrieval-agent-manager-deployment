{{/*
Generic Route template for OpenShift.
Usage: {{ include "openshift.route" (dict "ctx" . "config" $routeConfig) }}

Config parameters:
  - name: The route name (required)
  - serviceName: The service name (optional, defaults to name)
  - labels: The labels template name to use (required)
  - annotationsPath: Path in values for component-specific annotations (e.g., "api", "keycloak")
  - servicePort: The service port number (accepted for compatibility with nginx/contour templates, but not used)
  - pathsKey: The key in ingress values for paths (e.g., "api", "ui", "keycloak")
  - monitoringPort: Optional flag to enable monitoring port routing (uses "http-monitor" port name)
  - enableAppRoot: Whether to set app-root annotation (for ui)
  - appRootDefault: Default app root path if enableAppRoot is true

Note: Routes use service port names ("http" or "http-monitor") instead of port numbers
      to properly resolve through services that use named targetPorts.
*/}}

{{/*
Default annotations for API route.
*/}}
{{- define "route.default.annotations.api" -}}
{{- end -}}

{{/*
Default annotations for UI route.
*/}}
{{- define "route.default.annotations.ui" -}}
{{- end -}}

{{/*
Default annotations for PostgREST route.
Strips the base path prefix so PostgREST receives requests at root.
*/}}
{{- define "route.default.annotations.postgrest" -}}
haproxy.router.openshift.io/rewrite-target: /
{{- end -}}

{{/*
Get component-specific default annotations by pathsKey.
Returns empty dict for components without specific defaults (keycloak, keycloakAdmin, oauthProxy).
*/}}
{{- define "route.default.annotations.component" -}}
{{- $pathsKey := . -}}
{{- if eq $pathsKey "api" -}}
{{- include "route.default.annotations.api" . -}}
{{- else if eq $pathsKey "ui" -}}
{{- include "route.default.annotations.ui" . -}}
{{- else if eq $pathsKey "postgrest" -}}
{{- include "route.default.annotations.postgrest" . -}}
{{- end -}}
{{- end -}}

{{- define "openshift.route" -}}
{{- $ctx := .ctx -}}
{{- $config := .config -}}
{{- $fullName := $config.name | lower -}}
{{- $serviceName := ($config.serviceName | default $config.name) | lower -}}
{{- $pathsKey := $config.pathsKey -}}
{{- $annotationsPath := $config.annotationsPath | default $pathsKey -}}

{{- /* Start with global annotations from values */ -}}
{{- $annotations := deepCopy $ctx.Values.ingress.annotations | default dict -}}

{{- /* Merge component-specific default annotations */ -}}
{{- $componentDefaults := include "route.default.annotations.component" $annotationsPath -}}
{{- if $componentDefaults -}}
  {{- $annotations = merge ($componentDefaults | fromYaml) $annotations -}}
{{- end -}}

{{- /* Merge component-specific annotations from values if they exist (highest priority) */ -}}
{{- if $annotationsPath -}}
  {{- $componentIngress := index $ctx.Values.ingress $annotationsPath -}}
  {{- if and $componentIngress (hasKey $componentIngress "annotations") -}}
    {{- $annotations = merge (deepCopy $componentIngress.annotations) $annotations -}}
  {{- end -}}
{{- end -}}

{{- /* Get component paths */ -}}
{{- $componentIngress := index $ctx.Values.ingress $pathsKey -}}
{{- $paths := $componentIngress.paths -}}

{{- /* Generate a route for each path */ -}}
{{- range $index, $pathEntry := $paths -}}
{{- $routeName := $fullName -}}
{{- if gt $index 0 -}}
  {{- $routeName = printf "%s-%d" $fullName $index -}}
{{- end -}}
{{- /* Determine port name based on monitoring path */ -}}
{{- $targetPortName := "http" -}}
{{- if and $config.monitoringPort (contains "/monitoring" $pathEntry) -}}
  {{- $targetPortName = "http-monitor" -}}
{{- end -}}
{{- /* Use path directly since it's now a simple string */ -}}
{{- $routePath := $pathEntry -}}
{{- if and (ne $routePath "/") (hasSuffix $routePath "/") -}}
  {{- $routePath = trimSuffix $routePath "/" -}}
{{- end }}
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ $routeName }}
  labels:
    {{- include $config.labels $ctx | nindent 4 }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  host: {{ $ctx.Values.ingress.domain | quote }}
  {{- if and (ne $routePath "/") (not (default false $config.enableAppRoot)) }}
  path: {{ $routePath }}
  {{- end }}
  to:
    kind: Service
    name: {{ $serviceName }}
    weight: 100
  port:
    targetPort: {{ $targetPortName }}
  {{- if $ctx.Values.ingress.tls.enabled }}
  tls:
    termination: {{ $ctx.Values.ingress.tls.termination | default "edge" }}
    insecureEdgeTerminationPolicy: {{ $ctx.Values.ingress.tls.insecureEdgeTerminationPolicy | default "Redirect" }}
    {{- if $ctx.Values.ingress.tls.certificate }}
    certificate: |
      {{- $ctx.Values.ingress.tls.certificate | nindent 6 }}
    {{- end }}
    {{- if $ctx.Values.ingress.tls.key }}
    key: |
      {{- $ctx.Values.ingress.tls.key | nindent 6 }}
    {{- end }}
    {{- if $ctx.Values.ingress.tls.caCertificate }}
    caCertificate: |
      {{- $ctx.Values.ingress.tls.caCertificate | nindent 6 }}
    {{- end }}
  {{- end }}
  wildcardPolicy: None
status:
  ingress: []
{{ end }}
{{- end -}}
