{{/*
Whether Viya SSO configuration should be rendered.

Gated on three things, all of which the job genuinely needs:
  - integrations.viya.enabled      -- the cluster runs Viya at all
  - integrations.viya.sso.enabled  -- the operator opted in to federation
  - ingress.enabled                -- Keycloak's realm paths come from the
                                      ingress config, and the Viya SASLogon
                                      client needs a dialable redirect URI
Returns a non-empty string when enabled, empty otherwise, so callers can use
it directly in an `if`.
*/}}
{{- define "viya.sso.enabled" -}}
{{- if and .Values.integrations.viya.enabled .Values.integrations.viya.sso.enabled .Values.ingress.enabled -}}
true
{{- end -}}
{{- end -}}

{{/*
Name prefix for every object this integration creates.
*/}}
{{- define "viya.sso.fullname" -}}
{{- printf "%s-viya-sso" (include "retrieval-agent-manager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "viya.sso.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
app.kubernetes.io/name: {{ include "viya.sso.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: viya-sso
app.kubernetes.io/part-of: {{ include "retrieval-agent-manager.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Base URL of the Viya deployment, without a trailing slash.
*/}}
{{- define "viya.sso.url" -}}
{{- .Values.integrations.viya.url | trimSuffix "/" -}}
{{- end -}}

{{/*
The issuer URI an administrator configured on SASLogon's sas.logon.jwt
definition. Defaults to {viya url}/SASLogon, which is what SASLogon serves
once `issuer.uri` is set. The job refuses to run if Viya's discovery document
disagrees with this value.
*/}}
{{- define "viya.sso.issuerURI" -}}
{{- if .Values.integrations.viya.sso.issuerURI -}}
{{- .Values.integrations.viya.sso.issuerURI | trimSuffix "/" -}}
{{- else -}}
{{- printf "%s/SASLogon" (include "viya.sso.url" .) -}}
{{- end -}}
{{- end -}}

{{/*
Redirect URI the Viya SASLogon OAuth client must allow. This is the Keycloak
broker endpoint for our IdP alias, reachable from the user's browser, so it is
built from the public ingress rather than the cluster-internal service.
*/}}
{{- define "viya.sso.redirectURI" -}}
{{- $kcPath := first .Values.ingress.keycloak.paths | trimSuffix "/" -}}
{{- printf "https://%s%s/realms/%s/broker/%s/endpoint" .Values.ingress.domain $kcPath .Values.iam.keycloak.config.realm .Values.integrations.viya.sso.idpAlias -}}
{{- end -}}

{{/*
Name of the Secret holding the Viya OAuth client secret.
*/}}
{{- define "viya.sso.clientSecretName" -}}
{{- if .Values.integrations.viya.sso.existingClientSecret -}}
{{- .Values.integrations.viya.sso.existingClientSecret -}}
{{- else -}}
{{- printf "%s-client-secret" (include "viya.sso.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
The Viya OAuth client secret.

Mirrors "keycloak.clientSecret": an explicit value wins, otherwise reuse the
value already stored in the cluster so `helm upgrade` does not rotate a secret
that is also registered on the Viya side, and only generate a fresh one on a
genuinely new install.
*/}}
{{- define "viya.sso.clientSecret" -}}
{{- if .Values.integrations.viya.sso.clientSecret -}}
  {{- .Values.integrations.viya.sso.clientSecret -}}
{{- else -}}
  {{- $name := printf "%s-client-secret" (include "viya.sso.fullname" .) -}}
  {{- $existing := lookup "v1" "Secret" .Release.Namespace $name -}}
  {{- if and $existing (index $existing.data "client-secret") -}}
    {{- (index $existing.data "client-secret") | b64dec -}}
  {{- else -}}
    {{- randAlphaNum 32 | b64enc | replace "+" "-" | replace "/" "_" | replace "=" "" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Whether anything in this integration needs Viya administrator credentials.
*/}}
{{- define "viya.sso.needsAdmin" -}}
{{- if or .Values.integrations.viya.sso.registerClient .Values.integrations.viya.sso.configureSASLogon -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether the chart should restart sas-logon-app itself after changing the
issuer URI. Only possible when Viya shares this cluster and we have been told
which namespace it is in.
*/}}
{{- define "viya.sso.canRestartSASLogon" -}}
{{- if and (include "viya.sso.enabled" .) .Values.integrations.viya.sso.configureSASLogon .Values.integrations.viya.namespace -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether the job needs to reach the Kubernetes API at all.

Two separate things need it, and they are NOT gated the same way:

  - the pre-change backup ConfigMap, which the job writes in THIS namespace
    before touching SASLogon's issuer. Needed whenever `configureSASLogon` is
    on, with or without a Viya namespace.
  - restarting sas-logon-app afterwards, which additionally needs
    `integrations.viya.namespace` -- see "viya.sso.canRestartSASLogon".

Gating the service account token on the restart alone left the common case
(SSO on, no Viya namespace) with RBAC granted but no token to use it, so the
job died writing its backup -- before ever reaching the manual-restart
instructions it prints for exactly that configuration.

Usage: {{ if include "viya.sso.needsKubeAPI" . }}
*/}}
{{- define "viya.sso.needsKubeAPI" -}}
{{- if and (include "viya.sso.enabled" .) .Values.integrations.viya.sso.configureSASLogon -}}
true
{{- end -}}
{{- end -}}

{{/*
Validation. Emitted from the job so a misconfiguration fails at `helm template`
time rather than as a CrashLoopBackOff twenty minutes into an install.
*/}}
{{- define "viya.sso.validate" -}}
{{- if include "viya.sso.enabled" . -}}
{{- $errors := list -}}
{{- if not .Values.integrations.viya.url -}}
  {{- $errors = append $errors "integrations.viya.url is required when integrations.viya.sso.enabled is true" -}}
{{- else if not (hasPrefix "https://" .Values.integrations.viya.url) -}}
  {{- $errors = append $errors "integrations.viya.url must be an https:// URL" -}}
{{- end -}}
{{- if not .Values.ingress.domain -}}
  {{- $errors = append $errors "ingress.domain is required when integrations.viya.sso.enabled is true" -}}
{{- end -}}
{{- if and (include "viya.sso.needsAdmin" .) (not .Values.integrations.viya.sso.adminSecret) -}}
  {{- $errors = append $errors "integrations.viya.sso.adminSecret is required: the chart registers the SASLogon OAuth client and sets SASLogon's issuer URI on your behalf, and both authenticate as a Viya administrator. Point it at a Secret holding 'username' and 'password', or set integrations.viya.sso.registerClient and .configureSASLogon to false and perform those two steps yourself" -}}
{{- end -}}
{{- if $errors -}}
  {{- $msg := printf "\n\nViya SSO configuration failed with %d error(s):\n" (len $errors) -}}
  {{- range $i, $e := $errors -}}
    {{- $msg = printf "%s  [%d] %s\n" $msg (add1 $i) $e -}}
  {{- end -}}
  {{- fail $msg -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Viya's entry for oauth2-proxy's extra_jwt_issuers, in the "<issuer>=<audience>"
form that option expects -- or EMPTY when this release should not contribute
one.

Self-gating on purpose. The entry is appended to the operator's
`iam.oauthProxy.extraJwtIssuers` list by a single emitter in
oauth2-proxy/oauth-configmap.yaml, so returning empty is what keeps that
caller from having to repeat the conditions.

Usage: {{ with include "viya.sso.extraJwtIssuer" . }}
*/}}
{{- define "viya.sso.extraJwtIssuer" -}}
{{- if and (include "viya.sso.enabled" .) .Values.integrations.viya.sso.acceptViyaTokens -}}
{{- printf "%s/oauth/token=%s" (include "viya.sso.issuerURI" .) (.Values.integrations.viya.sso.tokenAudience | default "openid") -}}
{{- end -}}
{{- end -}}

{{/*
Whether oauth2-proxy should pin its login_url to the Viya identity provider.

Non-empty when SSO is on and `idpHint` has not been turned off. Defaults ON
because once federation is the way in, Keycloak's provider chooser presents a
choice the user does not have.

Read with hasKey rather than `| default true`: Go templates treat `false` as
empty, so `default true` would return TRUE for an explicit `idpHint: false` and
the off switch would do nothing.
*/}}
{{- define "viya.sso.idpHint" -}}
{{- if include "viya.sso.enabled" . -}}
{{- $sso := .Values.integrations.viya.sso -}}
{{- $hint := true -}}
{{- if hasKey $sso "idpHint" }}{{- $hint = $sso.idpHint -}}{{- end -}}
{{- if $hint -}}true{{- end -}}
{{- end -}}
{{- end -}}
