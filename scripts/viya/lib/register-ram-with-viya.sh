#!/usr/bin/env bash

set -euo pipefail

VIYA_URL="${VIYA_URL:-}"
ACCESS_TOKEN="${ACCESS_TOKEN:-}"
AUTHORIZATION_CODE="${AUTHORIZATION_CODE:-}"
VIYA_USERNAME="${VIYA_USERNAME:-}"
VIYA_PASSWORD="${VIYA_PASSWORD:-}"
CA_CERT="${CA_CERT:-}"
INSECURE="${INSECURE:-false}"

REGISTRY_NAME="${REGISTRY_NAME:-RetrievalAgentManager}"
APP_ID="${APP_ID:-RetrievalAgentManager}"
DISPLAY_NAME="${DISPLAY_NAME:-Retrieval Agent Manager}"
RAM_URI="${RAM_URI:-/SASRetrievalAgentManager/}"
PARENT_ID="${PARENT_ID:-agent_life_cycle_branch}"
PARENT_LABEL="${PARENT_LABEL:-Agentic Life Cycle}"
RELATIVE_ORDER="${RELATIVE_ORDER:-140}"
RESOURCE_PREFIX="${RESOURCE_PREFIX:-sasretrievalagentmanager}"
DRY_RUN=false
DELETE_ID="${DELETE_ID:-}"

usage() {
  cat <<'EOF'
Register SAS Retrieval Agent Manager in a SAS Viya application registry.

Usage:
  register-ram-with-viya.sh --viya-url URL [authentication] [options]

Authentication (choose one):
  --access-token TOKEN          Use an existing administrative SASLogon token
  --authorization-code CODE     Exchange a sas.cli authorization code
  --username USER               Use SASLogon password grant; prompts for password

Deletion:
  --delete ID                    Delete the app registry integration entry with
                                 this name/ID instead of registering one

Registration options:
  --name NAME                   Registry directive name
  --app-id ID                   Application ID
  --display-name LABEL          Display and shortcut label
  --uri PATH                    Application path, including leading slash
  --parent-id ID                Parent branch identifier
  --parent-label LABEL          Parent branch display label
  --relative-order NUMBER       Position within the parent branch
  --resource-prefix PREFIX      XML localization property-file prefix

TLS and execution options:
  --ca-cert FILE                CA certificate bundle for Viya TLS
  --insecure                    Disable TLS certificate verification
  --dry-run                     Print generated request JSON without authenticating
  -h, --help                    Show this help

Values can also be supplied directly as shell environment variables. This script
does not read or source a .env file. Supported variables are VIYA_URL,
ACCESS_TOKEN, AUTHORIZATION_CODE, VIYA_USERNAME, VIYA_PASSWORD, CA_CERT,
INSECURE, REGISTRY_NAME, APP_ID, DISPLAY_NAME, RAM_URI, PARENT_ID,
PARENT_LABEL, RELATIVE_ORDER, and RESOURCE_PREFIX.

Examples:
  ACCESS_TOKEN='...' register-ram-with-viya.sh --viya-url https://viya.example.com
  register-ram-with-viya.sh --viya-url https://viya.example.com \
    --authorization-code '...' --ca-cert /path/to/ca.pem
  register-ram-with-viya.sh --display-name 'SAS Retrieval Agent Manager' --dry-run
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_value() {
  local option="$1"
  local value="${2:-}"
  [[ -n "${value}" ]] || die "${option} requires a value."
}

xml_escape() {
  printf '%s' "$1" | sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\\\&apos;/g"
}

request() {
  local response
  response="$(curl --silent --show-error "${CURL_TLS_ARGS[@]}" "$@" --write-out $'\n%{http_code}')"
  HTTP_STATUS="${response##*$'\n'}"
  HTTP_BODY="${response%$'\n'*}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --viya-url)
      require_value "$1" "${2:-}"
      VIYA_URL="$2"
      shift 2
      ;;
    --access-token)
      require_value "$1" "${2:-}"
      ACCESS_TOKEN="$2"
      shift 2
      ;;
    --authorization-code)
      require_value "$1" "${2:-}"
      AUTHORIZATION_CODE="$2"
      shift 2
      ;;
    --username)
      require_value "$1" "${2:-}"
      VIYA_USERNAME="$2"
      shift 2
      ;;
    --delete)
      require_value "$1" "${2:-}"
      DELETE_ID="$2"
      shift 2
      ;;
    --name)
      require_value "$1" "${2:-}"
      REGISTRY_NAME="$2"
      shift 2
      ;;
    --app-id)
      require_value "$1" "${2:-}"
      APP_ID="$2"
      shift 2
      ;;
    --display-name)
      require_value "$1" "${2:-}"
      DISPLAY_NAME="$2"
      shift 2
      ;;
    --uri)
      require_value "$1" "${2:-}"
      RAM_URI="$2"
      shift 2
      ;;
    --parent-id)
      require_value "$1" "${2:-}"
      PARENT_ID="$2"
      shift 2
      ;;
    --parent-label)
      require_value "$1" "${2:-}"
      PARENT_LABEL="$2"
      shift 2
      ;;
    --relative-order)
      require_value "$1" "${2:-}"
      RELATIVE_ORDER="$2"
      shift 2
      ;;
    --resource-prefix)
      require_value "$1" "${2:-}"
      RESOURCE_PREFIX="$2"
      shift 2
      ;;
    --ca-cert)
      require_value "$1" "${2:-}"
      CA_CERT="$2"
      shift 2
      ;;
    --insecure)
      INSECURE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

