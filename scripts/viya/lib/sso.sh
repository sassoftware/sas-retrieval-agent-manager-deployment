#!/usr/bin/env bash

get_viya_token() {
  http_request POST "$VIYA_URL/SASLogon/oauth/token" '' \
    application/x-www-form-urlencoded '' \
    --user 'sas.cli:' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$VIYA_USER" \
    --data-urlencode "password=$VIYA_PASSWORD"
  expect_http 'Viya authentication' 200
  VIYA_TOKEN=$(response_value '.access_token') \
    || die "Viya authentication did not return an access token."
  [[ -n "$VIYA_TOKEN" ]] || die "Viya authentication returned an empty access token."
}

viya_token_issuer() {
  local payload decoded padding
  payload=${VIYA_TOKEN#*.}
  payload=${payload%%.*}
  [[ -n "$payload" && "$payload" != "$VIYA_TOKEN" ]] \
    || die "The Viya access token is not a JSON Web Token."
  payload=$(printf '%s' "$payload" | tr '_-' '/+')
  padding=$(( (4 - ${#payload} % 4) % 4 ))
  while (( padding > 0 )); do
    payload+='='
    padding=$((padding - 1))
  done
  decoded=$(printf '%s' "$payload" | base64 --decode 2>/dev/null) \
    || die "Could not read the SAS Logon issuer from the Viya token."
  jq --raw-output '.iss // empty' <<<"$decoded"
}

ensure_saslogon_issuer() {
  local expected_issuer current_issuer script_file
  expected_issuer="$ISSUER_URI/oauth/token"
  get_viya_token
  current_issuer=$(viya_token_issuer)
  if [[ "$current_issuer" == "$expected_issuer" ]]; then
    printf 'Verified SAS Logon issuer URI %s.\n' "$ISSUER_URI"
    return
  fi
  [[ "$CHECK_ONLY" == false ]] \
    || die "SAS Logon issuer is '$current_issuer'; expected '$expected_issuer'."

  script_file="$TEMPORARY_DIRECTORY/set-saslogon-issuer.sh"
  cat >"$script_file" <<'REMOTE_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

ISSUER_URI=${1:?SAS Logon issuer URI is required}
SASBOOT_PASSWORD=$(/opt/sas/viya/home/bin/sas-bootstrap-config kv read --global \
  'sas.logon/initial/password')
[[ -n "$SASBOOT_PASSWORD" ]] || { printf 'SAS boot password is not available.\n' >&2; exit 1; }

TEMP_DIR=$(mktemp -d)
AUTH_CONFIG="$TEMP_DIR/auth.curl"
API_CONFIG="$TEMP_DIR/api.curl"
TOKEN_FILE="$TEMP_DIR/token.json"
DEFINITIONS_FILE="$TEMP_DIR/definitions.json"
CONFIGURATIONS_FILE="$TEMP_DIR/configurations.json"
trap 'rm -rf "$TEMP_DIR"; unset SASBOOT_PASSWORD TOKEN' EXIT
umask 077
touch "$AUTH_CONFIG" "$API_CONFIG"
chmod 600 "$AUTH_CONFIG" "$API_CONFIG"

write_option() {
  local option=$1 value=$2
  printf '%s' "$value" | python3 -c \
    'import json,sys; print(sys.argv[1] + " = " + json.dumps(sys.stdin.read()))' \
    "$option" >>"$CURL_CONFIG"
}

CURL_CONFIG=$AUTH_CONFIG
write_option user 'sas.cli:'
write_option data-urlencode 'grant_type=password'
write_option data-urlencode 'username=sasboot'
write_option data-urlencode "password=$SASBOOT_PASSWORD"
token_status=$(curl --silent --show-error --insecure --config "$AUTH_CONFIG" \
  --output "$TOKEN_FILE" --write-out '%{http_code}' \
  'https://localhost:8080/SASLogon/oauth/token')
: >"$AUTH_CONFIG"
[[ "$token_status" == 200 ]] \
  || { printf 'SAS Logon authentication returned HTTP %s.\n' "$token_status" >&2; exit 1; }
TOKEN=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["access_token"])' "$TOKEN_FILE")
[[ -n "$TOKEN" ]] || { printf 'SAS Logon did not return an access token.\n' >&2; exit 1; }
: >"$TOKEN_FILE"

CURL_CONFIG=$API_CONFIG
write_option header "Authorization: Bearer $TOKEN"
write_option header 'Accept: application/json'
definitions_status=$(curl --silent --show-error --insecure --config "$API_CONFIG" \
  --output "$DEFINITIONS_FILE" --write-out '%{http_code}' \
  'https://sas-configuration/configuration/definitions?limit=1000')
[[ "$definitions_status" == 200 ]] \
  || { printf 'SAS configuration definition lookup returned HTTP %s.\n' "$definitions_status" >&2; exit 1; }
definition_type=$(python3 - "$DEFINITIONS_FILE" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
items = [item for item in data.get("items", []) if item.get("name") == "sas.logon.jwt"]
if not items:
    raise SystemExit("SAS configuration definition sas.logon.jwt was not found.")
item = max(items, key=lambda value: value.get("definitionVersion", 0))
link = next((value for value in item.get("links", [])
             if value.get("rel") == "createConfigurations"), None)
if not link or not link.get("itemType"):
    raise SystemExit("SAS configuration definition has no createConfigurations item type.")
print(link["itemType"])
PY
)

configurations_status=$(curl --silent --show-error --insecure --config "$API_CONFIG" \
  --output "$CONFIGURATIONS_FILE" --write-out '%{http_code}' \
  'https://sas-configuration/configuration/configurations?definitionName=sas.logon.jwt')
[[ "$configurations_status" == 200 ]] \
  || { printf 'SAS Logon configuration lookup returned HTTP %s.\n' "$configurations_status" >&2; exit 1; }
config_state=$(python3 - "$CONFIGURATIONS_FILE" "$ISSUER_URI" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
issuer = sys.argv[2]
for item in data.get("items", []):
    configuration = item.get("configuration", {})
    if configuration.get("issuer.uri") == issuer:
        print("MATCH")
        break
    update = next((link.get("href") for link in item.get("links", [])
                   if link.get("rel") == "update"), None)
    if update:
        print("UPDATE\t" + update)
        break
else:
    print("CREATE")
PY
)
[[ "$config_state" == MATCH ]] || {
  payload=$(python3 - "$ISSUER_URI" <<'PY'
import json
import sys
print(json.dumps({"issuer.uri": sys.argv[1]}))
PY
  )
  if [[ "$config_state" == CREATE ]]; then
    target='https://sas-configuration/configuration/configurations'
    method=POST
  elif [[ "$config_state" == UPDATE$'\t'* ]]; then
    href=${config_state#*$'\t'}
    if [[ "$href" == https://* ]]; then
      target=$href
    else
      target="https://sas-configuration$href"
    fi
    method=PUT
  else
    printf 'Could not select a SAS Logon configuration update link.\n' >&2
    exit 1
  fi
  status=$(curl --silent --show-error --insecure --config "$API_CONFIG" \
    --request "$method" --header "Content-Type: $definition_type" \
    --data-binary "$payload" --output /dev/null --write-out '%{http_code}' \
    "$target")
  case "$status" in
    200|201|204) ;;
    *) printf 'SAS Logon issuer update returned HTTP %s.\n' "$status" >&2; exit 1 ;;
  esac
}
printf 'SAS Logon issuer configuration is ready.\n'
REMOTE_SCRIPT
  chmod 600 "$script_file"

  kubectl_cmd exec --stdin --namespace "$VIYA_NAMESPACE" deployment/sas-logon-app \
    --container=sas-logon-app -- bash -s -- "$ISSUER_URI" <"$script_file" >/dev/null \
    || die "Could not set SAS Logon issuer.uri through the SAS Configuration API."
  kubectl_cmd delete pods --namespace "$VIYA_NAMESPACE" \
    --selector 'app=sas-logon-app' >/dev/null \
    || die "Could not restart SAS Logon pods after the issuer change."
  kubectl_cmd rollout status deployment/sas-logon-app \
    --namespace "$VIYA_NAMESPACE" --timeout=180s

  get_viya_token
  current_issuer=$(viya_token_issuer)
  [[ "$current_issuer" == "$expected_issuer" ]] \
    || die "SAS Logon issuer is '$current_issuer' after restart; expected '$expected_issuer'."
  printf 'Verified SAS Logon issuer URI %s after restart.\n' "$ISSUER_URI"
}

verify_sso_prerequisites() {
  local base idp clients client
  kubectl_cmd get secret "$VIYA_SSO_SECRET_NAME" --namespace "$RAM_NAMESPACE" \
    --output name >/dev/null \
    || die "Required SSO client Secret '$RAM_NAMESPACE/$VIYA_SSO_SECRET_NAME' does not exist."

  get_viya_token
  [[ "$(viya_token_issuer)" == "$ISSUER_URI/oauth/token" ]] \
    || die "The Viya token issuer does not match '$ISSUER_URI/oauth/token'."
  get_keycloak_admin_token
  base=$(keycloak_realm_url)

  http_request GET "$base/identity-provider/instances/$IDP_ALIAS" "$KC_TOKEN" '' ''
  expect_http "Read Keycloak identity provider '$IDP_ALIAS'" 200
  idp=$(<"$RESPONSE_FILE")
  jq --exit-status \
    '.enabled == true and .storeToken == true and .config.clientId == "ram-client"' \
    <<<"$idp" >/dev/null \
    || die "Keycloak identity provider '$IDP_ALIAS' is not ready for MCP user tokens."

  http_request GET "$base/clients" "$KC_TOKEN" '' '' \
    --get --data-urlencode "clientId=$RAM_KC_CLIENT_ID"
  expect_http "Read Keycloak client '$RAM_KC_CLIENT_ID'" 200
  clients=$(<"$RESPONSE_FILE")
  client=$(jq -c '.[0] // {}' <<<"$clients")
  jq --exit-status --arg alias "$IDP_ALIAS" \
    '(.attributes["external.token.enabled"] == "true")
     and (.attributes["external.token.idp"] == $alias)' <<<"$client" >/dev/null \
    || die "Keycloak client '$RAM_KC_CLIENT_ID' is not ready for user-token MCP access."
  printf 'Verified the existing RAM SSO configuration for MCP setup.\n'
}

get_keycloak_admin_token() {
  http_request POST \
    "$RAM_URL/SASRetrievalAgentManager/auth/realms/master/protocol/openid-connect/token" \
    '' application/x-www-form-urlencoded '' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' \
    --data-urlencode "username=$RAM_KC_USER" \
    --data-urlencode "password=$RAM_KC_PASSWORD"
  expect_http 'Keycloak authentication' 200
  KC_TOKEN=$(response_value '.access_token') \
    || die "Keycloak authentication did not return an access token."
  [[ -n "$KC_TOKEN" ]] || die "Keycloak authentication returned an empty access token."
}

prepare_sso_client_secret() {
  VIYA_CLIENT_SECRET_FILE="$TEMPORARY_DIRECTORY/viya-sso-client-secret"
  if kubectl_cmd get secret "$VIYA_SSO_SECRET_NAME" \
    --namespace "$RAM_NAMESPACE" >/dev/null 2>&1; then
    VIYA_CLIENT_SECRET=$(kubernetes_secret_value \
      "$RAM_NAMESPACE" "$VIYA_SSO_SECRET_NAME" 'client-secret')
    printf '%s' "$VIYA_CLIENT_SECRET" >"$VIYA_CLIENT_SECRET_FILE"
    chmod 600 "$VIYA_CLIENT_SECRET_FILE"
    unset VIYA_CLIENT_SECRET
    printf 'Found SSO client Secret %s/%s.\n' \
      "$RAM_NAMESPACE" "$VIYA_SSO_SECRET_NAME"
    return
  fi

  [[ "$CHECK_ONLY" == false ]] \
    || die "Required SSO client Secret '$RAM_NAMESPACE/$VIYA_SSO_SECRET_NAME' does not exist."

  VIYA_CLIENT_SECRET=$(random_secret)
  printf '%s' "$VIYA_CLIENT_SECRET" >"$VIYA_CLIENT_SECRET_FILE"
  chmod 600 "$VIYA_CLIENT_SECRET_FILE"
  unset VIYA_CLIENT_SECRET
  kubectl_cmd create secret generic "$VIYA_SSO_SECRET_NAME" \
    --namespace "$RAM_NAMESPACE" \
    --from-file="client-secret=$VIYA_CLIENT_SECRET_FILE" >/dev/null
  printf 'Created SSO client Secret %s/%s.\n' \
    "$RAM_NAMESPACE" "$VIYA_SSO_SECRET_NAME"
}

ensure_viya_sso_client() {
  local redirect_uri encoded_client body
  redirect_uri="$RAM_URL/SASRetrievalAgentManager/auth/realms/$RAM_KC_REALM/broker/$IDP_ALIAS/endpoint"
  encoded_client=$(jq --null-input --raw-output --arg value "$VIYA_SSO_CLIENT_ID" '$value | @uri')
  body=$(jq --null-input \
    --arg client_id "$VIYA_SSO_CLIENT_ID" \
    --rawfile client_secret "$VIYA_CLIENT_SECRET_FILE" \
    --arg redirect_uri "$redirect_uri" \
    '{
      client_id: $client_id,
      client_secret: $client_secret,
      authorities: ["SASAdministrators"],
      authorized_grant_types: ["authorization_code", "refresh_token"],
      name: "RAM Keycloak",
      scope: ["openid", "uaa.user", "profile", "email"],
      redirect_uri: [$redirect_uri],
      autoapprove: true
    }')

  http_request GET "$VIYA_URL/SASLogon/oauth/clients/$encoded_client" "$VIYA_TOKEN" '' ''
  if [[ "$HTTP_STATUS" == 200 ]]; then
    if jq --exit-status \
      --arg client_id "$VIYA_SSO_CLIENT_ID" \
      --arg redirect_uri "$redirect_uri" \
      '(.client_id == $client_id)
       and ((.authorities // []) == ["SASAdministrators"])
       and ((.authorized_grant_types // []) | sort == ["authorization_code", "refresh_token"])
       and ((.scope // []) | sort == ["email", "openid", "profile", "uaa.user"])
       and ((.redirect_uri // []) == [$redirect_uri])
       and (.autoapprove == true)' "$RESPONSE_FILE" >/dev/null; then
      if [[ "$CHECK_ONLY" == true ]]; then
        printf 'Verified Viya OAuth client %s.\n' "$VIYA_SSO_CLIENT_ID"
        return
      fi
    else
      [[ "$CHECK_ONLY" == false ]] \
        || die "Viya OAuth client '$VIYA_SSO_CLIENT_ID' has conflicting configuration."
    fi
    [[ "$CHECK_ONLY" == false ]] \
      || die "Viya OAuth client '$VIYA_SSO_CLIENT_ID' has conflicting configuration."

    http_request PUT "$VIYA_URL/SASLogon/oauth/clients/$encoded_client" \
      "$VIYA_TOKEN" application/json "$body"
    expect_http "Update Viya OAuth client '$VIYA_SSO_CLIENT_ID'" 200 204
    local secret_body
    secret_body=$(jq --null-input \
      --arg client_id "$VIYA_SSO_CLIENT_ID" \
      --rawfile secret "$VIYA_CLIENT_SECRET_FILE" \
      '{clientId: $client_id, secret: $secret}')
    http_request PUT "$VIYA_URL/SASLogon/oauth/clients/$encoded_client/secret" \
      "$VIYA_TOKEN" application/json "$secret_body"
    expect_http "Reset Viya OAuth client '$VIYA_SSO_CLIENT_ID' secret" 200 204
    printf 'Updated Viya OAuth client %s.\n' "$VIYA_SSO_CLIENT_ID"
    return
  fi
  [[ "$HTTP_STATUS" == 404 ]] \
    || die "Viya OAuth client lookup returned HTTP $HTTP_STATUS: $(sanitized_error)"
  [[ "$CHECK_ONLY" == false ]] \
    || die "Viya OAuth client '$VIYA_SSO_CLIENT_ID' does not exist."

  http_request POST "$VIYA_URL/SASLogon/oauth/clients" "$VIYA_TOKEN" application/json "$body"
  expect_http "Create Viya OAuth client '$VIYA_SSO_CLIENT_ID'" 200 201
  printf 'Created Viya OAuth client %s.\n' "$VIYA_SSO_CLIENT_ID"
}

keycloak_realm_url() {
  printf '%s/SASRetrievalAgentManager/auth/admin/realms/%s' "$RAM_URL" "$RAM_KC_REALM"
}

ensure_keycloak_identity_provider() {
  local discovery auth_url token_url userinfo_url jwks_url issuer logout_url body base
  http_request GET "$VIYA_URL/SASLogon/.well-known/openid-configuration" '' '' ''
  expect_http 'Read the Viya OpenID Connect configuration' 200
  discovery=$(<"$RESPONSE_FILE")
  auth_url=$(jq --exit-status --raw-output '.authorization_endpoint' <<<"$discovery") \
    || die "The Viya discovery document has no authorization endpoint."
  token_url=$(jq --exit-status --raw-output '.token_endpoint' <<<"$discovery") \
    || die "The Viya discovery document has no token endpoint."
  userinfo_url=$(jq --exit-status --raw-output '.userinfo_endpoint' <<<"$discovery") \
    || die "The Viya discovery document has no user information endpoint."
  jwks_url=$(jq --exit-status --raw-output '.jwks_uri' <<<"$discovery") \
    || die "The Viya discovery document has no JSON Web Key Set endpoint."
  issuer=$(jq --exit-status --raw-output '.issuer' <<<"$discovery") \
    || die "The Viya discovery document has no issuer."
  logout_url=$(jq --raw-output '.end_session_endpoint // empty' <<<"$discovery")

  body=$(jq --null-input \
    --arg alias "$IDP_ALIAS" \
    --arg client_id "$VIYA_SSO_CLIENT_ID" \
    --rawfile client_secret "$VIYA_CLIENT_SECRET_FILE" \
    --arg auth_url "$auth_url" \
    --arg token_url "$token_url" \
    --arg userinfo_url "$userinfo_url" \
    --arg jwks_url "$jwks_url" \
    --arg issuer "$issuer" \
    --arg logout_url "$logout_url" \
    '{
      alias: $alias,
      displayName: "SAS Viya",
      providerId: "oidc",
      enabled: true,
      trustEmail: true,
      storeToken: true,
      config: {
        clientId: $client_id,
        clientSecret: $client_secret,
        authorizationUrl: $auth_url,
        tokenUrl: $token_url,
        userInfoUrl: $userinfo_url,
        jwksUrl: $jwks_url,
        issuer: $issuer,
        logoutUrl: $logout_url,
        defaultScope: "openid profile email",
        validateSignature: "true",
        useJwksUrl: "true",
        isAccessTokenJWT: "true"
      }
    }')
  base=$(keycloak_realm_url)
  http_request GET "$base/identity-provider/instances/$IDP_ALIAS" "$KC_TOKEN" '' ''
  if [[ "$HTTP_STATUS" == 200 ]]; then
    if [[ "$CHECK_ONLY" == true ]]; then
      jq --exit-status \
        --arg alias "$IDP_ALIAS" \
        --arg client_id "$VIYA_SSO_CLIENT_ID" \
        --arg auth_url "$auth_url" \
        --arg token_url "$token_url" \
        --arg jwks_url "$jwks_url" \
        '(.alias == $alias) and (.providerId == "oidc") and (.enabled == true)
         and (.storeToken == true) and (.config.clientId == $client_id)
         and (.config.authorizationUrl == $auth_url)
         and (.config.tokenUrl == $token_url)
         and (.config.jwksUrl == $jwks_url)' "$RESPONSE_FILE" >/dev/null \
        || die "Keycloak identity provider '$IDP_ALIAS' has conflicting configuration."
      printf 'Verified Keycloak identity provider %s.\n' "$IDP_ALIAS"
      return
    fi
    http_request PUT "$base/identity-provider/instances/$IDP_ALIAS" \
      "$KC_TOKEN" application/json "$body"
    expect_http "Update Keycloak identity provider '$IDP_ALIAS'" 200 204
    printf 'Updated Keycloak identity provider %s from the Viya discovery document.\n' "$IDP_ALIAS"
    return
  fi
  [[ "$HTTP_STATUS" == 404 ]] \
    || die "Keycloak identity provider lookup returned HTTP $HTTP_STATUS: $(sanitized_error)"
  [[ "$CHECK_ONLY" == false ]] \
    || die "Keycloak identity provider '$IDP_ALIAS' does not exist."

  http_request POST "$base/identity-provider/instances" "$KC_TOKEN" application/json "$body"
  expect_http "Create Keycloak identity provider '$IDP_ALIAS'" 201 204
  printf 'Created Keycloak identity provider %s.\n' "$IDP_ALIAS"
}

ensure_keycloak_mapper() {
  local name=$1 mapper_type=$2 config=$3 base mappers mapper_id body
  base=$(keycloak_realm_url)
  http_request GET "$base/identity-provider/instances/$IDP_ALIAS/mappers" "$KC_TOKEN" '' ''
  expect_http 'Read Keycloak identity provider mappers' 200
  mappers=$(<"$RESPONSE_FILE")
  mapper_id=$(jq --raw-output --arg name "$name" \
    '.[] | select(.name == $name) | .id' <<<"$mappers")
  body=$(jq --null-input \
    --arg alias "$IDP_ALIAS" \
    --arg name "$name" \
    --arg mapper_type "$mapper_type" \
    --argjson config "$config" \
    '{identityProviderAlias: $alias, identityProviderMapper: $mapper_type,
      name: $name, config: $config}')

  if [[ -n "$mapper_id" ]]; then
    if jq --exit-status \
      --arg name "$name" --arg mapper_type "$mapper_type" --argjson config "$config" \
      '.[] | select(.name == $name)
       | (.identityProviderMapper == $mapper_type) and (.config == $config)' \
      <<<"$mappers" >/dev/null; then
      printf 'Verified Keycloak mapper %s.\n' "$name"
      return
    fi
    [[ "$CHECK_ONLY" == false ]] \
      || die "Keycloak mapper '$name' has conflicting configuration."
    body=$(jq --arg id "$mapper_id" '. + {id: $id}' <<<"$body")
    http_request PUT "$base/identity-provider/instances/$IDP_ALIAS/mappers/$mapper_id" \
      "$KC_TOKEN" application/json "$body"
    expect_http "Update Keycloak mapper '$name'" 200 204
    printf 'Updated Keycloak mapper %s.\n' "$name"
    return
  fi
  [[ "$CHECK_ONLY" == false ]] || die "Keycloak mapper '$name' does not exist."

  http_request POST "$base/identity-provider/instances/$IDP_ALIAS/mappers" \
    "$KC_TOKEN" application/json "$body"
  expect_http "Create Keycloak mapper '$name'" 201 204
  printf 'Created Keycloak mapper %s.\n' "$name"
}

ensure_keycloak_group_exists() {
  local group_name=$1 base groups group_path
  base=$(keycloak_realm_url)
  http_request GET "$base/groups" "$KC_TOKEN" '' '' \
    --get --data-urlencode "search=$group_name"
  expect_http "Find Keycloak group '$group_name'" 200
  groups=$(<"$RESPONSE_FILE")
  group_path="/$group_name"
  jq --exit-status --arg path "$group_path" \
    'any(.[]; .path == $path)' <<<"$groups" >/dev/null \
    || die "Keycloak group '$group_path' must exist before RAM group-mapper setup."
}

remove_legacy_group_mappers() {
  local base mappers name mapper_id
  base=$(keycloak_realm_url)
  http_request GET "$base/identity-provider/instances/$IDP_ALIAS/mappers" "$KC_TOKEN" '' ''
  expect_http 'Read Keycloak identity provider mappers' 200
  mappers=$(<"$RESPONSE_FILE")
  for name in ram-admin-group-mapper ram-user-group-mapper; do
    mapper_id=$(jq --raw-output --arg name "$name" \
      '.[] | select(.name == $name) | .id' <<<"$mappers")
    [[ -z "$mapper_id" ]] && continue
    [[ "$CHECK_ONLY" == false ]] \
      || die "Obsolete Keycloak mapper '$name' must be removed."
    http_request DELETE "$base/identity-provider/instances/$IDP_ALIAS/mappers/$mapper_id" \
      "$KC_TOKEN" '' ''
    expect_http "Remove obsolete Keycloak mapper '$name'" 204
    printf 'Removed obsolete Keycloak mapper %s.\n' "$name"
  done
}

ensure_keycloak_mappers() {
  local base mapper_types admin_config user_config email_config
  base=$(keycloak_realm_url)
  http_request GET "$base/identity-provider/instances/$IDP_ALIAS/mapper-types" \
    "$KC_TOKEN" '' ''
  expect_http 'Read Keycloak mapper types' 200
  mapper_types=$(<"$RESPONSE_FILE")
  jq --exit-status \
    'has("oidc-hardcoded-group-idp-mapper") and has("hardcoded-attribute-idp-mapper")' \
    <<<"$mapper_types" >/dev/null \
    || die "Keycloak does not provide the required hardcoded group and email mappers."

  ensure_keycloak_group_exists "$RAM_KC_ADMIN_GROUP"
  ensure_keycloak_group_exists "$RAM_KC_USER_GROUP"
  remove_legacy_group_mappers

  admin_config=$(jq --null-input --arg group "/$RAM_KC_ADMIN_GROUP" \
    '{syncMode: "INHERIT", group: $group}')
  ensure_keycloak_mapper ram-admin-mapper \
    oidc-hardcoded-group-idp-mapper "$admin_config"

  user_config=$(jq --null-input --arg group "/$RAM_KC_USER_GROUP" \
    '{syncMode: "INHERIT", group: $group}')
  ensure_keycloak_mapper ram-user-mapper \
    oidc-hardcoded-group-idp-mapper "$user_config"

  email_config=$(jq --null-input \
    '{syncMode: "INHERIT", attribute: "emailVerified", "attribute.value": "true"}')
  ensure_keycloak_mapper hardcode-email-verified \
    hardcoded-attribute-idp-mapper "$email_config"
}

remove_email_verified_scope_mapper() {
  local base scopes scope_id mappers mapper_id
  base=$(keycloak_realm_url)
  http_request GET "$base/client-scopes" "$KC_TOKEN" '' ''
  expect_http 'Read Keycloak client scopes' 200
  scopes=$(<"$RESPONSE_FILE")
  scope_id=$(jq --raw-output '.[] | select(.name == "email") | .id' <<<"$scopes")
  [[ -n "$scope_id" ]] || die "Keycloak client scope 'email' was not found."

  http_request GET "$base/client-scopes/$scope_id/protocol-mappers/models" "$KC_TOKEN" '' ''
  expect_http "Read the Keycloak 'email' client scope" 200
  mappers=$(<"$RESPONSE_FILE")
  mapper_id=$(jq --raw-output '.[] | select(.name == "email verified") | .id' <<<"$mappers")
  if [[ -z "$mapper_id" ]]; then
    printf "Verified that the 'email verified' client-scope mapper is absent.\n"
    return
  fi
  [[ "$CHECK_ONLY" == false ]] \
    || die "The 'email verified' client-scope mapper must be removed."

  http_request DELETE "$base/client-scopes/$scope_id/protocol-mappers/models/$mapper_id" \
    "$KC_TOKEN" '' ''
  expect_http "Remove the 'email verified' client-scope mapper" 204
  printf "Removed the 'email verified' client-scope mapper.\n"
}

configure_broker_client() {
  local base clients client_uuid client updated
  base=$(keycloak_realm_url)
  http_request GET "$base/clients" "$KC_TOKEN" '' '' \
    --get --data-urlencode "clientId=$RAM_KC_CLIENT_ID"
  expect_http "Find Keycloak client '$RAM_KC_CLIENT_ID'" 200
  clients=$(<"$RESPONSE_FILE")
  client_uuid=$(jq --raw-output '.[0].id // empty' <<<"$clients")
  [[ -n "$client_uuid" ]] \
    || die "Keycloak client '$RAM_KC_CLIENT_ID' was not found."

  http_request GET "$base/clients/$client_uuid" "$KC_TOKEN" '' ''
  expect_http "Read Keycloak client '$RAM_KC_CLIENT_ID'" 200
  client=$(<"$RESPONSE_FILE")
  if jq --exit-status --arg alias "$IDP_ALIAS" \
    '(.attributes["external.token.enabled"] == "true")
     and (.attributes["external.token.idp"] == $alias)' <<<"$client" >/dev/null; then
    printf 'Verified external-token settings on Keycloak client %s.\n' "$RAM_KC_CLIENT_ID"
  else
    [[ "$CHECK_ONLY" == false ]] \
      || die "Keycloak client '$RAM_KC_CLIENT_ID' is not enabled for external tokens."
    updated=$(jq --arg alias "$IDP_ALIAS" \
      '.attributes["external.token.enabled"] = "true"
       | .attributes["external.token.idp"] = $alias' <<<"$client")
    http_request PUT "$base/clients/$client_uuid" "$KC_TOKEN" application/json "$updated"
    expect_http "Configure Keycloak client '$RAM_KC_CLIENT_ID'" 204
    printf 'Enabled external tokens on Keycloak client %s.\n' "$RAM_KC_CLIENT_ID"
  fi

  RAM_KC_CLIENT_UUID=$client_uuid
}

ensure_token_exchange() {
  local base realm_management_uuid permission_id policy_name policies policy_id
  local permissions_body policy_body permission_body
  base=$(keycloak_realm_url)

  http_request GET "$base/clients" "$KC_TOKEN" '' '' \
    --get --data-urlencode 'clientId=realm-management'
  expect_http "Find Keycloak client 'realm-management'" 200
  realm_management_uuid=$(response_value '.[0].id') \
    || die "Keycloak client 'realm-management' was not found."

  if [[ "$CHECK_ONLY" == true ]]; then
    http_request GET "$base/identity-provider/instances/$IDP_ALIAS/management/permissions" \
      "$KC_TOKEN" '' ''
    expect_http 'Read identity-provider management permissions' 200
    permission_id=$(jq --raw-output \
      'select(.enabled == true) | .scopePermissions["token-exchange"] // empty' \
      "$RESPONSE_FILE")
    [[ -n "$permission_id" ]] \
      || die "Identity-provider token-exchange permissions are not enabled."
  else
    permissions_body=$(jq --null-input '{enabled: true}')
    http_request PUT "$base/identity-provider/instances/$IDP_ALIAS/management/permissions" \
      "$KC_TOKEN" application/json "$permissions_body"
    expect_http 'Enable identity-provider management permissions' 200
    permission_id=$(response_value '.scopePermissions["token-exchange"]') \
      || die "Keycloak did not return a token-exchange permission. Enable admin-fine-grained-authz:v1 and token-exchange."
  fi

  policy_name="$RAM_KC_CLIENT_ID-token-exchange-policy"
  http_request GET \
    "$base/clients/$realm_management_uuid/authz/resource-server/policy" \
    "$KC_TOKEN" '' '' --get \
    --data-urlencode "name=$policy_name" --data-urlencode 'exactName=true'
  expect_http "Find token-exchange policy '$policy_name'" 200
  policies=$(<"$RESPONSE_FILE")
  policy_id=$(jq --raw-output '.[0].id // empty' <<<"$policies")
  policy_body=$(jq --null-input \
    --arg name "$policy_name" --arg client_id "$RAM_KC_CLIENT_UUID" \
    '{name: $name, logic: "POSITIVE", clients: [$client_id]}')

  if [[ -n "$policy_id" ]]; then
    if jq --exit-status --arg client_id "$RAM_KC_CLIENT_UUID" \
      '.[0] | (.logic == "POSITIVE") and (.clients == [$client_id])' \
      <<<"$policies" >/dev/null; then
      printf 'Verified Keycloak token-exchange policy %s.\n' "$policy_name"
    else
      [[ "$CHECK_ONLY" == false ]] \
        || die "Keycloak token-exchange policy '$policy_name' has conflicting configuration."
      policy_body=$(jq --arg id "$policy_id" '. + {id: $id}' <<<"$policy_body")
      http_request PUT \
        "$base/clients/$realm_management_uuid/authz/resource-server/policy/client/$policy_id" \
        "$KC_TOKEN" application/json "$policy_body"
      expect_http "Update token-exchange policy '$policy_name'" 200 204
      printf 'Updated Keycloak token-exchange policy %s.\n' "$policy_name"
    fi
  else
    [[ "$CHECK_ONLY" == false ]] \
      || die "Keycloak token-exchange policy '$policy_name' does not exist."
    http_request POST \
      "$base/clients/$realm_management_uuid/authz/resource-server/policy/client" \
      "$KC_TOKEN" application/json "$policy_body"
    expect_http "Create token-exchange policy '$policy_name'" 201
    policy_id=$(response_value '.id') \
      || die "Keycloak did not return the new token-exchange policy ID."
  fi

  http_request GET \
    "$base/clients/$realm_management_uuid/authz/resource-server/permission/$permission_id" \
    "$KC_TOKEN" '' ''
  expect_http 'Read the token-exchange permission' 200
  permission_body=$(<"$RESPONSE_FILE")
  if jq --exit-status --arg policy_id "$policy_id" \
    '(.policies == [$policy_id]) and (.decisionStrategy == "UNANIMOUS")' \
    <<<"$permission_body" >/dev/null; then
    printf 'Verified the Keycloak token-exchange policy.\n'
    return
  fi
  [[ "$CHECK_ONLY" == false ]] \
    || die "The Keycloak token-exchange permission has conflicting configuration."

  permission_body=$(jq --arg policy_id "$policy_id" \
    '.policies = [$policy_id] | .decisionStrategy = "UNANIMOUS"' \
    <<<"$permission_body")
  http_request PUT \
    "$base/clients/$realm_management_uuid/authz/resource-server/permission/scope/$permission_id" \
    "$KC_TOKEN" application/json "$permission_body"
  expect_http 'Configure the token-exchange permission' 204
  printf 'Configured the Keycloak token-exchange policy.\n'
}

configure_oauth_proxy_redirect() {
  local config_map="${RAM_RELEASE}-oauth2-proxy"
  local api_deployment="${RAM_RELEASE}-api"
  local app_deployment="${RAM_RELEASE}-app"
  local config_file="$TEMPORARY_DIRECTORY/oauth2-proxy.cfg"
  local original_file="$TEMPORARY_DIRECTORY/oauth2-proxy.original.cfg"

  kubectl_cmd get configmap "$config_map" --namespace "$RAM_NAMESPACE" \
    --output 'jsonpath={.data.oauth2-proxy\.cfg}' >"$config_file" \
    || die "Could not read ConfigMap '$RAM_NAMESPACE/$config_map'."
  [[ -s "$config_file" ]] || die "ConfigMap '$RAM_NAMESPACE/$config_map' has no oauth2-proxy.cfg."
  cp "$config_file" "$original_file"

  IDP_ALIAS="$IDP_ALIAS" CONFIG_FILE="$config_file" python3 <<'PY'
import os
import re
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

path = Path(os.environ["CONFIG_FILE"])
alias = os.environ["IDP_ALIAS"]
config = path.read_text()
pattern = re.compile(r'(?m)^(\s*login_url\s*=\s*")([^"]+)("\s*)$')
matches = list(pattern.finditer(config))
if len(matches) != 1:
    raise SystemExit(f"Expected exactly one login_url setting; found {len(matches)}.")
match = matches[0]
parts = urlsplit(match.group(2))
if not parts.path.endswith("/protocol/openid-connect/auth"):
    raise SystemExit("The login_url does not target a Keycloak authorization endpoint.")
query = [(key, value) for key, value in parse_qsl(parts.query, keep_blank_values=True)
         if key != "kc_idp_hint"]
query.append(("kc_idp_hint", alias))
url = urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(query), parts.fragment))
path.write_text(config[:match.start()] + match.group(1) + url + match.group(3) + config[match.end():])
PY

  if cmp --silent "$original_file" "$config_file"; then
    printf 'Verified the RAM OAuth proxy login redirect.\n'
  else
    [[ "$CHECK_ONLY" == false ]] \
      || die "The RAM OAuth proxy login redirect is not configured for '$IDP_ALIAS'."
    kubectl_cmd create configmap "$config_map" --namespace "$RAM_NAMESPACE" \
      --from-file="oauth2-proxy.cfg=$config_file" \
      --dry-run=client --output yaml \
      | kubectl_cmd apply --namespace "$RAM_NAMESPACE" --filename - >/dev/null
    kubectl_cmd rollout restart "deployment/$api_deployment" "deployment/$app_deployment" \
      --namespace "$RAM_NAMESPACE" >/dev/null
    kubectl_cmd rollout status "deployment/$api_deployment" \
      --namespace "$RAM_NAMESPACE" --timeout=90s
    kubectl_cmd rollout status "deployment/$app_deployment" \
      --namespace "$RAM_NAMESPACE" --timeout=90s
    printf 'Configured the RAM OAuth proxy login redirect.\n'
  fi

  http_request GET "$RAM_URL/SASRetrievalAgentManager/oauth2/start" '' '' ''
  [[ "$HTTP_STATUS" == 3* ]] \
    || die "RAM OAuth start returned HTTP $HTTP_STATUS instead of a redirect."
  python3 - "$HEADER_FILE" "$IDP_ALIAS" <<'PY'
import sys
from urllib.parse import parse_qs, urlsplit

locations = []
for line in open(sys.argv[1], encoding="utf-8", errors="replace"):
    if line.lower().startswith("location:"):
        locations.append(line.split(":", 1)[1].strip())
if len(locations) != 1:
    raise SystemExit(f"Expected exactly one Location header; found {len(locations)}.")
if parse_qs(urlsplit(locations[0]).query).get("kc_idp_hint") != [sys.argv[2]]:
    raise SystemExit("RAM OAuth redirect does not contain the expected identity provider.")
PY
}

run_sso_setup() {
  printf 'Authenticating with SAS Viya and RAM Keycloak.\n'
  get_viya_token
  get_keycloak_admin_token
  prepare_sso_client_secret
  ensure_viya_sso_client
  ensure_keycloak_identity_provider
  ensure_keycloak_mappers
  remove_email_verified_scope_mapper
  configure_broker_client
  ensure_token_exchange
  configure_oauth_proxy_redirect
  printf 'RAM SSO with SAS Viya is configured.\n'
}
