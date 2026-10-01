#!/usr/bin/env bash

set -e -o pipefail

function check_env() {
  for var in VIYA_URL VIYA_USER VIYA_PASSWORD RAM_URL RAM_KC_PASSWORD; do
    [ -n "${!var}" ] || {
      echo >&2 "Required environment variable unset: ${var}"
      exit 1
    }
  done

  VIYA_CLIENT_ID="${VIYA_CLIENT_ID:-ram-client}"
  VIYA_CLIENT_SECRET="${VIYA_CLIENT_SECRET:-ram-secret}"
  RAM_KC_CLIENT_ID="${RAM_KC_CLIENT_ID:-sas-ram-app}"
  RAM_KC_USER="${RAM_KC_USER:-kcAdmin}"
  RAM_KC_REALM="${RAM_KC_REALM:-sas-iot}"
  IDP_ALIAS="${IDP_ALIAS:-viya-oidc}"
  RAM_KC_ADMIN_GROUP="${RAM_KC_ADMIN_GROUP:-Admin}"
  RAM_KC_USER_GROUP="${RAM_KC_USER_GROUP:-User}"

  export VIYA_CLIENT_ID VIYA_CLIENT_SECRET RAM_KC_CLIENT_ID RAM_KC_USER RAM_KC_REALM IDP_ALIAS RAM_KC_ADMIN_GROUP RAM_KC_USER_GROUP
}

