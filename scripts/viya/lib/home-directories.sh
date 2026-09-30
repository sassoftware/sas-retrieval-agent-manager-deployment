#!/usr/bin/env bash

HOME_DIRECTORY_SCRIPT=${BASH_SOURCE[0]}

home_worker_die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

home_worker_request() {
  local url=$1
  shift
  local option config_value
  local -a args=(--output "$HOME_RESPONSE_FILE" --write-out '%{http_code}')
  : >"$HOME_CURL_CONFIG"
  chmod 600 "$HOME_CURL_CONFIG"
  config_value=$(jq --null-input --arg value 'Accept: application/json' '$value')
  printf 'header = %s\n' "$config_value" >>"$HOME_CURL_CONFIG"
  while (( $# > 0 )); do
    case "$1" in
      --user|--data-urlencode|--header)
        [[ -n "${2:-}" ]] || home_worker_die "$1 requires a value."
        case "$1" in
          --user) option=user ;;
          --data-urlencode) option=data-urlencode ;;
          --header) option=header ;;
        esac
        config_value=$(jq --null-input --arg value "$2" '$value')
        printf '%s = %s\n' "$option" "$config_value" >>"$HOME_CURL_CONFIG"
        shift 2
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done
  : >"$HOME_RESPONSE_FILE"
  if ! HOME_HTTP_STATUS=$(curl --silent --show-error --location \
    --connect-timeout 15 --max-time 120 \
    "${HOME_CURL_TLS_ARGS[@]}" "${args[@]}" \
    --config "$HOME_CURL_CONFIG" "$url"); then
    : >"$HOME_CURL_CONFIG"
    home_worker_die "A Viya request failed before an HTTP response."
  fi
  : >"$HOME_CURL_CONFIG"
}

home_worker_get_token() {
  home_worker_request "$HOME_VIYA_URL/SASLogon/oauth/token" \
    --request POST --user 'sas.cli:' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$HOME_VIYA_USER" \
    --data-urlencode "password=$HOME_VIYA_PASSWORD"
  [[ "$HOME_HTTP_STATUS" == 200 ]] \
    || home_worker_die "Viya authentication returned HTTP $HOME_HTTP_STATUS."
  HOME_VIYA_TOKEN=$(jq --exit-status --raw-output '.access_token' "$HOME_RESPONSE_FILE") \
    || home_worker_die "Viya authentication did not return an access token."
  HOME_VIYA_REFRESH_TOKEN=$(jq --raw-output '.refresh_token // empty' "$HOME_RESPONSE_FILE")
  : >"$HOME_RESPONSE_FILE"
}

