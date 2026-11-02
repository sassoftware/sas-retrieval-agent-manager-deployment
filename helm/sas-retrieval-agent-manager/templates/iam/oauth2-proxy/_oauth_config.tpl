{{/*
The body of oauth2-proxy.cfg, indented ready for the ConfigMap block scalar.

A named template rather than inline YAML so that one thing produces this
content and two consume it: the ConfigMap that projects it into the sidecars,
and "oauth2-proxy.configChecksum", which hashes it into the pod annotations so
a change to it actually causes a rollout.

Keeping those in step matters. oauth2-proxy reads its config once, at startup,
so a checksum taken over anything but the real content would either miss a
change -- no rollout, sidecars silently left on the old configuration -- or
move when nothing had, restarting pods for no reason.

The indentation is carried here rather than applied with nindent at the call
site: nindent rewrites blank lines as whitespace-only ones, which changes the
bytes without changing the meaning, and would bump the checksum on upgrade.

Usage: {{ include "oauth2-proxy.config" . }}
*/}}
{{- define "oauth2-proxy.config" -}}
    # http_address is set via OAUTH2_PROXY_HTTP_ADDRESS env var in sidecar (see _oauth_sidecar.tpl)
    # upstreams is set via OAUTH2_PROXY_UPSTREAMS env var in sidecar (see _oauth_sidecar.tpl)
    reverse_proxy             = true
    ssl_insecure_skip_verify  = false
    upstream_timeout          = "300s"

    # Provider Configuration
    provider                = "oidc"
    skip_provider_button    = true
    skip_jwt_bearer_tokens  = true
    {{- /*
      Trusted bearer-token issuers, from two sources that must share ONE key:
      the operator's `iam.oauthProxy.extraJwtIssuers` list, and -- when Viya SSO
      is on -- SASLogon itself, for callers that hit the API without a browser
      session (a SAS Studio or Job Execution process, for example).

      Emitting them separately renders `extra_jwt_issuers` twice; oauth2-proxy
      keeps one and silently drops the other, so whichever issuer loses simply
      stops authenticating with nothing in the config or the logs to say why.
      Hence one emitter, fed by both.

      Viya's entry requires SASLogon to have an external issuer.uri configured.
      Until an administrator sets one it issues
      http://localhost/SASLogon/oauth/token, which is not dialable from here.
    */}}
    {{- $issuers := list }}
    {{- $seen := dict }}
    {{- range .Values.iam.oauthProxy.extraJwtIssuers }}
    {{- if not (hasKey $seen .issuer) }}
    {{- $issuers = append $issuers (printf "%s=%s" .issuer .audience) }}
    {{- $_ := set $seen .issuer true }}
    {{- end }}
    {{- end }}
    {{- with include "viya.sso.extraJwtIssuer" . }}
    {{- /*
      Listed explicitly as well? The operator's entry wins -- they may have
      deliberately chosen a different audience, and repeating the issuer would
      leave oauth2-proxy with two contradictory rules for one issuer.
    */}}
    {{- $viyaIssuer := . | splitList "=" | first }}
    {{- if not (hasKey $seen $viyaIssuer) }}
    {{- $issuers = append $issuers . }}
    {{- end }}
    {{- end }}
    {{- if $issuers }}
    extra_jwt_issuers       = "{{ join ";" $issuers }}"
    {{- end }}
    code_challenge_method   = "S256"

    redirect_url            = "{{ include "oauth2-proxy.ingressURL" . }}/callback"
    oidc_issuer_url         = "{{ include "keycloak.ingressURL" . }}"
{{- if include "viya.sso.idpHint" . }}
    # kc_idp_hint sends the browser straight to Viya's SASLogon instead of
    # stopping at Keycloak's login page. Without it a user signing in to RAM is
    # asked to choose a provider on every visit, which is not a choice they have
    # -- federation is the only way in once SSO is on.
    #
    # It also has to live HERE rather than be applied to the live ConfigMap
    # afterwards: Helm renders the whole oauth2-proxy.cfg key, so an in-place
    # edit is discarded by the next `helm upgrade`.
    #
    # Set integrations.viya.sso.idpHint to false to keep the chooser -- needed
    # if local Keycloak accounts must still be able to reach the login form.
    login_url               = "{{ include "keycloak.ingressURL" . }}/protocol/openid-connect/auth?kc_idp_hint={{ .Values.integrations.viya.sso.idpAlias }}"
{{- else }}
    login_url               = "{{ include "keycloak.ingressURL" . }}/protocol/openid-connect/auth"
{{- end }}
    whitelist_domains       = "{{ include "oauth2-proxy.domain" . }}"
    proxy_prefix            = "{{ include "oauth2-proxy.prefix" . }}"
    email_domains           = "*"

    # Skip OIDC discovery and provide internal URLs directly.
    # If OIDC discovery is not skipped, external URLs returned from the .well-known endpoint
    # will be used. These may not be reachable from within the cluster.
    skip_oidc_discovery = true
    oidc_jwks_url       = "{{ include "keycloak.internalURL" . }}/protocol/openid-connect/certs"
    redeem_url          = "{{ include "keycloak.internalURL" . }}/protocol/openid-connect/token"
    validate_url        = "{{ include "keycloak.internalURL" . }}/protocol/openid-connect/userinfo"

    # Cookie Configuration
    cookie_name     = "esp_oauth2_proxy"
    cookie_path     = "/"
    cookie_expire   = "12h"
    cookie_refresh  = "60s"    
    cookie_secure   = true
    cookie_domains  = [
      "{{ .Values.ingress.domain }}",
      "{{ include "oauth2-proxy.fullname" . | lower }}.{{ .Release.Namespace }}.svc.cluster.local",
    ]
    cookie_samesite = "lax"

    cookie_csrf_per_request       = true
    cookie_csrf_per_request_limit = 10

    # Auth Response Headers (for nginx auth subrequest pattern)
    set_authorization_header  = true
    set_xauthrequest          = true
    pass_access_token         = true

    # Pass ID token to upstream in Authorization header (required for reverse_proxy/sidecar mode)
    pass_authorization_header = true

    # CORS and preflight
    skip_auth_preflight       = true

    # bypass authentication for requests that match the method & path. Format: method=path_regex OR path_regex alone for all methods
    # skip_auth_routes = [
    #   "GET=^/$"
    # ]
{{- end -}}
