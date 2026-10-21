#!/usr/bin/env bash
# Set the display names and descriptions of the RAM groups in SAS Viya.
# Use the Identities REST API. Keep group IDs and SSO group mappings unchanged.
# SSO means single sign-on.
#
# Requires: curl, jq, and a Viya user with permission to change groups.
#
# Usage:
#   DRY_RUN=1 bash rename_viya_group.sh
#   bash rename_viya_group.sh
#
# Required environment: VIYA_URL, VIYA_USER, VIYA_PASSWORD.
# Optional overrides:
#   RAM_ADMIN_GROUP_ID=ram-admin-group   RAM_ADMIN_GROUP_NAME="RAM Admin"
#   RAM_ADMIN_GROUP_DESC="Users with admin access to Retrieval Agent Manager"
#   RAM_USER_GROUP_ID=ram-user-group     RAM_USER_GROUP_NAME="RAM User"
#   RAM_USER_GROUP_DESC="Users with user access to Retrieval Agent Manager"

set -e -o pipefail

function die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

function check_env() {
  local var
  for var in VIYA_URL VIYA_USER VIYA_PASSWORD; do
    [ -n "${!var:-}" ] || die "Required environment variable unset: ${var}"
  done
  for var in curl jq awk; do
    command -v "${var}" >/dev/null || die "${var} is required."
  done
  VIYA_URL="${VIYA_URL%/}"
  RAM_ADMIN_GROUP_ID="${RAM_ADMIN_GROUP_ID:-ram-admin-group}"
  RAM_ADMIN_GROUP_NAME="${RAM_ADMIN_GROUP_NAME:-RAM Admin}"
  RAM_ADMIN_GROUP_DESC="${RAM_ADMIN_GROUP_DESC:-Users with admin access to Retrieval Agent Manager}"
  RAM_USER_GROUP_ID="${RAM_USER_GROUP_ID:-ram-user-group}"
  RAM_USER_GROUP_NAME="${RAM_USER_GROUP_NAME:-RAM User}"
  RAM_USER_GROUP_DESC="${RAM_USER_GROUP_DESC:-Users with user access to Retrieval Agent Manager}"
  DRY_RUN="${DRY_RUN:-}"
}

function get_viya_token() {
  local token
  token=$(curl -ksSf -X POST "${VIYA_URL}/SASLogon/oauth/token" \
    -u "sas.cli:" \
    --data-urlencode "grant_type=password" \
    --data-urlencode "username=${VIYA_USER}" \
    --data-urlencode "password=${VIYA_PASSWORD}" | jq -er '.access_token // empty') ||
    die "Failed to obtain Viya access token."
  printf '%s' "${token}"
}

function set_group_display() {
  local group_id="${1}" new_name="${2}" new_desc="${3}"
  local encoded_id url status etag
  encoded_id=$(jq -rn --arg id "${group_id}" '$id | @uri') || return 1
  url="${VIYA_URL}/identities/groups/${encoded_id}"
  status=$(curl -ksS -o "${body_file}" -D "${headers_file}" -w "%{http_code}" \
    "${url}" "${auth[@]}") || {
    printf "Could not read group '%s'.\n" "${group_id}" >&2
    return 1
  }
  if [ "${status}" != "200" ]; then
    printf "Group '%s' lookup returned HTTP %s. Run link_viya_identity.sh first.\n" \
      "${group_id}" "${status}" >&2
    return 1
  fi
  jq -e --arg id "${group_id}" '.id == $id' "${body_file}" >/dev/null || {
    printf "Group '%s' response has no matching ID.\n" "${group_id}" >&2
    return 1
  }
  if jq -e --arg name "${new_name}" --arg desc "${new_desc}" \
    '.name == $name and .description == $desc' "${body_file}" >/dev/null; then
    printf "Group '%s' already has the requested name and description.\n" "${group_id}"
    return 0
  fi
  if [ -n "${DRY_RUN}" ]; then
    printf "DRY RUN: Set group '%s' name to '%s' and description to '%s'.\n" \
      "${group_id}" "${new_name}" "${new_desc}"
    return 0
  fi

  # Use the entity tag (ETag) to prevent the loss of a concurrent group change.
  etag=$(awk 'tolower($1) == "etag:" {
    sub(/^[^:]*:[ \t]*/, ""); sub(/\r$/, ""); tag = $0
  } END {print tag}' "${headers_file}") || return 1
  local put_args=("${auth[@]}" -H "Content-Type: application/json")
  [ -z "${etag}" ] || put_args+=(-H "If-Match: ${etag}")
  jq --arg name "${new_name}" --arg desc "${new_desc}" \
    '.name = $name | .description = $desc' "${body_file}" >"${update_file}" || return 1
  status=$(curl -ksS -o "${body_file}" -w "%{http_code}" -X PUT "${url}" \
    "${put_args[@]}" --data-binary "@${update_file}") || {
    printf "Could not update group '%s'.\n" "${group_id}" >&2
    return 1
  }
  if [[ ! "${status}" =~ ^2[0-9][0-9]$ ]]; then
    printf "Group '%s' update returned HTTP %s.\n" "${group_id}" "${status}" >&2
    return 1
  fi
  status=$(curl -ksS -o "${body_file}" -w "%{http_code}" "${url}" "${auth[@]}") || {
    printf "Could not verify group '%s'.\n" "${group_id}" >&2
    return 1
  }
  if [ "${status}" != "200" ] || ! jq -e \
    --arg id "${group_id}" --arg name "${new_name}" --arg desc "${new_desc}" \
    '.id == $id and .name == $name and .description == $desc' "${body_file}" >/dev/null; then
    printf "Could not verify the name and description of group '%s'.\n" "${group_id}" >&2
    return 1
  fi
  printf "Group '%s' updated and verified.\n" "${group_id}"
}

check_env
umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "${temporary_directory}"' EXIT
body_file="${temporary_directory}/group.json"
headers_file="${temporary_directory}/headers"
update_file="${temporary_directory}/update.json"

echo "Authenticating with Viya..."
VIYA_TOKEN="$(get_viya_token)"
auth=(-H "Authorization: Bearer ${VIYA_TOKEN}" -H "Accept: application/json")
rc=0
set_group_display "${RAM_ADMIN_GROUP_ID}" "${RAM_ADMIN_GROUP_NAME}" "${RAM_ADMIN_GROUP_DESC}" || rc=1
set_group_display "${RAM_USER_GROUP_ID}" "${RAM_USER_GROUP_NAME}" "${RAM_USER_GROUP_DESC}" || rc=1
[ "${rc}" -eq 0 ] || die "One or more groups could not be updated."
echo "Group IDs and SSO group mappings are unchanged."
