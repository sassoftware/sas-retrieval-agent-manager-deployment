#!/usr/bin/env bash

# This script applies realm updates to a Keycloak server using the Keycloak Admin CLI (kcadm.sh).
# It reads admin credentials from mounted Kubernetes secrets and uses an ephemeral work directory
# for storing the kcadm.sh configuration file.
# It is intended to be run as part of a Kubernetes Job within a Helm chart deployment, and will
# execute realm updates defined in additional scripts or commands after authentication. Any
# script present in the /updates directory with the suffix "-update.sh" will be executed.

set -e -o pipefail -o nounset

shopt -s nullglob

script_pattern="/updates/*-update.sh"
targets=( $script_pattern )

if [ ${#targets[@]} -eq 0 ]; then
  echo "No update scripts found. Skipping realm updates."
  exit 0
fi

# Consume mounted secrets for Keycloak admin credentials.
if [ -f /admin/username ]; then
  KEYCLOAK_USER=$(cat /admin/username)
  export KEYCLOAK_USER
fi

if [ -f /admin/password ]; then
  KEYCLOAK_PASSWORD=$(cat /admin/password)
  export KEYCLOAK_PASSWORD
fi

# Verify that kcadm.sh exists.
if [ -f /opt/keycloak/bin/kcadm.sh ]; then
  KCADM_SH="/opt/keycloak/bin/kcadm.sh"
else
  echo "kcadm.sh not found in /opt/keycloak/bin/"
  exit 1
fi

# Verify required environment variables are set.
if [ -z "${KEYCLOAK_USER:-}" ] || [ -z "${KEYCLOAK_PASSWORD:-}" ]; then
  echo "KEYCLOAK_USER and KEYCLOAK_PASSWORD environment variables must be set."
  exit 1
fi

if [ -z "${KCADM_CFG_PATH}" ] || [ -z "${KEYCLOAK_URL}" ] || [ -z "${KEYCLOAK_REALM:-}" ]; then
  echo "KCADM_CFG_PATH, KEYCLOAK_URL, and KEYCLOAK_REALM environment variables must be set."
  exit 1
fi

# Authenticate with Keycloak and persist configuration to ephemeral work directory.
"${KCADM_SH}" config credentials --config "${KCADM_CFG_PATH}" \
  --server "${KEYCLOAK_URL}" --realm master                   \
  --user "${KEYCLOAK_USER}" --password "${KEYCLOAK_PASSWORD}"

# Disable exit on error to allow for custom error handling in update scripts and
# all scripts to run.
set +e

exit_code=0

# Apply realm updates.
for update_script in /updates/*-update.sh; do
  if [ -f "${update_script}" ]; then
    echo "Applying update script: ${update_script}"
    if ! bash "${update_script}"; then
      echo "Error applying update script: ${update_script}"
      exit_code=1
    else
      echo "Successfully applied update script: ${update_script}"
    fi
  fi
done

exit ${exit_code}
