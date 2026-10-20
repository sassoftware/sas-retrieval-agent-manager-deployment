#!/usr/bin/env bash
# Add one SAS Viya group to another through the Identities REST API.
# By default, add SASAdministrators to ram-admin-group.
# Change only the parent group. Keep the member group unchanged.
#
# Requires: curl, jq, and a Viya user with permission to change groups.
#
# Usage:
#   DRY_RUN=1 bash add_viya_group_member.sh
#   bash add_viya_group_member.sh
#   REMOVE=1 bash add_viya_group_member.sh
#
# Required environment: VIYA_URL, VIYA_USER, VIYA_PASSWORD.
# Optional overrides:
#   PARENT_GROUP_ID=ram-admin-group   MEMBER_GROUP_ID=SASAdministrators
#
# Check a new administrator login token after this change.
# The authorities claim must contain ram-admin-group for RAM admin access.
# If the token does not contain this group, add the users directly in Viya.

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
  for var in curl jq; do
    command -v "${var}" >/dev/null || die "${var} is required."
  done
  VIYA_URL="${VIYA_URL%/}"
  PARENT_GROUP_ID="${PARENT_GROUP_ID:-ram-admin-group}"
  MEMBER_GROUP_ID="${MEMBER_GROUP_ID:-SASAdministrators}"
  DRY_RUN="${DRY_RUN:-}"
  REMOVE="${REMOVE:-}"
  [ "${PARENT_GROUP_ID}" != "${MEMBER_GROUP_ID}" ] ||
    die "A group cannot be a member of itself (${PARENT_GROUP_ID})."
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

function group_exists() {
  local status
  status=$(curl -ksS -o /dev/null -w "%{http_code}" \
    "${VIYA_URL}/identities/groups/${1}" "${auth[@]}") ||
    die "Could not read group '${1}'."
  [ "${status}" == "200" ] ||
    die "Group '${1}' lookup returned HTTP ${status}. Run link_viya_identity.sh first."
}

# Return 0 for a member, 1 for no member, or 2 for a failed lookup.
function is_member() {
  local start=0 status size found
  while true; do
    status=$(curl -ksS -o "${response_file}" -w "%{http_code}" \
      "${VIYA_URL}/identities/groups/${parent_id}/members?start=${start}&limit=1000" \
      "${auth[@]}") || {
      printf 'Could not read group members.\n' >&2
      return 2
    }
    if [ "${status}" != "200" ]; then
      printf 'Group member lookup returned HTTP %s.\n' "${status}" >&2
      return 2
    fi
    size=$(jq -er '.items | arrays | length' "${response_file}") || {
      printf 'Group member response has no valid items array.\n' >&2
      return 2
    }
    found=$(jq -r --arg id "${MEMBER_GROUP_ID}" \
      '[.items[] | select(.id == $id and (.type // "group") == "group")] | length' \
      "${response_file}") || {
      printf 'Could not read the group member response.\n' >&2
      return 2
    }
    [ "${found}" -eq 0 ] || return 0
    [ "${size}" -ne 0 ] || return 1
    start=$((start + size))
  done
}

check_env
umask 077
temporary_directory=$(mktemp -d)
trap 'rm -rf "${temporary_directory}"' EXIT
response_file="${temporary_directory}/members.json"

echo "Authenticating with Viya..."
VIYA_TOKEN="$(get_viya_token)"
auth=(-H "Authorization: Bearer ${VIYA_TOKEN}" -H "Accept: application/json")
parent_id=$(jq -rn --arg id "${PARENT_GROUP_ID}" '$id | @uri')
member_id=$(jq -rn --arg id "${MEMBER_GROUP_ID}" '$id | @uri')
group_exists "${parent_id}"
group_exists "${member_id}"

membership_state=0
is_member || membership_state=$?
[ "${membership_state}" != "2" ] || die "Could not verify current group membership."

method=PUT
expected_state=0
if [ -n "${REMOVE}" ]; then
  method=DELETE
  expected_state=1
fi
if [ "${membership_state}" == "${expected_state}" ]; then
  echo "Group membership already has the requested state."
  exit 0
fi

url="${VIYA_URL}/identities/groups/${parent_id}/groupMembers/${member_id}"
if [ -n "${DRY_RUN}" ]; then
  printf 'DRY RUN: %s %s\n' "${method}" "${url}"
  exit 0
fi
status=$(curl -ksS -o /dev/null -w "%{http_code}" -X "${method}" \
  "${url}" "${auth[@]}") || die "Group membership request failed."
[[ "${status}" =~ ^2[0-9][0-9]$ ]] ||
  die "Group membership request returned HTTP ${status}."

verify_state=0
is_member || verify_state=$?
[ "${verify_state}" == "${expected_state}" ] ||
  die "Could not verify group membership after HTTP ${status}."
echo "Group membership updated and verified."
if [ -z "${REMOVE}" ]; then
  printf "Check that a new administrator login token contains '%s' in its authorities claim.\n" \
    "${PARENT_GROUP_ID}"
fi
