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

{{/*
Checksum of the rendered oauth2-proxy ConfigMap, for the pod annotation that
makes a configuration change actually reach the sidecars.

oauth2-proxy reads `--config=/config/oauth2-proxy.cfg` once, at startup. The
file is projected from a ConfigMap, so changing it changes nothing already
running: Kubernetes updates the mounted file, and the process never re-reads
it. Nothing in the Deployment spec changes either, so there is no rollout.

That turns a values-only upgrade into a silent no-op. Several settings touch
ONLY this ConfigMap -- `integrations.viya.sso.idpHint`, the Viya JWT issuer,
the login URL -- so `helm upgrade` reports success, the ConfigMap on the
cluster is correct, and every sidecar carries on with the old configuration.

Putting the checksum in the pod template annotations makes the template differ
whenever the configuration does, which is what triggers the rollout.

Usage: {{ include "oauth2-proxy.configChecksum" . }}
*/}}
{{- define "oauth2-proxy.configChecksum" -}}
{{- include "oauth2-proxy.config" . | sha256sum -}}
{{- end -}}

{{- define "oauth2-proxy.sidecar" -}}
{{- $oauthValues := .Root.Values.iam.oauthProxy -}}
{{- $upstreamPort := .upstreamPort | required "upstreamPort is required for oauth2-proxy.sidecar" -}}
{{- $upstreamPath := .upstreamPath | default "" -}}
{{- $instance := .instance | default 0 -}}
{{- $containerPort := add 4180 $instance -}}
{{- $containerName := printf "oauth2-proxy%d" $instance -}}
- name: {{ $containerName }}
  securityContext:
    {{- include "ram.securityContext" (list .Root.Values.iam.oauthProxy.securityContext .Root.Values.platform) | nindent 4 }}
  image: "{{- include "images.oauthProxy" . -}}"
  imagePullPolicy: {{ .Root.Values.images.oauthProxy.pullPolicy }}
  args:
    - --config=/config/oauth2-proxy.cfg
  env:
    # OAuth2 Client Configuration
    - name: OAUTH2_PROXY_CLIENT_ID
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-client-secret" (include "keycloak.fullname" .Root) }}
          key: sv-client-id
    - name: OAUTH2_PROXY_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-client-secret" (include "keycloak.fullname" .Root) }}
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
{{- if .Values.ingress.enabled -}}
{{- $keycloakPath := first .Values.ingress.keycloak.paths -}}
- command:
    - /bin/sh
    - -c
    - |
        while [ $(curl -sw '%{http_code}' "http://{{ include "keycloak.fullname" . | lower }}:{{ .Values.iam.keycloak.service.port }}{{ $keycloakPath }}/realms/{{ .Values.iam.keycloak.config.realm }}" -o /dev/null) -ne 200 ]; do
          echo "Waiting for ID provider to reach ready state...";
          sleep 15;
        done
  image: "{{- include "images.kubectl" . -}}"
  imagePullPolicy: {{ .Values.images.kubectl.pullPolicy }}
  name: idp-ready
  resources:
    limits:
      cpu: 50m
      memory: 32Mi
    requests:
      cpu: 50m
      memory: 32Mi
  securityContext:
    {{- include "ram.securityContext" (list .Values.iam.oauthProxy.securityContext .Values.platform) | nindent 12 }}
{{- end }}
{{- end }}
