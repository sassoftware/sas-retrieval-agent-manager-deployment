{{/*
Contour HTTPProxy templates.
Since Contour doesn't allow multiple HTTPProxies with the same FQDN, we use a single
combined HTTPProxy with all routes defined inline.
*/}}

{{/*
Combined HTTPProxy template - creates a single HTTPProxy with all routes
Usage: {{ include "contour.httpproxy.combined" . }}
*/}}
{{- define "contour.httpproxy.combined" -}}
{{- $ctx := . -}}
{{- $baseName := $ctx.Values.name | default "retrieval-agent-manager" -}}

apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: {{ $baseName }}-ingress
  labels:
    {{- include "retrieval-agent-manager.labels" $ctx | nindent 4 }}
spec:
  ingressClassName: {{ $ctx.Values.ingress.className | default "contour" }}
  virtualhost:
    fqdn: {{ $ctx.Values.ingress.domain }}
    {{- if and ((include "testValuesPath" (list $ctx.Values "ingress" "tls" "enabled")) | eq "true" | default false) ($ctx.Values.ingress.tls.enabled | default false) }}
    tls:
      {{- if $ctx.Values.ingress.tls.secretName }}
      secretName: {{ $ctx.Values.ingress.tls.secretName }}
      {{- else }}
      secretName: ingress-tls
      {{- end }}
      {{- if $ctx.Values.ingress.tls.minimumProtocolVersion }}
      minimumProtocolVersion: {{ $ctx.Values.ingress.tls.minimumProtocolVersion | quote }}
      {{- end }}
    {{- end }}
  routes:
    # API routes
    {{- range $ctx.Values.ingress.api.paths }}
    - conditions:
        - prefix: {{ . }}
      services:
        - name: {{ $baseName }}-api
          port: {{ $ctx.Values.api.service.port }}
      {{- if and $ctx.Values.ingress.contour $ctx.Values.ingress.contour.timeoutPolicy }}
      timeoutPolicy:
        {{- toYaml (default dict $ctx.Values.ingress.contour.timeoutPolicy) | nindent 8 }}
      {{- end }}
    {{- end }}
    # Keycloak admin routes
    {{- range $ctx.Values.ingress.keycloakAdmin.paths }}
    - conditions:
        - prefix: {{ . }}
      services:
        - name: {{ $baseName }}-keycloak
          port: {{ $ctx.Values.iam.keycloak.service.port }}
    {{- end }}
    # Keycloak public routes
    {{- range $ctx.Values.ingress.keycloak.paths }}
    - conditions:
        - prefix: {{ . }}
      services:
        - name: {{ $baseName }}-keycloak
          port: {{ $ctx.Values.iam.keycloak.service.port }}
    {{- end }}
    # PostgREST routes (rewrite path to "/")
    {{- range $ctx.Values.ingress.postgrest.paths }}
    - conditions:
        - prefix: {{ . }}
      pathRewritePolicy:
        replacePrefix:
          - replacement: /
      services:
        - name: {{ $baseName }}-postgrest
          {{- if contains "/monitoring" . }}
          port: {{ $ctx.Values.db.rest.monitoring.service.port }}
          {{- else }}
          port: {{ $ctx.Values.db.rest.service.port }}
          {{- end }}
    {{- end }}
    # UI routes (last due to broader prefix match)
    {{- $uiPaths := $ctx.Values.ingress.ui.paths }}
    {{- range $uiPaths }}
    - conditions:
        - prefix: {{ . }}
      services:
        - name: {{ $baseName }}-app
          port: {{ $ctx.Values.ui.service.port }}
    {{- end }}
    # Root redirect to UI if enableRootIngress is true
    {{- if (or (not (hasKey $ctx.Values.ingress "enableRootIngress")) (eq $ctx.Values.ingress.enableRootIngress true)) }}
    - conditions:
        - prefix: /
      requestRedirectPolicy:
        path: {{ index $uiPaths 0 }}
        statusCode: 302
    {{- end }}
{{- end -}}

{{/*
Template alias - produces no output for Contour
*/}}
{{- define "contour.httpproxy" -}}
{{- end -}}
