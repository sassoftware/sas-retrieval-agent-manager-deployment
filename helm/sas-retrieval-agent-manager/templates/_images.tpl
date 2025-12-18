{{/* ========== sas-retrieval-agent-manager-api ========== */}}
{{- define "images.api.repo.base" -}}
  {{- if and .Values.images.api .Values.images.api.repo }}
    {{- .Values.images.repo.base | default .Values.images.api.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.api.repo.path" -}}
  {{- if and .Values.images.api .Values.images.api.repo }}
    {{- .Values.images.api.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.api.tag" -}}
  {{- if .Values.images.api }}
    {{- .Values.images.api.tag -}}
  {{- end }}
{{- end }}

{{- define "images.api.pullPolicy" -}}
  {{- if .Values.images.api }}
    {{- .Values.images.api.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.api" -}}
  {{- printf "%s/%s:%s" (include "images.api.repo.base" .) (include "images.api.repo.path" .) (include "images.api.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-ui ========== */}}
{{- define "images.ui.repo.base" -}}
  {{- if and .Values.images.ui .Values.images.ui.repo }}
    {{- .Values.images.repo.base | default .Values.images.ui.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.ui.repo.path" -}}
  {{- if and .Values.images.ui .Values.images.ui.repo }}
    {{- .Values.images.ui.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.ui.tag" -}}
  {{- if .Values.images.ui }}
    {{- .Values.images.ui.tag -}}
  {{- end }}
{{- end }}

{{- define "images.ui.pullPolicy" -}}
  {{- if .Values.images.ui }}
    {{- .Values.images.ui.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.ui" -}}
  {{- printf "%s/%s:%s" (include "images.ui.repo.base" .) (include "images.ui.repo.path" .) (include "images.ui.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-agent ========== */}}
{{- define "images.agent.repo.base" -}}
  {{- if and .Values.images.agent .Values.images.agent.repo }}
    {{- .Values.images.repo.base | default .Values.images.agent.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.agent.repo.path" -}}
  {{- if and .Values.images.agent .Values.images.agent.repo }}
    {{- .Values.images.agent.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.agent.tag" -}}
  {{- if .Values.images.agent }}
    {{- .Values.images.agent.tag -}}
  {{- end }}
{{- end }}

{{- define "images.agent.pullPolicy" -}}
  {{- if .Values.images.agent }}
    {{- .Values.images.agent.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.agent" -}}
  {{- printf "%s/%s:%s" (include "images.agent.repo.base" .) (include "images.agent.repo.path" .) (include "images.agent.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-evaluation ========== */}}
{{- define "images.eval.repo.base" -}}
  {{- if and .Values.images.eval .Values.images.eval.repo }}
    {{- .Values.images.repo.base | default .Values.images.eval.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.eval.repo.path" -}}
  {{- if and .Values.images.eval .Values.images.eval.repo }}
    {{- .Values.images.eval.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.eval.tag" -}}
  {{- if .Values.images.eval }}
    {{- .Values.images.eval.tag -}}
  {{- end }}
{{- end }}

{{- define "images.eval.pullPolicy" -}}
  {{- if .Values.images.eval }}
    {{- .Values.images.eval.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.eval" -}}
  {{- printf "%s/%s:%s" (include "images.eval.repo.base" .) (include "images.eval.repo.path" .) (include "images.eval.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-plugin ========== */}}
{{- define "images.plugin.repo.base" -}}
  {{- if and .Values.images.plugin .Values.images.plugin.repo }}
    {{- .Values.images.repo.base | default .Values.images.plugin.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.plugin.repo.path" -}}
  {{- if and .Values.images.plugin .Values.images.plugin.repo }}
    {{- .Values.images.plugin.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.plugin.tag" -}}
  {{- if .Values.images.plugin }}
    {{- .Values.images.plugin.tag -}}
  {{- end }}
{{- end }}

{{- define "images.plugin.pullPolicy" -}}
  {{- if .Values.images.plugin }}
    {{- .Values.images.plugin.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.plugin" -}}
  {{- printf "%s/%s:%s" (include "images.plugin.repo.base" .) (include "images.plugin.repo.path" .) (include "images.plugin.tag" .) -}}
{{- end }}

{{/* ========== sas-iot-keycloak-theme ========== */}}
{{- define "images.theme.repo.base" -}}
  {{- if and .Values.images.theme .Values.images.theme.repo }}
    {{- .Values.images.repo.base | default .Values.images.theme.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.theme.repo.path" -}}
  {{- if and .Values.images.theme .Values.images.theme.repo }}
    {{- .Values.images.theme.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.theme.tag" -}}
  {{- if .Values.images.theme }}
    {{- .Values.images.theme.tag -}}
  {{- end }}
{{- end }}

{{- define "images.theme.pullPolicy" -}}
  {{- if .Values.images.theme }}
    {{- .Values.images.theme.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.theme" -}}
  {{- printf "%s/%s:%s" (include "images.theme.repo.base" .) (include "images.theme.repo.path" .) (include "images.theme.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-db-migration ========== */}}
{{- define "images.goose.repo.base" -}}
  {{- if and .Values.images.goose .Values.images.goose.repo }}
    {{- .Values.images.repo.base | default .Values.images.goose.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.goose.repo.path" -}}
  {{- if and .Values.images.goose .Values.images.goose.repo }}
    {{- .Values.images.goose.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.goose.tag" -}}
  {{- if .Values.images.goose }}
    {{- .Values.images.goose.tag -}}
  {{- end }}
{{- end }}

{{- define "images.goose.pullPolicy" -}}
  {{- if .Values.images.goose }}
    {{- .Values.images.goose.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.goose" -}}
  {{- printf "%s/%s:%s" (include "images.goose.repo.base" .) (include "images.goose.repo.path" .) (include "images.goose.tag" .) -}}
{{- end }}

{{/* ========== text-embeddings-inference ========== */}}
{{- define "images.embedding.repo.base" -}}
  {{- if and .Values.images.embedding .Values.images.embedding.repo }}
    {{- .Values.images.repo.base | default .Values.images.embedding.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.embedding.repo.path" -}}
  {{- if and .Values.images.embedding .Values.images.embedding.repo }}
    {{- .Values.images.embedding.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.embedding.tag" -}}
  {{- if .Values.images.embedding }}
    {{- .Values.images.embedding.tag -}}
  {{- end }}
{{- end }}

{{- define "images.embedding.pullPolicy" -}}
  {{- if .Values.images.embedding }}
    {{- .Values.images.embedding.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.embedding" -}}
  {{- printf "%s/%s:%s" (include "images.embedding.repo.base" .) (include "images.embedding.repo.path" .) (include "images.embedding.tag" .) -}}
{{- end }}

{{/* ========== postgrest ========== */}}
{{- define "images.postgrest.repo.base" -}}
  {{- if and .Values.images.postgrest .Values.images.postgrest.repo }}
    {{- .Values.images.repo.base | default .Values.images.postgrest.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.postgrest.repo.path" -}}
  {{- if and .Values.images.postgrest .Values.images.postgrest.repo }}
    {{- .Values.images.postgrest.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.postgrest.tag" -}}
  {{- if .Values.images.postgrest }}
    {{- .Values.images.postgrest.tag -}}
  {{- end }}
{{- end }}

{{- define "images.postgrest.pullPolicy" -}}
  {{- if .Values.images.postgrest }}
    {{- .Values.images.postgrest.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.postgrest" -}}
  {{- printf "%s/%s:%s" (include "images.postgrest.repo.base" .) (include "images.postgrest.repo.path" .) (include "images.postgrest.tag" .) -}}
{{- end }}

{{/* ========== gpg ========== */}}
{{- define "images.gpg.repo.base" -}}
  {{- if and .Values.images.gpg .Values.images.gpg.repo }}
    {{- .Values.images.repo.base | default .Values.images.gpg.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.gpg.repo.path" -}}
  {{- if and .Values.images.gpg .Values.images.gpg.repo }}
    {{- .Values.images.gpg.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.gpg.tag" -}}
  {{- if .Values.images.gpg }}
    {{- .Values.images.gpg.tag -}}
  {{- end }}
{{- end }}

{{- define "images.gpg.pullPolicy" -}}
  {{- if .Values.images.gpg }}
    {{- .Values.images.gpg.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.gpg" -}}
  {{- printf "%s/%s:%s" (include "images.gpg.repo.base" .) (include "images.gpg.repo.path" .) (include "images.gpg.tag" .) -}}
{{- end }}

{{/* ========== kubectl ========== */}}
{{- define "images.kubectl.repo.base" -}}
  {{- if and .Values.images.kubectl .Values.images.kubectl.repo }}
    {{- .Values.images.repo.base | default .Values.images.kubectl.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.kubectl.repo.path" -}}
  {{- if and .Values.images.kubectl .Values.images.kubectl.repo }}
    {{- .Values.images.kubectl.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.kubectl.tag" -}}
  {{- if .Values.images.kubectl }}
    {{- .Values.images.kubectl.tag -}}
  {{- end }}
{{- end }}

{{- define "images.kubectl.pullPolicy" -}}
  {{- if .Values.images.kubectl }}
    {{- .Values.images.kubectl.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.kubectl" -}}
  {{- printf "%s/%s:%s" (include "images.kubectl.repo.base" .) (include "images.kubectl.repo.path" .) (include "images.kubectl.tag" .) -}}
{{- end }}

{{/* ========== keycloak ========== */}}
{{- define "images.keycloak.repo.base" -}}
  {{- if and .Values.images.keycloak .Values.images.keycloak.repo }}
    {{- .Values.images.repo.base | default .Values.images.keycloak.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.keycloak.repo.path" -}}
  {{- if and .Values.images.keycloak .Values.images.keycloak.repo }}
    {{- .Values.images.keycloak.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.keycloak.tag" -}}
  {{- if .Values.images.keycloak }}
    {{- .Values.images.keycloak.tag -}}
  {{- end }}
{{- end }}

{{- define "images.keycloak.pullPolicy" -}}
  {{- if .Values.images.keycloak }}
    {{- .Values.images.keycloak.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.keycloak" -}}
  {{- printf "%s/%s:%s" (include "images.keycloak.repo.base" .) (include "images.keycloak.repo.path" .) (include "images.keycloak.tag" .) -}}
{{- end }}

{{/* ========== postgres ========== */}}
{{- define "images.postgres.repo.base" -}}
  {{- if and .Values.images.postgres .Values.images.postgres.repo }}
    {{- .Values.images.repo.base | default .Values.images.postgres.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.postgres.repo.path" -}}
  {{- if and .Values.images.postgres .Values.images.postgres.repo }}
    {{- .Values.images.postgres.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.postgres.tag" -}}
  {{- if .Values.images.postgres }}
    {{- .Values.images.postgres.tag -}}
  {{- end }}
{{- end }}

{{- define "images.postgres.pullPolicy" -}}
  {{- if .Values.images.postgres }}
    {{- .Values.images.postgres.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.postgres" -}}
  {{- printf "%s/%s:%s" (include "images.postgres.repo.base" .) (include "images.postgres.repo.path" .) (include "images.postgres.tag" .) -}}
{{- end }}

{{/* ========== oauth2-proxy ========== */}}
{{- define "images.oauthProxy.repo.base" -}}
  {{- if and .Root.Values.images.oauthProxy .Root.Values.images.oauthProxy.repo }}
    {{- .Root.Values.images.repo.base | default .Root.Values.images.oauthProxy.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.oauthProxy.repo.path" -}}
  {{- if and .Root.Values.images.oauthProxy .Root.Values.images.oauthProxy.repo }}
    {{- .Root.Values.images.oauthProxy.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.oauthProxy.tag" -}}
  {{- if .Root.Values.images.oauthProxy }}
    {{- .Root.Values.images.oauthProxy.tag -}}
  {{- end }}
{{- end }}

{{- define "images.oauthProxy.pullPolicy" -}}
  {{- if .Root.Values.images.oauthProxy }}
    {{- .Root.Values.images.oauthProxy.pullPolicy | default "IfNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.oauthProxy" -}}
  {{- printf "%s/%s:%s" (include "images.oauthProxy.repo.base" .) (include "images.oauthProxy.repo.path" .) (include "images.oauthProxy.tag" .) -}}
{{- end }}

{{/* ========== sas-retrieval-agent-manager-vectorization-hub ========== */}}
{{- define "images.vectorizationHub.repo.base" -}}
  {{- if and .Values.images.vectorizationHub .Values.images.vectorizationHub.repo }}
    {{- .Values.images.repo.base | default .Values.images.vectorizationHub.repo.base -}}
  {{- end }}
{{- end }}

{{- define "images.vectorizationHub.repo.path" -}}
  {{- if and .Values.images.vectorizationHub .Values.images.vectorizationHub.repo }}
    {{- .Values.images.vectorizationHub.repo.path -}}
  {{- end }}
{{- end }}

{{- define "images.vectorizationHub.tag" -}}
  {{- if .Values.images.vectorizationHub }}
    {{- .Values.images.vectorizationHub.tag -}}
  {{- end }}
{{- end }}

{{- define "images.vectorizationHub.pullPolicy" -}}
  {{- if .Values.images.vectorizationHub }}
    {{- .Values.images.vectorizationHub.pullPolicy | default "ifNotPresent" }}
  {{- end }}
{{- end }}

{{- define "images.vectorizationHub" -}}
  {{- include "images.sas-retrieval-agent-manager-vectorization-hub.repo.base" . -}}/{{- include "images.sas-retrieval-agent-manager-vectorization-hub.repo.path" . -}}:{{- include "images.sas-retrieval-agent-manager-vectorization-hub.tag" . -}}
{{- end }}
