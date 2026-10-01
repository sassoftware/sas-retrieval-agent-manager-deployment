#!/usr/bin/env bash

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_value() {
  local option=$1
  local value=${2:-}
  [[ -n "$value" ]] || die "$option requires a value."
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required."
}

trim_url() {
  local value=$1
  while [[ "$value" == */ ]]; do
    value=${value%/}
  done
  printf '%s' "$value"
}

validate_https_url() {
  local name=$1
  local value=$2
  [[ "$value" =~ ^https://[^/?#[:space:]]+([/?#].*)?$ ]] \
    || die "$name must be an HTTPS URL."
  [[ "$value" != *$'\n'* && "$value" != *$'\r'* ]] \
    || die "$name cannot contain a newline."
}

validate_kubernetes_name() {
  local name=$1
  local value=$2
  [[ "$value" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]] \
    || die "$name is not a valid Kubernetes name: $value"
}

validate_alias() {
  local name=$1
  local value=$2
  [[ "$value" =~ ^[A-Za-z0-9._-]+$ ]] \
    || die "$name contains unsupported characters."
}

prompt_secret() {
  local variable_name=$1
  local prompt=$2
  local value=${!variable_name:-}

  if [[ -z "$value" ]]; then
    [[ -r /dev/tty ]] \
      || die "Run this script from a terminal to enter $variable_name."
    printf '%s' "$prompt" >/dev/tty
    IFS= read -r -s value </dev/tty || die "Could not read $variable_name."
    printf '\n' >/dev/tty
  fi

  [[ -n "$value" ]] || die "$variable_name must not be empty."
  printf -v "$variable_name" '%s' "$value"
}

init_temporary_directory() {
  umask 077
  TEMPORARY_DIRECTORY=$(mktemp -d "${TMPDIR:-/tmp}/ram-connect-viya.XXXXXX")
  RESPONSE_FILE="$TEMPORARY_DIRECTORY/response.json"
  HEADER_FILE="$TEMPORARY_DIRECTORY/headers.txt"
  : >"$RESPONSE_FILE"
  : >"$HEADER_FILE"
}

cleanup_temporary_directory() {
  if [[ -n "${TEMPORARY_DIRECTORY:-}" && -d "$TEMPORARY_DIRECTORY" ]]; then
    rm -rf "$TEMPORARY_DIRECTORY"
  fi
}

configure_tls() {
  CURL_TLS_ARGS=()
  if [[ -n "${CA_CERT:-}" ]]; then
    [[ -r "$CA_CERT" ]] || die "The CA certificate file is not readable: $CA_CERT"
    CURL_TLS_ARGS+=(--cacert "$CA_CERT")
  fi
}

kubectl_cmd() {
  kubectl --context "$KUBE_CONTEXT" "$@"
}

verify_kubernetes_target() {
  local current_context server
  current_context=$(kubectl config current-context 2>/dev/null) \
    || die "Could not read the current Kubernetes context."
  [[ "$current_context" == "$KUBE_CONTEXT" ]] \
    || die "The current Kubernetes context is '$current_context', not '$KUBE_CONTEXT'."

  server=$(kubectl config view --minify --output \
    'jsonpath={.clusters[0].cluster.server}' 2>/dev/null) \
    || die "Could not read the Kubernetes server."
  [[ -n "$server" ]] || die "The current Kubernetes context has no server."

  kubectl_cmd cluster-info >/dev/null \
    || die "Could not connect to the Kubernetes cluster."
  printf 'Kubernetes context: %s\n' "$KUBE_CONTEXT"
  printf 'Kubernetes server: %s\n' "$server"
}

http_request() {
  local method=$1
  local url=$2
  local bearer_token=${3:-}
  local content_type=${4:-}
  local body=${5:-}
  local request_file=
  local curl_config="$TEMPORARY_DIRECTORY/curl-options"
  local config_value option
  shift 5

  local -a args=(
    --silent
    --show-error
    --connect-timeout 15
    --max-time 120
    --request "$method"
    --output "$RESPONSE_FILE"
    --dump-header "$HEADER_FILE"
    --write-out '%{http_code}'
    "${CURL_TLS_ARGS[@]}"
  )

  : >"$curl_config"
  chmod 600 "$curl_config"
  config_value=$(jq --null-input --arg value 'Accept: application/json' '$value')
  printf 'header = %s\n' "$config_value" >>"$curl_config"
  if [[ -n "$bearer_token" ]]; then
    config_value=$(jq --null-input --arg value "Authorization: Bearer $bearer_token" '$value')
    printf 'header = %s\n' "$config_value" >>"$curl_config"
  fi
  if [[ -n "$content_type" ]]; then
    config_value=$(jq --null-input --arg value "Content-Type: $content_type" '$value')
    printf 'header = %s\n' "$config_value" >>"$curl_config"
  fi

  if [[ -n "$body" ]]; then
    request_file="$TEMPORARY_DIRECTORY/request-body"
    printf '%s' "$body" >"$request_file"
    chmod 600 "$request_file"
    args+=(--data-binary "@$request_file")
  fi

  while (( $# > 0 )); do
    case "$1" in
      --user|--data-urlencode|--header)
        [[ -n "${2:-}" ]] || die "$1 requires a value."
        case "$1" in
          --user) option=user ;;
          --data-urlencode) option=data-urlencode ;;
          --header) option=header ;;
        esac
        config_value=$(jq --null-input --arg value "$2" '$value')
        printf '%s = %s\n' "$option" "$config_value" >>"$curl_config"
        shift 2
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done
  args+=(--config "$curl_config")

  : >"$RESPONSE_FILE"
  : >"$HEADER_FILE"
  if ! HTTP_STATUS=$(curl "${args[@]}" "$url"); then
    [[ -z "$request_file" ]] || : >"$request_file"
    : >"$curl_config"
    die "$method request failed before an HTTP response."
  fi
  [[ -z "$request_file" ]] || : >"$request_file"
  : >"$curl_config"
}

sanitized_error() {
  printf 'The service returned an error. No response details are shown.'
}

expect_http() {
  local operation=$1
  shift
  local expected
  for expected in "$@"; do
    if [[ "$HTTP_STATUS" == "$expected" ]]; then
      return
    fi
  done
  die "$operation returned HTTP $HTTP_STATUS: $(sanitized_error)"
}

response_value() {
  local filter=$1
  jq --exit-status --raw-output "$filter // empty" "$RESPONSE_FILE" 2>/dev/null \
    || return 1
}

kubernetes_secret_value() {
  local namespace=$1
  local secret=$2
  local key=$3
  local encoded
  encoded=$(kubectl_cmd get secret "$secret" --namespace "$namespace" \
    --output "jsonpath={.data.${key}}") \
    || die "Could not read key '$key' from Secret '$namespace/$secret'."
  [[ -n "$encoded" ]] || die "Secret '$namespace/$secret' has no value for '$key'."
  printf '%s' "$encoded" | base64 --decode
}

random_secret() {
  openssl rand -base64 48 | tr -d '\r\n'
}

new_uuid() {
  if [[ -r /proc/sys/kernel/random/uuid ]]; then
    tr -d '\r\n' </proc/sys/kernel/random/uuid
  else
    cat /proc/sys/kernel/random/uuid
  fi
}

confirm_changes() {
  [[ -r /dev/tty ]] || die "Run this script from a terminal to confirm the changes."
  printf 'Enter CONNECT to continue: ' >/dev/tty
  local answer
  IFS= read -r answer </dev/tty || die "Could not read the confirmation."
  [[ "$answer" == CONNECT ]] || die "The changes were not confirmed."
}
