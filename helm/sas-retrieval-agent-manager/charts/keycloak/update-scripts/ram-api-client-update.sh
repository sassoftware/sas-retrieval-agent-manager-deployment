#!/usr/bin/env bash

set -e -o pipefail -o nounset

function maybe_create_api_client() {
  client_id=$(/opt/keycloak/bin/kcadm.sh get clients -r "${KEYCLOAK_REALM}" \
    -q "clientId=sas-ram-api" --fields id,clientId --format csv \
    --config "${KCADM_CFG_PATH}" | cut -d',' -f1 | sed 's/"//g')

  if [ -n "$client_id" ]; then
    echo "Default API client found in realm '${KEYCLOAK_REALM}', skipping creation."
    return 0
  fi

  cat > /workdir/ram-api-client.json <<EOF
{
  "clientId": "sas-ram-api",
  "name": "SAS RAM API Client",
  "description": "The default public client for SAS RAM API access.",
  "rootUrl": "https://${KEYCLOAK_FQDN}/",
  "adminUrl": "",
  "baseUrl": "",
  "surrogateAuthRequired": false,
  "enabled": true,
  "alwaysDisplayInConsole": false,
  "clientAuthenticatorType": "client-secret",
  "redirectUris": [
    "/*"
  ],
  "webOrigins": [
    "+"
  ],
  "notBefore": 0,
  "bearerOnly": false,
  "consentRequired": true,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "serviceAccountsEnabled": false,
  "publicClient": true,
  "frontchannelLogout": true,
  "protocol": "openid-connect",
  "attributes": {
    "request.object.signature.alg": "any",
    "post.logout.redirect.uris": "+",
    "frontchannel.logout.session.required": "true",
    "oauth2.device.authorization.grant.enabled": "true",
    "backchannel.logout.revoke.offline.tokens": "false",
    "use.refresh.tokens": "true",
    "realm_client": "false",
    "oidc.ciba.grant.enabled": "false",
    "id.token.signed.response.alg": "RS256",
    "backchannel.logout.session.required": "true",
    "client_credentials.use_refresh_token": "false",
    "require.pushed.authorization.requests": "false",
    "request.object.encryption.enc": "any",
    "pkce.code.challenge.method": "S256",
    "request.object.encryption.alg": "any",
    "client.introspection.response.allow.jwt.claim.enabled": "false",
    "standard.token.exchange.enabled": "false",
    "access.token.signed.response.alg": "RS256",
    "client.use.lightweight.access.token.enabled": "false",
    "request.object.required": "not required",
    "access.token.header.type.rfc9068": "false",
    "tls.client.certificate.bound.access.tokens": "false",
    "acr.loa.map": "{}",
    "display.on.consent.screen": "false",
    "token.response.type.bearer.lower-case": "false"
  },
  "authenticationFlowBindingOverrides": {},
  "fullScopeAllowed": false,
  "nodeReRegistrationTimeout": -1,
  "protocolMappers": [
    {
      "name": "SAS RAM roles",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-usermodel-client-role-mapper",
      "consentRequired": false,
      "config": {
        "introspection.token.claim": "true",
        "multivalued": "true",
        "userinfo.token.claim": "true",
        "id.token.claim": "true",
        "lightweight.claim": "false",
        "access.token.claim": "true",
        "claim.name": "resource_access.${RAM_APP_CLIENT}.roles",
        "jsonType.label": "String",
        "usermodel.clientRoleMapping.clientId": "${RAM_APP_CLIENT}"
      }
    },
    {
      "name": "SAS RAM audience",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "consentRequired": false,
      "config": {
        "included.client.audience": "${RAM_APP_CLIENT}",
        "id.token.claim": "true",
        "lightweight.claim": "false",
        "access.token.claim": "true",
        "introspection.token.claim": "true"
      }
    }
  ],
  "defaultClientScopes": [
    "web-origins",
    "acr",
    "profile",
    "roles",
    "basic",
    "email"
  ],
  "optionalClientScopes": [
    "organization",
    "offline_access",
    "microprofile-jwt"
  ],
  "access": {
    "view": true,
    "configure": true,
    "manage": true
  }
}
EOF

  echo "Creating default API client in realm '${KEYCLOAK_REALM}'..."
  if ! /opt/keycloak/bin/kcadm.sh create clients         \
     -r "${KEYCLOAK_REALM}" --config "${KCADM_CFG_PATH}" \
     -f /workdir/ram-api-client.json; then
    echo "Failed to create default API client in realm '${KEYCLOAK_REALM}'."
    return 1
  fi
}

function add_ram_app_scope_mapping() {
  echo "Adding SAS RAM application scope mapping to API client..."
  api_client_id="$(/opt/keycloak/bin/kcadm.sh get clients \
    -r "${KEYCLOAK_REALM}" --config "${KCADM_CFG_PATH}"   \
    -q "clientId=sas-ram-api" --fields id,clientId        \
    --format csv | cut -d',' -f1 | sed 's/"//g')"
  if [ -z "${api_client_id}" ]; then
    echo "API client 'sas-ram-api' not found in realm '${KEYCLOAK_REALM}'."
    return 1
  fi

  app_client_id="$(/opt/keycloak/bin/kcadm.sh get clients -r "${KEYCLOAK_REALM}" \
    -q "clientId=${RAM_APP_CLIENT}" --fields id,clientId --format csv            \
    --config "${KCADM_CFG_PATH}" | cut -d',' -f1 | sed 's/"//g')"
  if [ -z "${app_client_id}" ]; then
    echo "SAS RAM application client '${RAM_APP_CLIENT}' not found in realm '${KEYCLOAK_REALM}'."
    return 1
  fi

  app_roles="$(/opt/keycloak/bin/kcadm.sh get "clients/${app_client_id}/roles" \
    -r "${KEYCLOAK_REALM}" --config "${KCADM_CFG_PATH}" --fields 'id,name,description')"
  if [ -z "${app_roles}" ]; then
    echo "No roles found for SAS RAM application client '${RAM_APP_CLIENT}' in realm '${KEYCLOAK_REALM}'."
    return 1
  fi

  /opt/keycloak/bin/kcadm.sh create "clients/${api_client_id}/scope-mappings/clients/${app_client_id}" \
    -r "${KEYCLOAK_REALM}" --config "${KCADM_CFG_PATH}" \
    -f - <<<"${app_roles}"
}

maybe_create_api_client || exit 1

add_ram_app_scope_mapping
