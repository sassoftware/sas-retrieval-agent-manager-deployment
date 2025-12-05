#!/usr/bin/env bash

set -e -o pipefail -o nounset

function set_signing_algo() {
  /opt/keycloak/bin/kcadm.sh update clients/"${client_id}"     \
    -r "${KEYCLOAK_REALM}" --config "${KCADM_CFG_PATH}"        \
    -s 'attributes."access.token.signed.response.alg"="RS256"' \
    -s 'attributes."id.token.signed.response.alg"="RS256"'
}


client_id=$(/opt/keycloak/bin/kcadm.sh get clients -r "${KEYCLOAK_REALM}" \
  -q "clientId=${RAM_APP_CLIENT}" --fields id,clientId --format csv \
  --config "${KCADM_CFG_PATH}" | cut -d',' -f1 | sed 's/"//g')

if [ -z "$client_id" ]; then
  echo "Client '${RAM_APP_CLIENT}' not found in realm '${KEYCLOAK_REALM}'."
  exit 1
fi

export client_id

echo "Setting signing algorithms for client '${RAM_APP_CLIENT}'..."
set_signing_algo
