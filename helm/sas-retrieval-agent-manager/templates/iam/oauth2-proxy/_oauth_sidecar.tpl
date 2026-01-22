{{/*
OAuth2 Proxy Sidecar Container Template

This template generates a complete OAuth2 Proxy sidecar container
that can be included in any deployment.

Usage in your deployment template:
  containers:
    - name: my-app
      # ... your app container spec
    {{- include "oauth2-proxy.sidecar" (dict "Root" . "upstreamPort" 8080) | nindent 4 }}

Parameters (passed via dict):
  .Root: The root context (required) - provides access to .Values, .Chart, .Release, etc.
  .upstreamPort: The port of the upstream application (required)
  .upstreamPath: The path prefix for the upstream (optional, defaults to "")
  .instance: (optional) Instance number for naming and port offset (defaults to 0)
*/}}

{{- define "oauth2-proxy.sidecar" -}}
{{- $oauthValues := .Root.Values.keycloak.oauthProxy -}}
{{- $upstreamPort := .upstreamPort | required "upstreamPort is required for oauth2-proxy.sidecar" -}}
{{- $upstreamPath := .upstreamPath | default "" -}}
{{- $instance := .instance | default 0 -}}
{{- $containerPort := add 4180 $instance -}}
{{- $containerName := printf "oauth2-proxy%d" $instance -}}
{{- $oauthProxy_repo_base := "" -}}
{{- if ((include "testValuesPath" (list .Root.Values "global" "image" "repo" "base")) | eq "true") -}}
  {{- $oauthProxy_repo_base = .Root.Values.global.image.repo.base | default (index .Root.Values "keycloak").oauthProxy.image.repo.base -}}
{{- else -}}
  {{- $oauthProxy_repo_base = index .Root.Values.keycloak.oauthProxy.image.repo.base -}}
{{- end -}}
- name: {{ $containerName }}
  securityContext:
    {{- toYaml .Root.Values.keycloak.oauthProxy.securityContext | nindent 4 }}
  image: "{{ $oauthProxy_repo_base }}/{{ .Root.Values.keycloak.oauthProxy.image.repo.path }}:{{ .Root.Values.keycloak.oauthProxy.image.tag | default .Root.Chart.AppVersion }}"
  imagePullPolicy: {{ .Root.Values.keycloak.oauthProxy.image.pullPolicy }}
  args:
    - --config=/config/oauth2-proxy.cfg
  env:
    # OAuth2 Client Configuration
    - name: OAUTH2_PROXY_CLIENT_ID
      valueFrom:
        secretKeyRef:
          name: keycloak-client-secret
          key: sv-client-id
    - name: OAUTH2_PROXY_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: keycloak-client-secret
          key: sv-client-secret
    - name: OAUTH2_PROXY_COOKIE_SECRET
      valueFrom:
        secretKeyRef:
          name: {{ include "oauth2-proxy.fullname" .Root | lower }}
          key: cookie-secret
      # head -c 32 /dev/random | base64 -w 0
      #value: xvL2dHsqwThpkUOHYdWFn95TIUuKxuTbspLrSjJtSW8=
    # Pod metadata for logging/debugging
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: POD_UID
      valueFrom:
        fieldRef:
          fieldPath: metadata.uid
    # Upstream configuration
    - name: OAUTH2_PROXY_UPSTREAMS
      value: "http://127.0.0.1:{{ $upstreamPort }}{{ $upstreamPath }}"
    # Port override
    - name: OAUTH2_PROXY_HTTP_ADDRESS
      value: "0.0.0.0:{{ $containerPort }}"
  ports:
    - containerPort: {{ $containerPort }}
      name: {{ $containerName }}
      protocol: TCP
  {{- with $oauthValues.startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  livenessProbe:
    httpGet:
      path: /ping
      port: {{ $containerName }}
  readinessProbe:
    httpGet:
      path: /ping
      port: {{ $containerName }}
  resources:
    {{- toYaml $oauthValues.resources | nindent 4 }}
  volumeMounts:
    - name: oauth2-proxy-config
      mountPath: /config
      readOnly: true
    - name: oauth2-proxy-tmp
      mountPath: /tmp
    - name: oauth2-proxy-var-tmp
      mountPath: /var/tmp
    - name: oauth2-proxy-var-run
      mountPath: /var/run
{{- end -}}

{{/*
OAuth2 Proxy Sidecar Volumes

This template generates the required volumes for the OAuth2 proxy sidecar.

Usage in your deployment template:
  volumes:
    - name: my-app-config
      # ... your volumes
    {{- include "oauth2-proxy.sidecar.volumes" . | nindent 4 }}
*/}}
{{- define "oauth2-proxy.sidecar.volumes" -}}
- name: oauth2-proxy-config
  configMap:
    name: {{ include "oauth2-proxy.fullname" . | lower }}
    defaultMode: 0444
- name: oauth2-proxy-tmp
  emptyDir:
    sizeLimit: 128Mi
- name: oauth2-proxy-var-tmp
  emptyDir:
    sizeLimit: 128Mi
- name: oauth2-proxy-var-run
  emptyDir:
    sizeLimit: 5Mi
{{- end -}}

{{/*
OAuth2 Proxy init container for IDP readiness

This template generates the required init container for the OAuth2 proxy sidecar.

Usage in your deployment template:
  initContainers:
    - name: my-app-config
      # ... your containers
    {{- include "oauth2-proxy.sidecar.init" . | nindent 4 }}

Parameters (passed via dict):
  .configMapName: Name of the ConfigMap containing oauth2-proxy.cfg (optional)
*/}}
{{- define "oauth2-proxy.sidecar.init" -}}
{{- $configMapName := .configMapName -}}
{{- if not $configMapName -}}
  {{- $configMapName = (printf "%s-oauth2-config" (include "oauth2-proxy.fullname" .)) -}}
{{- end -}}
{{- $kubectl_repo_base := "" -}}
{{- if ((include "testValuesPath" (list .Values "global" "image" "repo" "base")) | eq "true") -}}
  {{- $kubectl_repo_base = .Values.global.image.repo.base | default (index .Values "keycloak").image.kubectl.repo.base -}}
{{- else -}}
  {{- $kubectl_repo_base = (index .Values "keycloak").image.kubectl.repo.base -}}
{{- end -}}
{{- $globalEnabled := false -}}
{{- if hasKey .Values "global" -}}
{{- if hasKey .Values.global "ingress" -}}
{{- if hasKey .Values.global.ingress "enabled" -}}
{{- $globalEnabled = .Values.global.ingress.enabled -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $oAuthProxyPath := "" -}}
{{- if $globalEnabled -}}
{{- $oAuthProxyPath = regexReplaceAll "\\(.*" (first (index .Values "keycloak").oauthProxy.ingress.paths).path "" -}}
{{- else -}}
{{- if (len (index .Values "keycloak").oauthProxy.ingress.hosts) -}}
{{- $oAuthProxyPath = regexReplaceAll "\\(.*" (first (first (index .Values "keycloak").oauthProxy.ingress.hosts).paths).path "" -}}
{{- end -}}
{{- end -}}
{{- $keycloakPath := "" -}}
{{- if $globalEnabled -}}
{{- $keycloakPath = regexReplaceAll "\\(.*" (first (index .Values "keycloak").ingress.paths).path "" -}}
{{- else -}}
{{- if (len (index .Values "keycloak").ingress.hosts) -}}
{{- $keycloakPath = regexReplaceAll "\\(.*" (first (first (index .Values "keycloak").ingress.hosts).paths).path "" -}}
{{- end -}}
{{- end -}}
- command:
    - /bin/sh
    - -c
    - |
        while [ $(curl -sw '%{http_code}' "http://{{ include "keycloak.fullname" . | lower }}:{{ (index .Values "keycloak").service.port }}{{ $keycloakPath }}/realms/master" -o /dev/null) -ne 200 ]; do
          echo "Waiting for ID provider to reach ready state...";
          sleep 15;
        done
  image: "{{ $kubectl_repo_base }}/{{ (index .Values "keycloak").image.kubectl.repo.path }}:{{ (index .Values "keycloak").image.kubectl.tag }}"
  imagePullPolicy: {{ (index .Values "keycloak").image.kubectl.pullPolicy }}
  name: idp-ready
  resources:
    limits:
      cpu: 50m
      memory: 32Mi
    requests:
      cpu: 50m
      memory: 32Mi
  securityContext:
    {{- toYaml (index .Values "keycloak").oauthProxy.securityContext | nindent 12 }}
{{- end -}}
