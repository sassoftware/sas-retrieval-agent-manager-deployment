#!/usr/bin/env bash

mcp_json_request() {
  local method=$1
  local url=$2
  local bearer_token=$3
  local body=$4
  local request_file="$TEMPORARY_DIRECTORY/mcp-request.json"
  printf '%s' "$body" >"$request_file"
  http_request "$method" "$url" "$bearer_token" application/json '' \
    --data-binary "@$request_file"
  : >"$request_file"
}

prepare_mcp_client_secret() {
  VIYA_MCP_CLIENT_SECRET_FILE="$TEMPORARY_DIRECTORY/viya-mcp-client-secret"
  if kubectl_cmd get secret "$VIYA_MCP_SECRET_NAME" \
    --namespace "$RAM_NAMESPACE" >/dev/null 2>&1; then
    VIYA_MCP_CLIENT_SECRET=$(kubernetes_secret_value \
      "$RAM_NAMESPACE" "$VIYA_MCP_SECRET_NAME" 'client-secret')
    printf '%s' "$VIYA_MCP_CLIENT_SECRET" >"$VIYA_MCP_CLIENT_SECRET_FILE"
    chmod 600 "$VIYA_MCP_CLIENT_SECRET_FILE"
    unset VIYA_MCP_CLIENT_SECRET
    printf 'Found MCP OAuth client Secret %s/%s.\n' \
      "$RAM_NAMESPACE" "$VIYA_MCP_SECRET_NAME"
    return
  fi

  [[ "$CHECK_ONLY" == false ]] \
    || die "Required MCP OAuth client Secret '$RAM_NAMESPACE/$VIYA_MCP_SECRET_NAME' does not exist."

  VIYA_MCP_CLIENT_SECRET=$(random_secret)
  printf '%s' "$VIYA_MCP_CLIENT_SECRET" >"$VIYA_MCP_CLIENT_SECRET_FILE"
  chmod 600 "$VIYA_MCP_CLIENT_SECRET_FILE"
  unset VIYA_MCP_CLIENT_SECRET
  kubectl_cmd create secret generic "$VIYA_MCP_SECRET_NAME" \
    --namespace "$RAM_NAMESPACE" \
    --from-file="client-secret=$VIYA_MCP_CLIENT_SECRET_FILE" >/dev/null
  printf 'Created MCP OAuth client Secret %s/%s.\n' \
    "$RAM_NAMESPACE" "$VIYA_MCP_SECRET_NAME"
}

ensure_viya_mcp_group() {
  local encoded_group body
  encoded_group=$(jq --null-input --raw-output --arg value "$VIYA_MCP_CLIENT_ID" '$value | @uri')
  http_request GET "$VIYA_URL/identities/groups/$encoded_group" "$VIYA_TOKEN" '' ''
  if [[ "$HTTP_STATUS" == 200 ]]; then
    jq --exit-status --arg id "$VIYA_MCP_CLIENT_ID" \
      '(.id == $id) and (.type == "group")' "$RESPONSE_FILE" >/dev/null \
      || die "Viya group '$VIYA_MCP_CLIENT_ID' has conflicting configuration."
    printf 'Verified Viya group %s.\n' "$VIYA_MCP_CLIENT_ID"
    return
  fi
  [[ "$HTTP_STATUS" == 404 ]] \
    || die "Viya MCP group lookup returned HTTP $HTTP_STATUS: $(sanitized_error)"
  [[ "$CHECK_ONLY" == false ]] \
    || die "Viya group '$VIYA_MCP_CLIENT_ID' does not exist."

  body=$(jq --null-input --arg id "$VIYA_MCP_CLIENT_ID" \
    '{id: $id, name: ("RAM Application Group (" + $id + ")"), type: "group"}')
  mcp_json_request POST "$VIYA_URL/identities/groups" "$VIYA_TOKEN" "$body"
  expect_http "Create Viya group '$VIYA_MCP_CLIENT_ID'" 200 201
  printf 'Created Viya group %s.\n' "$VIYA_MCP_CLIENT_ID"
}