function get_viya_token() {
  local resp
  resp=$(curl -sk -X POST "${VIYA_URL}/SASLogon/oauth/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -u "sas.cli:" \
    --data-urlencode "grant_type=password" \
    --data-urlencode "username=${VIYA_USER}" \
    --data-urlencode "password=${VIYA_PASSWORD}")

  local token
  token=$(echo "${resp}" | jq -r '.access_token // empty')
  if [ -z "${token}" ]; then
    echo >&2 "Failed to obtain Viya access token"
    echo >&2 "${resp}"
    exit 1
  fi
  echo "${token}"
}

function get_kc_admin_token() {
  local resp
  resp=$(curl -sk -X POST "${RAM_URL}/SASRetrievalAgentManager/auth/realms/master/protocol/openid-connect/token" \
    --data-urlencode "grant_type=password" \
    --data-urlencode "client_id=admin-cli" \
    --data-urlencode "username=${RAM_KC_USER}" \
    --data-urlencode "password=${RAM_KC_PASSWORD}")

  local token
  token=$(echo "${resp}" | jq -r '.access_token // empty')
  if [ -z "${token}" ]; then
    echo >&2 "Failed to obtain Keycloak admin token"
    echo >&2 "${resp}"
    exit 1
  fi
  echo "${token}"
}

function create_viya_groups() {
  local viya_token="${1}"
  local headers=(-H "Authorization: Bearer ${viya_token}" -H "Content-Type: application/json")

  for group_id in "ram-admin-group" "ram-user-group"; do
    local status
    status=$(curl -sk -o /dev/null -w "%{http_code}" "${VIYA_URL}/identities/groups/${group_id}" \
      -H "Authorization: Bearer ${viya_token}")

    if [ "${status}" == "200" ]; then
      echo "  Group '${group_id}' already exists - skipping."
    else
      local body
      body=$(printf '{"id":"%s","name":"%s","type":"group"}' "${group_id}" "${group_id}")
      local resp
      resp=$(curl -sk -X POST "${VIYA_URL}/identities/groups" \
        "${headers[@]}" \
        --data "${body}")
      if echo "${resp}" | jq -e '.error' &>/dev/null; then
        echo >&2 "Failed to create group '${group_id}': $(echo "${resp}" | jq -r '.message // .error')"
        exit 1
      fi
      echo "  Group '${group_id}' created."
    fi
  done
}

function create_viya_oauth_client() {
  local viya_token="${1}"
  local headers=(-H "Authorization: Bearer ${viya_token}" -H "Content-Type: application/json")

  local redirect_uri="${RAM_URL}/SASRetrievalAgentManager/auth/realms/${RAM_KC_REALM}/broker/${IDP_ALIAS}/endpoint"
  local body
  body=$(jq -n \
    --arg cid "${VIYA_CLIENT_ID}" \
    --arg cs "${VIYA_CLIENT_SECRET}" \
    --arg uri "${redirect_uri}" \
    '{
      client_id: $cid,
      client_secret: $cs,
      authorities: ["ram-admin-group", "ram-user-group"],
      authorized_grant_types: ["authorization_code", "refresh_token"],
      name: "RAM Keycloak",
      scope: ["openid", "uaa.user", "profile", "email"],
      redirect_uri: [$uri],
      autoapprove: true
    }')

  local status
  status=$(curl -sk --head "${VIYA_URL}/SASLogon/oauth/clients/${VIYA_CLIENT_ID}" \
    -H "Authorization: Bearer ${viya_token}" \
    -w "%{http_code}" -o /dev/null)

  local resp
  if [ "${status}" == "200" ]; then
    echo "  Client '${VIYA_CLIENT_ID}' already exists - updating."
    resp=$(curl -sk -X PUT "${VIYA_URL}/SASLogon/oauth/clients/${VIYA_CLIENT_ID}" \
      "${headers[@]}" --data "${body}")
    curl -sk -X PUT "${VIYA_URL}/SASLogon/oauth/clients/${VIYA_CLIENT_ID}/secret" \
      "${headers[@]}" \
      --data "{\"clientId\":\"${VIYA_CLIENT_ID}\",\"secret\":\"${VIYA_CLIENT_SECRET}\"}" &>/dev/null
  else
    resp=$(curl -sk -X POST "${VIYA_URL}/SASLogon/oauth/clients" \
      "${headers[@]}" --data "${body}")
  fi

  if echo "${resp}" | jq -e '.error' &>/dev/null; then
    echo >&2 "Failed to create/update OAuth client '${VIYA_CLIENT_ID}'"
    echo >&2 "$(echo "${resp}" | jq -r '.error'): $(echo "${resp}" | jq -r '.error_description // empty')"
    exit 1
  fi
  echo "  Client '${VIYA_CLIENT_ID}' registered."
}


function create_keycloak_idp() {
  local kc_token="${1}"
  local base="${RAM_URL}/SASRetrievalAgentManager/auth/admin/realms/${RAM_KC_REALM}"
  local headers=(-H "Authorization: Bearer ${kc_token}" -H "Content-Type: application/json")

  echo "  Fetching Viya OIDC discovery document..."
  local oidc_config
  oidc_config=$(curl -sk "${VIYA_URL}/SASLogon/.well-known/openid-configuration")
  local auth_url token_url userinfo_url jwks_uri issuer logout_url
  auth_url=$(echo "${oidc_config}" | jq -r '.authorization_endpoint')
  token_url=$(echo "${oidc_config}" | jq -r '.token_endpoint')
  userinfo_url=$(echo "${oidc_config}" | jq -r '.userinfo_endpoint')
  jwks_uri=$(echo "${oidc_config}" | jq -r '.jwks_uri')
  issuer=$(echo "${oidc_config}" | jq -r '.issuer')
  logout_url=$(echo "${oidc_config}" | jq -r '.end_session_endpoint // empty')

  local body
  body=$(jq -n \
    --arg alias "${IDP_ALIAS}" \
    --arg cid "${VIYA_CLIENT_ID}" \
    --arg cs "${VIYA_CLIENT_SECRET}" \
    --arg auth_url "${auth_url}" \
    --arg token_url "${token_url}" \
    --arg userinfo_url "${userinfo_url}" \
    --arg jwks_uri "${jwks_uri}" \
    --arg issuer "${issuer}" \
    --arg logout_url "${logout_url}" \
    '{
      alias: $alias,
      displayName: "SAS Viya",
      providerId: "oidc",
      enabled: true,
      trustEmail: true,
      storeToken: true,
      config: {
        clientId: $cid,
        clientSecret: $cs,
        authorizationUrl: $auth_url,
        tokenUrl: $token_url,
        userInfoUrl: $userinfo_url,
        jwksUrl: $jwks_uri,
        issuer: $issuer,
        logoutUrl: $logout_url,
        defaultScope: "openid profile email",
        validateSignature: "true",
        useJwksUrl: "true",
        isAccessTokenJWT: "true"
      }
    }')

  local status
  status=$(curl -sk --head "${base}/identity-provider/instances/${IDP_ALIAS}" \
    -H "Authorization: Bearer ${kc_token}" \
    -w "%{http_code}" -o /dev/null)

  if [ "${status}" == "200" ]; then
    echo "  IDP '${IDP_ALIAS}' already exists - updating."
    curl -sk -X PUT "${base}/identity-provider/instances/${IDP_ALIAS}" \
      "${headers[@]}" --data "${body}" &>/dev/null
  else
    curl -sk -X POST "${base}/identity-provider/instances" \
      "${headers[@]}" --data "${body}" &>/dev/null
    echo "  IDP '${IDP_ALIAS}' created."
  fi
}


function create_idp_mappers() {
  local kc_token="${1}"
  local base="${RAM_URL}/SASRetrievalAgentManager/auth/admin/realms/${RAM_KC_REALM}"
  local headers=(-H "Authorization: Bearer ${kc_token}" -H "Content-Type: application/json")

  # Verify the mapper type is available in this Keycloak instance
  local mapper_type="oidc-advanced-group-idp-mapper"
  local mapper_types
  mapper_types=$(curl -sk \
    "${base}/identity-provider/instances/${IDP_ALIAS}/mapper-types" \
    "${headers[@]}")
  if ! echo "${mapper_types}" | jq -e --arg t "${mapper_type}" 'has($t)' &>/dev/null; then
    echo >&2 "  Mapper type '${mapper_type}' is not available in this Keycloak instance."
    echo >&2 "  Available types: $(echo "${mapper_types}" | jq -r 'keys[]')"
    exit 1
  fi

  local existing_mappers
  existing_mappers=$(curl -sk \
    "${base}/identity-provider/instances/${IDP_ALIAS}/mappers" \
    "${headers[@]}")

  local names=("ram-admin-group-mapper" "ram-user-group-mapper")
  local claim_values=("ram-admin-group" "ram-user-group")
  local groups=("${RAM_KC_ADMIN_GROUP}" "${RAM_KC_USER_GROUP}")

  local i
  for i in 0 1; do
    local mapper_name="${names[$i]}"
    local claim_value="${claim_values[$i]}"
    local group="${groups[$i]}"

    local exists
    exists=$(echo "${existing_mappers}" | jq -r --arg n "${mapper_name}" \
      '.[] | select(.name == $n) | .id')

    local body
    # claims is a serialized JSON array as required by oidc-advanced-group-idp-mapper
    local claims
    claims=$(jq -cn --arg val "${claim_value}" '[{"key":"authorities","value":$val}]')
    # Keycloak requires group paths to be absolute (leading /)
    [[ "${group}" == /* ]] || group="/${group}"
    body=$(jq -n \
      --arg alias "${IDP_ALIAS}" \
      --arg name "${mapper_name}" \
      --arg claims "${claims}" \
      --arg group "${group}" \
      '{
        identityProviderAlias: $alias,
        identityProviderMapper: "oidc-advanced-group-idp-mapper",
        name: $name,
        config: {
          syncMode: "INHERIT",
          claims: $claims,
          group: $group
        }
      }')

    local resp
    if [ -n "${exists}" ]; then
      echo "  Mapper '${mapper_name}' already exists - updating."
      resp=$(curl -sk -X PUT \
        "${base}/identity-provider/instances/${IDP_ALIAS}/mappers/${exists}" \
        "${headers[@]}" --data "$(echo "${body}" | jq --arg id "${exists}" '. + {id: $id}')")
    else
      echo "  Creating mapper '${mapper_name}'..."
      resp=$(curl -sk -X POST \
        "${base}/identity-provider/instances/${IDP_ALIAS}/mappers" \
        "${headers[@]}" --data "${body}")
    fi

    if echo "${resp}" | jq -e '.error // .errorMessage' &>/dev/null; then
      echo >&2 "  Failed to create/update mapper '${mapper_name}':"
      echo >&2 "  $(echo "${resp}" | jq -r '.error // .errorMessage')"
      exit 1
    fi
  done
}


function delete_email_verified_scope_mapper() {
  local kc_token="${1}"
  local base="${RAM_URL}/SASRetrievalAgentManager/auth/admin/realms/${RAM_KC_REALM}"
  local headers=(-H "Authorization: Bearer ${kc_token}" -H "Content-Type: application/json")

  local scopes
  scopes=$(curl -sk "${base}/client-scopes" "${headers[@]}")
  local scope_id
  scope_id=$(echo "${scopes}" | jq -r '.[] | select(.name == "email") | .id')

  if [ -z "${scope_id}" ]; then
    echo "  Client scope 'email' not found - skipping."
    return
  fi

  local mappers
  mappers=$(curl -sk "${base}/client-scopes/${scope_id}/protocol-mappers/models" "${headers[@]}")
  local mapper_id
  mapper_id=$(echo "${mappers}" | jq -r '.[] | select(.name == "email verified") | .id')

  if [ -z "${mapper_id}" ]; then
    echo "  Mapper 'email verified' not found in 'email' client scope - skipping."
    return
  fi

  curl -sk -X DELETE \
    "${base}/client-scopes/${scope_id}/protocol-mappers/models/${mapper_id}" \
    -H "Authorization: Bearer ${kc_token}" &>/dev/null
  echo "  Deleted 'email verified' mapper from 'email' client scope."
}


function configure_kc_client_for_brokering() {
  local kc_token="${1}"
  local base="${RAM_URL}/SASRetrievalAgentManager/auth/admin/realms/${RAM_KC_REALM}"
  local headers=(-H "Authorization: Bearer ${kc_token}" -H "Content-Type: application/json")

  local clients
  clients=$(curl -sk "${base}/clients?clientId=${RAM_KC_CLIENT_ID}" "${headers[@]}")
  local client_uuid
  client_uuid=$(echo "${clients}" | jq -r '.[0].id // empty')
  if [ -z "${client_uuid}" ]; then
    echo >&2 "  Client '${RAM_KC_CLIENT_ID}' not found in realm '${RAM_KC_REALM}'"
    exit 1
  fi

  local client
  client=$(curl -sk "${base}/clients/${client_uuid}" "${headers[@]}")

  local updated
  updated=$(echo "${client}" | jq \
    --arg idp "${IDP_ALIAS}" \
    '.attributes["external.token.enabled"] = "true"
     | .attributes["external.token.idp"] = $idp')

  local http_status
  http_status=$(curl -sk -o /dev/null -w "%{http_code}" -X PUT \
    "${base}/clients/${client_uuid}" \
    "${headers[@]}" --data "${updated}")

  if [ "${http_status}" != "204" ]; then
    echo >&2 "  Failed to update client '${RAM_KC_CLIENT_ID}' (HTTP ${http_status})"
    exit 1
  fi
  echo "  Client '${RAM_KC_CLIENT_ID}' configured for Identity Brokering API v2."
}


function create_hardcoded_email_verified_mapper() {
  local kc_token="${1}"
  local base="${RAM_URL}/SASRetrievalAgentManager/auth/admin/realms/${RAM_KC_REALM}"
  local headers=(-H "Authorization: Bearer ${kc_token}" -H "Content-Type: application/json")

  local mapper_name="hardcode-email-verified"

  local existing_mappers
  existing_mappers=$(curl -sk \
    "${base}/identity-provider/instances/${IDP_ALIAS}/mappers" \
    "${headers[@]}")
  local exists
  exists=$(echo "${existing_mappers}" | jq -r --arg n "${mapper_name}" \
    '.[] | select(.name == $n) | .id')

  local body
  body=$(jq -n \
    --arg alias "${IDP_ALIAS}" \
    --arg name "${mapper_name}" \
    '{
      identityProviderAlias: $alias,
      identityProviderMapper: "hardcoded-attribute-idp-mapper",
      name: $name,
      config: {
        syncMode: "INHERIT",
        "attribute": "emailVerified",
        "attribute.value": "true"
      }
    }')

  local resp
  if [ -n "${exists}" ]; then
    echo "  Mapper '${mapper_name}' already exists - updating."
    resp=$(curl -sk -X PUT \
      "${base}/identity-provider/instances/${IDP_ALIAS}/mappers/${exists}" \
      "${headers[@]}" --data "$(echo "${body}" | jq --arg id "${exists}" '. + {id: $id}')")
  else
    echo "  Creating mapper '${mapper_name}'..."
    resp=$(curl -sk -X POST \
      "${base}/identity-provider/instances/${IDP_ALIAS}/mappers" \
      "${headers[@]}" --data "${body}")
  fi

  if echo "${resp}" | jq -e '.error // .errorMessage' &>/dev/null; then
    echo >&2 "  Failed to create/update mapper '${mapper_name}':"
    echo >&2 "  $(echo "${resp}" | jq -r '.error // .errorMessage')"
    exit 1
  fi
}

check_env

echo "Authenticating with Viya..."
VIYA_TOKEN="$(get_viya_token)"

echo "Authenticating with Keycloak..."
KC_TOKEN="$(get_kc_admin_token)"

echo "Creating Viya groups..."
create_viya_groups "${VIYA_TOKEN}"

echo "Creating Viya OAuth client..."
create_viya_oauth_client "${VIYA_TOKEN}"

echo "Creating Keycloak IDP..."
create_keycloak_idp "${KC_TOKEN}"

echo "Creating IDP group mappers..."
create_idp_mappers "${KC_TOKEN}"

echo "Deleting 'email verified' mapper from email client scope..."
delete_email_verified_scope_mapper "${KC_TOKEN}"

echo "Adding hardcoded emailVerified IDP mapper..."
create_hardcoded_email_verified_mapper "${KC_TOKEN}"

echo "Configuring Keycloak client for Identity Brokering API v2..."
configure_kc_client_for_brokering "${KC_TOKEN}"

cat <<EOF

Done. Users can now authenticate via Viya at:

  ${RAM_URL}/SASRetrievalAgentManager/auth/realms/${RAM_KC_REALM}/account

EOF