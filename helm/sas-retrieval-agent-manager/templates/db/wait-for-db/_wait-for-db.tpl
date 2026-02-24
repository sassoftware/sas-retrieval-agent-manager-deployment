{{- /*
wait-for-db.yaml
Reusable Helm template for a wait-for-db initContainer or sidecar.

USAGE:
  # IMPORTANT: Pass the root context (the parent chart's ".") to all dicts for correct value resolution.
  # Example for db = application|monitoring|keycloak|vector-store:

  {{- include "wait-for-db.container" (dict "db" "application") . }}

  # Volumes for wait-for-db:
  {{- include "wait-for-db.volumes" (dict "db" "application") . }}

  # This ensures all .Values and template lookups resolve from the root context, avoiding issues seen with other sidecars.
*/ -}}
{{- define "wait-for-db.container" }}
{{- $db := required "db parameter required (application, monitoring, keycloak, vector-store)" .db }}
{{- $root := .Root | default . }}
{{- $configMapName := printf "%s-db-%s" (include "retrieval-agent-manager.fullname" $root) $db }}
{{- $secretName := printf "%s-%s-db-credentials" (include "retrieval-agent-manager.fullname" $root) $db }}
- name: {{ printf "db-wait-%s" $db }}
  image: "{{- include "images.postgres" $root -}}"
  imagePullPolicy: {{ $root.Values.images.postgres.pullPolicy }}
  command:
    - "/bin/sh"
    - "-c"
    - "set -e; /config/wait_for_postgres.sh; /config/wait_for_database.sh"
  env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: {{ $secretName }}
          key: user
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ $secretName }}
          key: password
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: {{ printf "%s-db-connection" (include "retrieval-agent-manager.fullname" $root) }}
          key: host
    - name: DB_PORT
      valueFrom:
        configMapKeyRef:
          name: {{ printf "%s-db-connection" (include "retrieval-agent-manager.fullname" $root) }}
          key: port
    - name: DB_NAME
      valueFrom:
        configMapKeyRef:
          name: {{ $configMapName }}
          key: db
    - name: DB_SCHEMA
      valueFrom:
        configMapKeyRef:
          name: {{ $configMapName }}
          key: schema
  volumeMounts:
    - mountPath: "/config"
      name: scripts-{{ $db }}
      readOnly: true
    - mountPath: "/config/db"
      name: db-connection-{{ $db }}
      readOnly: true
    - mountPath: "/config/{{ $db }}"
      name: db-{{ $db }}-config
      readOnly: true
    - mountPath: "/secret/{{ $db }}"
      name: db-{{ $db }}-secret
      readOnly: true
  securityContext:
    {{- toYaml $root.Values.db.rest.securityContext | nindent 12 }}
  resources:
    {{- toYaml $root.Values.db.rest.resources | nindent 12 }}
{{- end }}

{{- define "wait-for-db.volumes" }}
{{- $db := required "db parameter required (application, monitoring, keycloak, vector-store)" .db }}
{{- $root := .Root | default . }}
{{- $configMapName := printf "%s-db-%s" (include "retrieval-agent-manager.fullname" $root) $db }}
{{- $secretName := printf "%s-%s-db-credentials" (include "retrieval-agent-manager.fullname" $root) $db }}
- name: scripts-{{ $db }}
  configMap:
    name: {{ include "postgrest.fullname" $root }}-scripts
    defaultMode: 0777
- name: db-connection-{{ $db }}
  configMap:
    name: {{ printf "%s-db-connection" (include "retrieval-agent-manager.fullname" $root) }}
- name: db-{{ $db }}-config
  configMap:
    name: {{ $configMapName }}
- name: db-{{ $db }}-secret
  secret:
    secretName: {{ $secretName }}
{{- end }}