command -v curl >/dev/null 2>&1 || die "curl is required."
command -v jq >/dev/null 2>&1 || die "jq is required."
command -v sed >/dev/null 2>&1 || die "sed is required."

if [[ -n "${DELETE_ID}" ]]; then
  [[ "${DELETE_ID}" != *$'\n'* && "${DELETE_ID}" != *$'\r'* ]] || die "DELETE_ID cannot contain newlines."

  [[ -n "${VIYA_URL}" ]] || die "VIYA_URL or --viya-url is required."
  VIYA_URL="${VIYA_URL%/}"

  CURL_TLS_ARGS=()
  if [[ "${INSECURE}" == true ]]; then
    CURL_TLS_ARGS+=(--insecure)
  elif [[ -n "${CA_CERT}" ]]; then
    [[ -f "${CA_CERT}" ]] || die "CA certificate not found: ${CA_CERT}"
    CURL_TLS_ARGS+=(--cacert "${CA_CERT}")
  fi

  HTTP_STATUS=""
  HTTP_BODY=""

  if [[ -z "${ACCESS_TOKEN}" && -n "${AUTHORIZATION_CODE}" ]]; then
    printf 'Exchanging SASLogon authorization code...\n'
    request --request POST \
      --url "${VIYA_URL}/SASLogon/oauth/token" \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=authorization_code' \
      --data-urlencode "code=${AUTHORIZATION_CODE}" \
      --data-urlencode 'client_id=sas.cli'
    [[ "${HTTP_STATUS}" == 200 ]] || die "authorization-code exchange failed (HTTP ${HTTP_STATUS}): ${HTTP_BODY}"
    ACCESS_TOKEN="$(jq --exit-status --raw-output '.access_token' <<<"${HTTP_BODY}")" || die "token response did not include access_token."
  elif [[ -z "${ACCESS_TOKEN}" && -n "${VIYA_USERNAME}" ]]; then
    if [[ -z "${VIYA_PASSWORD}" ]]; then
      read -r -s -p "Password for ${VIYA_USERNAME}: " VIYA_PASSWORD
      printf '\n'
    fi
    printf 'Authenticating with SASLogon...\n'
    request --request POST \
      --url "${VIYA_URL}/SASLogon/oauth/token" \
      --user 'sas.cli:' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=password' \
      --data-urlencode "username=${VIYA_USERNAME}" \
      --data-urlencode "password=${VIYA_PASSWORD}"
    [[ "${HTTP_STATUS}" == 200 ]] || die "SASLogon authentication failed (HTTP ${HTTP_STATUS}): ${HTTP_BODY}"
    ACCESS_TOKEN="$(jq --exit-status --raw-output '.access_token' <<<"${HTTP_BODY}")" || die "token response did not include access_token."
  fi

  [[ -n "${ACCESS_TOKEN}" ]] || die "provide ACCESS_TOKEN, --access-token, --authorization-code, or --username."

  if [[ "${DRY_RUN}" == true ]]; then
    printf 'Would delete %s/appRegistry/integration/%s\n' "${VIYA_URL}" "${DELETE_ID}"
    exit 0
  fi

  printf 'Deleting %s from %s...\n' "${DELETE_ID}" "${VIYA_URL}"
  request --request DELETE \
    --url "${VIYA_URL}/appRegistry/integration/${DELETE_ID}" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}"

  if [[ "${HTTP_STATUS}" != 200 && "${HTTP_STATUS}" != 204 ]]; then
    printf 'Deletion failed (HTTP %s).\n' "${HTTP_STATUS}" >&2
    jq . <<<"${HTTP_BODY}" 2>/dev/null || printf '%s\n' "${HTTP_BODY}" >&2
    exit 1
  fi

  printf 'Deleted %s (HTTP %s).\n' "${DELETE_ID}" "${HTTP_STATUS}"
  [[ -z "${HTTP_BODY}" ]] || jq . <<<"${HTTP_BODY}" 2>/dev/null || printf '%s\n' "${HTTP_BODY}"
  exit 0