ensure_viya_mcp_client() {
  local encoded_client body
  encoded_client=$(jq --null-input --raw-output --arg value "$VIYA_MCP_CLIENT_ID" '$value | @uri')
  body=$(jq --null-input \
    --arg client_id "$VIYA_MCP_CLIENT_ID" \
    --rawfile client_secret "$VIYA_MCP_CLIENT_SECRET_FILE" \
    '{
      client_id: $client_id,
      client_secret: $client_secret,
      authorities: [$client_id],
      authorized_grant_types: ["client_credentials"],
      uid: "2001",
      gid: "2001"
    }')

  http_request GET "$VIYA_URL/SASLogon/oauth/clients/$encoded_client" "$VIYA_TOKEN" '' ''
  if [[ "$HTTP_STATUS" == 200 ]]; then
    jq --exit-status --arg client_id "$VIYA_MCP_CLIENT_ID" \
      '(.client_id == $client_id)
       and ((.authorities // []) == [$client_id])
       and ((.authorized_grant_types // []) == ["client_credentials"])
       and ((.uid | tostring) == "2001")
       and ((.gid | tostring) == "2001")' "$RESPONSE_FILE" >/dev/null \
      || die "Viya OAuth client '$VIYA_MCP_CLIENT_ID' has conflicting configuration."
    printf 'Verified Viya OAuth client %s.\n' "$VIYA_MCP_CLIENT_ID"
    return
  fi
  [[ "$HTTP_STATUS" == 404 ]] \
    || die "Viya MCP OAuth client lookup returned HTTP $HTTP_STATUS: $(sanitized_error)"
  [[ "$CHECK_ONLY" == false ]] \
    || die "Viya OAuth client '$VIYA_MCP_CLIENT_ID' does not exist."

  mcp_json_request POST "$VIYA_URL/SASLogon/oauth/clients" "$VIYA_TOKEN" "$body"
  expect_http "Create Viya OAuth client '$VIYA_MCP_CLIENT_ID'" 201
  printf 'Created Viya OAuth client %s.\n' "$VIYA_MCP_CLIENT_ID"
}

get_ram_api_token() {
  local appadmin_secret="${RAM_RELEASE}-keycloak-appadmin-secret"
  local client_secret="${RAM_RELEASE}-keycloak-client-secret"
  local appadmin_user appadmin_password client_id client_password realm

  appadmin_user=$(kubernetes_secret_value "$RAM_NAMESPACE" "$appadmin_secret" user)
  appadmin_password=$(kubernetes_secret_value "$RAM_NAMESPACE" "$appadmin_secret" password)
  client_id=$(kubernetes_secret_value "$RAM_NAMESPACE" "$client_secret" sv-client-id)
  client_password=$(kubernetes_secret_value "$RAM_NAMESPACE" "$client_secret" sv-client-secret)
  realm=$(kubernetes_secret_value "$RAM_NAMESPACE" "$client_secret" realm)

  http_request POST \
    "$RAM_URL/SASRetrievalAgentManager/auth/realms/$realm/protocol/openid-connect/token" \
    '' application/x-www-form-urlencoded '' \
    --user "$client_id:$client_password" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$appadmin_user" \
    --data-urlencode "password=$appadmin_password"
  expect_http 'RAM API authentication' 200
  RAM_API_TOKEN=$(response_value '.access_token') \
    || die "RAM API authentication did not return an access token."
  [[ -n "$RAM_API_TOKEN" ]] || die "RAM API authentication returned an empty access token."
  RAM_API_URL="$RAM_URL/SASRetrievalAgentManager/api/v1"
}

lookup_ram_template() {
  local name=$1
  http_request GET "$RAM_API_URL/toolServerTemplates" "$RAM_API_TOKEN" '' '' \
    --get --data-urlencode "filter=and(eq(name,$name),eq(type,container))" \
    --data-urlencode 'limit=1'
  expect_http "Find RAM template '$name'" 200
  TEMPLATE_ITEM=$(jq --compact-output '.items[0] // {}' "$RESPONSE_FILE")
}

publish_ram_template() {
  local name=$1 template_id=$2 version=$3 state=$4
  [[ "$state" == published ]] && return
  [[ "$CHECK_ONLY" == false ]] || die "RAM template '$name' is not published."
  http_request PUT \
    "$RAM_API_URL/toolServerTemplates/$template_id/$version/published" \
    "$RAM_API_TOKEN" '' ''
  expect_http "Publish RAM template '$name'" 200
  printf 'Published RAM template %s.\n' "$name"
}

ensure_ram_template() {
  local name=$1 desired=$2 match_filter=$3
  local id version state current
  lookup_ram_template "$name"
  id=$(jq --raw-output '.id // empty' <<<"$TEMPLATE_ITEM")
  version=$(jq --raw-output '.version // empty' <<<"$TEMPLATE_ITEM")

  if [[ -n "$id" && -n "$version" ]]; then
    http_request GET "$RAM_API_URL/toolServerTemplates/$id/$version" \
      "$RAM_API_TOKEN" '' ''
    expect_http "Read RAM template '$name'" 200
    current=$(<"$RESPONSE_FILE")
    jq --exit-status \
      --arg image "$MCP_IMAGE" \
      --arg token_url "$VIYA_URL/SASLogon/oauth/token" \
      --arg client_id "$VIYA_MCP_CLIENT_ID" \
      --rawfile client_secret "$VIYA_MCP_CLIENT_SECRET_FILE" \
      --arg idp_alias "$IDP_ALIAS" \
      "$match_filter" <<<"$current" >/dev/null \
      || die "RAM template '$name' has conflicting configuration."
    state=$(jq --raw-output '.published_state // empty' <<<"$current")
    printf 'Verified RAM template %s.\n' "$name"
  else
    [[ "$CHECK_ONLY" == false ]] || die "RAM template '$name' does not exist."
    id=$(new_uuid)
    desired=$(jq --arg id "$id" '.id = $id' <<<"$desired")
    mcp_json_request POST "$RAM_API_URL/toolServerTemplates" "$RAM_API_TOKEN" "$desired"
    expect_http "Create RAM template '$name'" 200
    id=$(response_value '.toolServerTemplateId') \
      || die "RAM did not return the new template ID."
    version=$(response_value '.version') \
      || die "RAM did not return the new template version."
    state=unpublished
    printf 'Created RAM template %s.\n' "$name"
  fi

  publish_ram_template "$name" "$id" "$version" "$state"
  TEMPLATE_ID=$id
  TEMPLATE_VERSION=$version
}

ensure_ram_tool_server() {
  local name=$1 desired=$2 template_id=$3 template_version=$4 match_filter=$5
  local item id current
  http_request GET "$RAM_API_URL/toolServers" "$RAM_API_TOKEN" '' '' \
    --get --data-urlencode "filter=and(eq(name,$name),eq(type,container))" \
    --data-urlencode 'limit=1'
  expect_http "Find RAM tools server '$name'" 200
  item=$(jq --compact-output '.items[0] // {}' "$RESPONSE_FILE")
  id=$(jq --raw-output '.id // empty' <<<"$item")

  if [[ -n "$id" ]]; then
    http_request GET "$RAM_API_URL/toolServers/$id" "$RAM_API_TOKEN" '' ''
    expect_http "Read RAM tools server '$name'" 200
    current=$(<"$RESPONSE_FILE")
    jq --exit-status \
      --arg template_id "$template_id" \
      --argjson template_version "$template_version" \
      --arg viya_url "$VIYA_URL" \
      --arg client_id "$VIYA_MCP_CLIENT_ID" \
      --rawfile client_secret "$VIYA_MCP_CLIENT_SECRET_FILE" \
      --arg idp_alias "$IDP_ALIAS" \
      "$match_filter" <<<"$current" >/dev/null \
      || die "RAM tools server '$name' has conflicting configuration."
    printf 'Verified RAM tools server %s.\n' "$name"
  else
    [[ "$CHECK_ONLY" == false ]] || die "RAM tools server '$name' does not exist."
    id=$(new_uuid)
    desired=$(jq --arg id "$id" '.id = $id' <<<"$desired")
    mcp_json_request POST "$RAM_API_URL/toolServers" "$RAM_API_TOKEN" "$desired"
    expect_http "Create RAM tools server '$name'" 200
    printf 'Created RAM tools server %s.\n' "$name"
  fi

  if [[ "$CHECK_ONLY" == false ]]; then
    http_request PUT "$RAM_API_URL/toolServers/$id/deployment" "$RAM_API_TOKEN" '' ''
    expect_http "Start RAM tools server '$name'" 200 202 204
    printf 'Started RAM tools server %s.\n' "$name"
  fi
}

ensure_oauth_mcp_server() {
  local template template_filter template_id template_version server server_filter
  template=$(jq --null-input \
    --arg image "$MCP_IMAGE" \
    --arg client_id "$VIYA_MCP_CLIENT_ID" \
    --rawfile client_secret "$VIYA_MCP_CLIENT_SECRET_FILE" \
    --arg token_url "$VIYA_URL/SASLogon/oauth/token" \
    '{
      id: "", name: "sas-mcp-tools",
      description: "SAS MCP Server container tools that use an OAuth token.",
      type: "container", published_state: "unpublished", version: 0,
      template_type: "tool_container",
      metadata: {image: $image, port: 8134, transport: "http", basepath: "/mcp",
        auth: "client_credentials", resources: {req_cpu: 0.5, req_mem: "512Mi"}},
      secrets: {args: "", auth_credentials: {client_id: $client_id,
        client_secret: $client_secret, token_url: $token_url, scope: null}, env_vars: [
        {name: "VIYA_ENDPOINT", description: "Viya deployment URL.", default: null, secret: false},
        {name: "ALLOW_RAW_BEARER", description: "Allow raw bearer tokens.", default: "true", secret: false}
      ]}, files: {files: []}
    }')
  template_filter='
    .metadata.image == $image and (.metadata.port | tostring) == "8134"
    and .metadata.transport == "http" and .metadata.basepath == "/mcp"
    and .metadata.auth == "client_credentials"
    and .secrets.auth_credentials.client_id == $client_id
    and .secrets.auth_credentials.client_secret == $client_secret
    and .secrets.auth_credentials.token_url == $token_url
  '
  ensure_ram_template sas-mcp-tools "$template" "$template_filter"
  template_id=$TEMPLATE_ID
  template_version=$TEMPLATE_VERSION

  server=$(jq --null-input \
    --arg template_id "$template_id" \
    --argjson template_version "$template_version" \
    --arg viya_url "$VIYA_URL" \
    --arg client_id "$VIYA_MCP_CLIENT_ID" \
    --rawfile client_secret "$VIYA_MCP_CLIENT_SECRET_FILE" \
    '{
      id: "", name: "sas-mcp-tools",
      description: "SAS MCP Server container tools that use an OAuth token.",
      template_id: $template_id, template_version: $template_version,
      type: "container", template_type: "tool_container",
      metadata: {auth: "client_credentials"},
      secrets: {auth_credentials: {client_id: $client_id,
        client_secret: $client_secret,
        token_url: ($viya_url + "/SASLogon/oauth/token"), scope: null}, env_vars: [
        {name: "VIYA_ENDPOINT", value: $viya_url, description: "Viya deployment URL.", secret: false},
        {name: "ALLOW_RAW_BEARER", value: "true", description: "Allow raw bearer tokens.", secret: false}
      ]}
    }')
  server_filter='
    .template_id == $template_id and .template_version == $template_version
    and .metadata.auth == "client_credentials"
    and .secrets.auth_credentials.client_id == $client_id
    and .secrets.auth_credentials.client_secret == $client_secret
    and .secrets.auth_credentials.token_url == ($viya_url + "/SASLogon/oauth/token")
    and any(.secrets.env_vars[]?; .name == "VIYA_ENDPOINT" and .value == $viya_url)
  '
  ensure_ram_tool_server sas-mcp-tools "$server" "$template_id" \
    "$template_version" "$server_filter"
}

ensure_user_token_mcp_server() {
  local template template_filter template_id template_version server server_filter
  template=$(jq --null-input --arg image "$MCP_IMAGE" --arg idp_alias "$IDP_ALIAS" '{
    id: "", name: "user-authenticated sas-mcp-tools",
    description: "SAS MCP Server container tools that use the authenticated user token.",
    type: "container", published_state: "unpublished", version: 0,
    template_type: "tool_container",
    metadata: {auth: "identity_broker", port: 8134, image: $image,
      basepath: "/mcp", transport: "http",
      resources: {req_cpu: 0.5, req_mem: "512Mi"}},
    secrets: {auth_credentials: {identity_broker_alias: $idp_alias},
      extra_auth_headers: {}, env_vars: [
        {name: "VIYA_ENDPOINT", description: "Viya deployment URL.", required: false, default: "", secret: false},
        {name: "ALLOW_RAW_BEARER", description: "Allow raw bearer tokens.", required: false, default: "true", secret: false}
      ], args: null, credentials: {username: null, password: null}},
    files: {files: [{path: "/tmp/config/tools.yaml", content: "# SAS MCP server configuration\n"}]}
  }')
  template_filter='
    .metadata.image == $image and (.metadata.port | tostring) == "8134"
    and .metadata.transport == "http" and .metadata.basepath == "/mcp"
    and .metadata.auth == "identity_broker"
    and .secrets.auth_credentials.identity_broker_alias == $idp_alias
  '
  ensure_ram_template 'user-authenticated sas-mcp-tools' "$template" "$template_filter"
  template_id=$TEMPLATE_ID
  template_version=$TEMPLATE_VERSION

  server=$(jq --null-input \
    --arg template_id "$template_id" \
    --argjson template_version "$template_version" \
    --arg viya_url "$VIYA_URL" --arg idp_alias "$IDP_ALIAS" '{
      id: "", name: "user-authenticated sas-mcp-tools",
      description: "SAS MCP Server container tools that use the authenticated user token.",
      template_id: $template_id, template_version: $template_version,
      type: "container", template_type: "tool_container",
      metadata: {auth: "identity_broker"},
      secrets: {auth_credentials: {identity_broker_alias: $idp_alias},
        extra_auth_headers: {}, env_vars: [
          {name: "VIYA_ENDPOINT", value: $viya_url, description: "Viya deployment URL.", secret: false},
          {name: "ALLOW_RAW_BEARER", value: "true", description: "Allow raw bearer tokens.", secret: false}
        ]}
    }')
  server_filter='
    .template_id == $template_id and .template_version == $template_version
    and .metadata.auth == "identity_broker"
    and .secrets.auth_credentials.identity_broker_alias == $idp_alias
    and any(.secrets.env_vars[]?; .name == "VIYA_ENDPOINT" and .value == $viya_url)
  '
  ensure_ram_tool_server 'user-authenticated sas-mcp-tools' "$server" \
    "$template_id" "$template_version" "$server_filter"
}

run_mcp_setup() {
  printf 'Configuring the Viya OAuth client for the MCP tools server.\n'
  prepare_mcp_client_secret
  ensure_viya_mcp_group
  ensure_viya_mcp_client
  get_ram_api_token
  ensure_oauth_mcp_server
  ensure_user_token_mcp_server
  printf 'Both RAM MCP tools servers are configured.\n'
}