home_worker_authcheck() {
  local payload padding decoded expires now
  payload=${HOME_VIYA_TOKEN#*.}
  payload=${payload%%.*}
  payload=$(printf '%s' "$payload" | tr '_-' '/+')
  padding=$(( (4 - ${#payload} % 4) % 4 ))
  while (( padding > 0 )); do
    payload+='='
    padding=$((padding - 1))
  done
  decoded=$(printf '%s' "$payload" | base64 --decode 2>/dev/null) \
    || home_worker_die "Could not read the Viya token expiration time."
  expires=$(jq --exit-status --raw-output '.exp' <<<"$decoded") \
    || home_worker_die "The Viya access token has no expiration time."
  [[ "$expires" =~ ^[0-9]+$ ]] || home_worker_die "The Viya access token has an invalid expiration time."
  now=$(date +%s)
  if (( now >= expires || expires - now < 60 )); then
    [[ -n "$HOME_VIYA_REFRESH_TOKEN" ]] \
      || home_worker_die "The Viya access token expired and no refresh token is available."
    home_worker_request "$HOME_VIYA_URL/SASLogon/oauth/token" \
      --request POST --user 'sas.cli:' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=refresh_token' \
      --data-urlencode "refresh_token=$HOME_VIYA_REFRESH_TOKEN"
    [[ "$HOME_HTTP_STATUS" == 200 ]] \
      || home_worker_die "Viya token refresh returned HTTP $HOME_HTTP_STATUS."
    HOME_VIYA_TOKEN=$(jq --exit-status --raw-output '.access_token' "$HOME_RESPONSE_FILE") \
      || home_worker_die "Viya token refresh did not return an access token."
    HOME_VIYA_REFRESH_TOKEN=$(jq --raw-output '.refresh_token // empty' "$HOME_RESPONSE_FILE")
    : >"$HOME_RESPONSE_FILE"
  fi
}

home_worker_create_directory() {
  local user_id=$1 encoded_user uid gid path
  [[ -n "$user_id" && "$user_id" != '.' && "$user_id" != '..' && "$user_id" != */* ]] \
    || home_worker_die "Viya returned an unsafe user ID."
  home_worker_authcheck
  encoded_user=$(jq --null-input --raw-output --arg value "$user_id" '$value | @uri')
  home_worker_request "$HOME_VIYA_URL/identities/users/$encoded_user/identifier" \
    --header "Authorization: Bearer $HOME_VIYA_TOKEN" \
    --header 'Accept: application/json'
  if [[ "$HOME_HTTP_STATUS" == 404 ]]; then
    printf 'Skipped a Viya user without an identifier.\n'
    return
  fi
  [[ "$HOME_HTTP_STATUS" == 200 ]] \
    || home_worker_die "A Viya user identifier request returned HTTP $HOME_HTTP_STATUS."
  uid=$(jq --exit-status --raw-output '.uid' "$HOME_RESPONSE_FILE") \
    || { printf 'Skipped a Viya user without a UID.\n'; return; }
  gid=$(jq --exit-status --raw-output '.gid' "$HOME_RESPONSE_FILE") \
    || { printf 'Skipped a Viya user without a GID.\n'; return; }
  [[ "$uid" =~ ^[0-9]+$ && "$gid" =~ ^[0-9]+$ ]] \
    || { printf 'Skipped a Viya user with an invalid UID or GID.\n'; return; }

  path="$HOME_ROOT/$user_id"
  if [[ -e "$path" ]]; then
    [[ -d "$path" ]] || home_worker_die "A Viya home path exists but is not a directory."
    printf 'Kept an existing Viya home directory.\n'
    return
  fi

  install -d -m 0700 -o "$uid" -g "$gid" "$path" \
    || home_worker_die "Could not create a Viya home directory."
}

run_home_directory_worker() {
  set -euo pipefail
  umask 077
  : "${HOME_ROOT:?HOME_ROOT is required}"
  : "${HOME_VIYA_URL:?HOME_VIYA_URL is required}"
  : "${HOME_VIYA_USER:?HOME_VIYA_USER is required}"
  : "${HOME_VIYA_PASSWORD:?HOME_VIYA_PASSWORD is required}"
  HOME_VIYA_URL=${HOME_VIYA_URL%/}
  HOME_RESPONSE_FILE=$(mktemp /tmp/viya-home-response.XXXXXX)
  HOME_CURL_CONFIG=$(mktemp /tmp/viya-home-curl.XXXXXX)
  trap 'rm -f "$HOME_RESPONSE_FILE" "$HOME_CURL_CONFIG"' EXIT
  HOME_CURL_TLS_ARGS=()
  if [[ -f /opt/viya-ca/ca.crt ]]; then
    HOME_CURL_TLS_ARGS+=(--cacert /opt/viya-ca/ca.crt)
  fi

  command -v curl >/dev/null 2>&1 || home_worker_die "curl is required."
  command -v jq >/dev/null 2>&1 || home_worker_die "jq is required."
  [[ -d "$HOME_ROOT" && -w "$HOME_ROOT" ]] \
    || home_worker_die "The Viya home export is not writable."

  home_worker_get_token
  local next_url="$HOME_VIYA_URL/identities/users" user_id
  local -a users=()
  while [[ -n "$next_url" ]]; do
    home_worker_authcheck
    home_worker_request "$next_url" \
      --header "Authorization: Bearer $HOME_VIYA_TOKEN" \
      --header 'Accept: application/json'
    [[ "$HOME_HTTP_STATUS" == 200 ]] \
      || home_worker_die "The Viya user-list request returned HTTP $HOME_HTTP_STATUS."
    mapfile -t -O "${#users[@]}" users < <(jq --raw-output '.items[].id' "$HOME_RESPONSE_FILE")
    next_url=$(jq --raw-output \
      '[.links[]? | select(.rel == "next") | .href][0] // empty' "$HOME_RESPONSE_FILE")
    if [[ -n "$next_url" && "$next_url" == /* ]]; then
      next_url="$HOME_VIYA_URL$next_url"
    fi
  done
  [[ ${#users[@]} -gt 0 ]] || home_worker_die "Viya returned no users."

  for user_id in "${users[@]}"; do
    home_worker_create_directory "$user_id"
  done
  printf 'Verified %s Viya home directories.\n' "${#users[@]}"
}

discover_viya_home_export() {
  local nfs_json
  if nfs_json=$(kubectl_cmd get pods --namespace "$VIYA_NAMESPACE" --output json \
    | jq --exit-status --compact-output '
      [.items[].spec.volumes[]?
       | select(.nfs.server? and .nfs.path? and (.nfs.path | endswith("/homes")))
       | .nfs] | unique
      | if length == 1 then .[0] else empty end
    '); then
    :
  else
    nfs_json=$(kubectl_cmd get pv --output json \
      | jq --exit-status --compact-output '
        [.items[]
         | select(.spec.nfs.server? and .spec.nfs.path?
           and (.spec.nfs.path | endswith("/homes")))
         | .spec.nfs] | unique
        | if length == 1 then .[0] else empty end
      ') || die "Exactly one Viya NFS home export is required."
  fi
  HOME_NFS_SERVER=$(jq --exit-status --raw-output '.server' <<<"$nfs_json") \
    || die "The Viya NFS home export has no server."
  HOME_NFS_PATH=$(jq --exit-status --raw-output '.path' <<<"$nfs_json") \
    || die "The Viya NFS home export has no path."
  [[ -n "$HOME_NFS_SERVER" && "$HOME_NFS_PATH" == /*/homes ]] \
    || die "The Viya NFS home export is invalid."
  printf 'Found one Viya NFS home export.\n'
}

cleanup_home_directory_resources() {
  [[ "${HOME_RESOURCES_CREATED:-false}" == true ]] || return
  kubectl_cmd delete job "$HOME_JOB_NAME" --namespace "$RAM_NAMESPACE" \
    --ignore-not-found >/dev/null 2>&1 || true
  kubectl_cmd delete secret "$HOME_SECRET_NAME" --namespace "$RAM_NAMESPACE" \
    --ignore-not-found >/dev/null 2>&1 || true
  kubectl_cmd delete configmap "$HOME_CONFIGMAP_NAME" --namespace "$RAM_NAMESPACE" \
    --ignore-not-found >/dev/null 2>&1 || true
  if [[ -n "${HOME_CA_CONFIGMAP_NAME:-}" ]]; then
    kubectl_cmd delete configmap "$HOME_CA_CONFIGMAP_NAME" --namespace "$RAM_NAMESPACE" \
      --ignore-not-found >/dev/null 2>&1 || true
  fi
}

verify_home_resource_names_available() {
  local kind name
  for kind in job secret configmap; do
    case "$kind" in
      job) name=$HOME_JOB_NAME ;;
      secret) name=$HOME_SECRET_NAME ;;
      configmap) name=$HOME_CONFIGMAP_NAME ;;
    esac
    if kubectl_cmd get "$kind" "$name" --namespace "$RAM_NAMESPACE" >/dev/null 2>&1; then
      die "Temporary resource '$RAM_NAMESPACE/$name' already exists."
    fi
  done
  if [[ -n "$HOME_CA_CONFIGMAP_NAME" ]] \
    && kubectl_cmd get configmap "$HOME_CA_CONFIGMAP_NAME" \
      --namespace "$RAM_NAMESPACE" >/dev/null 2>&1; then
    die "Temporary resource '$RAM_NAMESPACE/$HOME_CA_CONFIGMAP_NAME' already exists."
  fi
}

run_home_directory_setup() {
  HOME_JOB_NAME=viya-home-directory-provisioner
  HOME_SECRET_NAME="$HOME_JOB_NAME-credentials"
  HOME_CONFIGMAP_NAME="$HOME_JOB_NAME-script"
  HOME_CA_CONFIGMAP_NAME=
  [[ -z "${CA_CERT:-}" ]] || HOME_CA_CONFIGMAP_NAME="$HOME_JOB_NAME-ca"

  discover_viya_home_export
  verify_home_resource_names_available
  if [[ "$CHECK_ONLY" == true ]]; then
    printf 'The Viya home-directory temporary resource names are available.\n'
    return
  fi

  local script_path=$HOME_DIRECTORY_SCRIPT
  local password_file="$TEMPORARY_DIRECTORY/sasboot-password"
  printf '%s' "$VIYA_PASSWORD" >"$password_file"
  chmod 600 "$password_file"

  kubectl_cmd create configmap "$HOME_CONFIGMAP_NAME" \
    --namespace "$RAM_NAMESPACE" \
    --from-file="home-directories.sh=$script_path" >/dev/null
  HOME_RESOURCES_CREATED=true
  kubectl_cmd create secret generic "$HOME_SECRET_NAME" \
    --namespace "$RAM_NAMESPACE" \
    --from-file="password=$password_file" >/dev/null
  if [[ -n "$HOME_CA_CONFIGMAP_NAME" ]]; then
    kubectl_cmd create configmap "$HOME_CA_CONFIGMAP_NAME" \
      --namespace "$RAM_NAMESPACE" --from-file="ca.crt=$CA_CERT" >/dev/null
  fi

  local manifest="$TEMPORARY_DIRECTORY/viya-home-job.json"
  jq --null-input \
    --arg namespace "$RAM_NAMESPACE" \
    --arg job "$HOME_JOB_NAME" \
    --arg secret "$HOME_SECRET_NAME" \
    --arg configmap "$HOME_CONFIGMAP_NAME" \
    --arg ca_configmap "$HOME_CA_CONFIGMAP_NAME" \
    --arg viya_url "$VIYA_URL" \
    --arg viya_user "$VIYA_USER" \
    --arg nfs_server "$HOME_NFS_SERVER" \
    --arg nfs_path "$HOME_NFS_PATH" '
    {
      apiVersion: "batch/v1", kind: "Job",
      metadata: {name: $job, namespace: $namespace},
      spec: {backoffLimit: 0, ttlSecondsAfterFinished: 3600,
        template: {metadata: {labels: {app: $job}}, spec: {
          restartPolicy: "Never", automountServiceAccountToken: false,
          securityContext: {runAsUser: 0, runAsGroup: 0,
            seccompProfile: {type: "RuntimeDefault"}},
          containers: [{name: "provision", image: "alpine:3.20",
            securityContext: {allowPrivilegeEscalation: true},
            env: [
              {name: "HOME_ROOT", value: "/export/viya/homes"},
              {name: "HOME_VIYA_URL", value: $viya_url},
              {name: "HOME_VIYA_USER", value: $viya_user},
              {name: "HOME_VIYA_PASSWORD",
               valueFrom: {secretKeyRef: {name: $secret, key: "password"}}}
            ],
            command: ["/bin/sh", "-c"],
            args: ["apk add --no-cache bash coreutils curl jq >/dev/null && bash /opt/script/home-directories.sh --worker"],
            volumeMounts: ([
              {name: "homes", mountPath: "/export/viya/homes", readOnly: false},
              {name: "script", mountPath: "/opt/script", readOnly: true}
            ] + if $ca_configmap == "" then [] else
              [{name: "viya-ca", mountPath: "/opt/viya-ca", readOnly: true}] end)
          }],
          volumes: ([
            {name: "homes", nfs: {server: $nfs_server, path: $nfs_path, readOnly: false}},
            {name: "script", configMap: {name: $configmap, defaultMode: 365}}
          ] + if $ca_configmap == "" then [] else
            [{name: "viya-ca", configMap: {name: $ca_configmap}}] end)
        }}
      }
    }' >"$manifest"

  kubectl_cmd create --filename "$manifest" >/dev/null
  if ! kubectl_cmd wait --for=condition=complete "job/$HOME_JOB_NAME" \
    --namespace "$RAM_NAMESPACE" --timeout=15m; then
    die "The Viya home-directory Job did not complete."
  fi
  printf 'The Viya home-directory Job completed.\n'
  cleanup_home_directory_resources
  HOME_RESOURCES_CREATED=false
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ "${1:-}" == --worker ]]; then
    run_home_directory_worker
  else
    printf 'Error: this file is a library.\n' >&2
    exit 2
  fi
fi