fi

[[ "${RAM_URI}" == /* ]] || die "RAM_URI must start with '/'."
[[ "${RELATIVE_ORDER}" =~ ^[0-9]+$ ]] || die "RELATIVE_ORDER must be a non-negative integer."
[[ "${RESOURCE_PREFIX}" =~ ^[A-Za-z0-9._-]+$ ]] || die "RESOURCE_PREFIX contains unsupported characters."

for value in "${REGISTRY_NAME}" "${APP_ID}" "${DISPLAY_NAME}" "${RAM_URI}" "${PARENT_ID}" "${PARENT_LABEL}"; do
  [[ "${value}" != *$'\n'* && "${value}" != *$'\r'* ]] || die "registration values cannot contain newlines."
done

registry_name_xml="$(xml_escape "${REGISTRY_NAME}")"
app_id_xml="$(xml_escape "${APP_ID}")"
display_name_xml="$(xml_escape "${DISPLAY_NAME}")"
ram_uri_xml="$(xml_escape "${RAM_URI}")"
parent_id_xml="$(xml_escape "${PARENT_ID}")"
resource_prefix_xml="$(xml_escape "${RESOURCE_PREFIX}")"

integration_xml="$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<appRegistryEntries>
  <appRegistryBranch name="${parent_id_xml}"
             label.key="branch.label.txt">
    <localizationResource propertyFilePrefix="${resource_prefix_xml}"/>
  </appRegistryBranch>
    <appRegistryLeaf name="${registry_name_xml}" label.key="label.txt" uri="${ram_uri_xml}" parentId="${parent_id_xml}">
        <options appId="${app_id_xml}"
                 appSwitcherCompliance="true"
                 createDefaultShortcut="true"
                 relativeOrder="${RELATIVE_ORDER}"
                 appName="${display_name_xml}"
                 shortcutLabel.key="label.txt"/>
        <localizationResource propertyFilePrefix="${resource_prefix_xml}"/>
    </appRegistryLeaf>
</appRegistryEntries>
EOF
)"

properties_contents="$(cat <<EOF
label.txt=${DISPLAY_NAME}
branch.label.txt=${PARENT_LABEL}
EOF
)"
request_json="$(jq --null-input \
  --arg xml_name "${RESOURCE_PREFIX}.xml" \
  --arg xml_contents "${integration_xml}" \
  --arg properties_name "${RESOURCE_PREFIX}.properties" \
  --arg properties_contents "${properties_contents}" \
  '{files: [
    {fileName: $xml_name, contents: $xml_contents},
    {fileName: $properties_name, contents: $properties_contents}
  ]}')"

if [[ "${DRY_RUN}" == true ]]; then
  jq . <<<"${request_json}"
  exit 0
fi

[[ -n "${VIYA_URL}" ]] || die "VIYA_URL or --viya-url is required."
VIYA_URL="${VIYA_URL%/}"

CURL_TLS_ARGS=()
if [[ "${INSECURE}" == true ]]; then
  CURL_TLS_ARGS+=(--insecure)
elif [[ -n "${CA_CERT}" ]]; then
  [[ -f "${CA_CERT}" ]] || die "CA certificate not found: ${CA_CERT}"
  CURL_TLS_ARGS+=(--cacert "${CA_CERT}")
fi

HTTP_STATUS=""
HTTP_BODY=""

if [[ -z "${ACCESS_TOKEN}" && -n "${AUTHORIZATION_CODE}" ]]; then
  printf 'Exchanging SASLogon authorization code...\n'
  request --request POST \
    --url "${VIYA_URL}/SASLogon/oauth/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=authorization_code' \
    --data-urlencode "code=${AUTHORIZATION_CODE}" \
    --data-urlencode 'client_id=sas.cli'
  [[ "${HTTP_STATUS}" == 200 ]] || die "authorization-code exchange failed (HTTP ${HTTP_STATUS}): ${HTTP_BODY}"
  ACCESS_TOKEN="$(jq --exit-status --raw-output '.access_token' <<<"${HTTP_BODY}")" || die "token response did not include access_token."
elif [[ -z "${ACCESS_TOKEN}" && -n "${VIYA_USERNAME}" ]]; then
  if [[ -z "${VIYA_PASSWORD}" ]]; then
    read -r -s -p "Password for ${VIYA_USERNAME}: " VIYA_PASSWORD
    printf '\n'
  fi
  printf 'Authenticating with SASLogon...\n'
  request --request POST \
    --url "${VIYA_URL}/SASLogon/oauth/token" \
    --user 'sas.cli:' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=${VIYA_USERNAME}" \
    --data-urlencode "password=${VIYA_PASSWORD}"
  [[ "${HTTP_STATUS}" == 200 ]] || die "SASLogon authentication failed (HTTP ${HTTP_STATUS}): ${HTTP_BODY}"
  ACCESS_TOKEN="$(jq --exit-status --raw-output '.access_token' <<<"${HTTP_BODY}")" || die "token response did not include access_token."
fi

[[ -n "${ACCESS_TOKEN}" ]] || die "provide ACCESS_TOKEN, --access-token, --authorization-code, or --username."

printf 'Registering %s at %s...\n' "${DISPLAY_NAME}" "${RAM_URI}"
request --request POST \
  --url "${VIYA_URL}/appRegistry/integration" \
  --header 'Accept: application/json, application/vnd.sas.app.registry.upload.result+json, application/vnd.sas.error+json' \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data-binary "${request_json}"

if [[ "${HTTP_STATUS}" != 200 && "${HTTP_STATUS}" != 201 ]]; then
  printf 'Registration failed (HTTP %s).\n' "${HTTP_STATUS}" >&2
  jq . <<<"${HTTP_BODY}" 2>/dev/null || printf '%s\n' "${HTTP_BODY}" >&2
  exit 1
fi

if [[ "${HTTP_STATUS}" == 201 ]]; then
  printf 'Registration changed (HTTP 201).\n'
else
  printf 'Registration processed with no change (HTTP 200).\n'
fi

jq . <<<"${HTTP_BODY}" 2>/dev/null || printf '%s\n' "${HTTP_BODY}"