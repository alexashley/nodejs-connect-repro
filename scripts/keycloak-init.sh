#!/usr/bin/env bash

set -eu

cd $(dirname "$0")

KEYCLOAK_URI="http://localhost:8080"
REALM_FILE="../keycloak-nodejs-connect/example/nodejs-example-realm.json"
ADMIN_USER="keycloak"
ADMIN_PASSWORD="password"
EXAMPLE_CLIENT="nodejs-connect"
CLIENT_ADMIN_URL="http://example:3000"

function assert_install {
  if ! [[ -x "$(command -v "$1")" ]]; then
    echo "Error: $1 is not installed." >&2
    exit 1
  fi
}

assert_install "curl"
assert_install "jq"

if ! [[ -f "${REALM_FILE}" ]]; then
    echo "Realm file is missing, did you clone the repo with submodules?"
    exit 1
fi

REALM_NAME=$(cat "${REALM_FILE}" | jq -r '.realm')

if [[ $(curl --silent "${KEYCLOAK_URI}/auth/realms/${REALM_NAME}" --output /dev/null -w "%{http_code}") == 200 ]]; then
    echo "${REALM_NAME} realm exists, skipping setup"
    exit 0;
fi

accessToken=$(curl "${KEYCLOAK_URI}/auth/realms/master/protocol/openid-connect/token" \
                --silent \
                -d "grant_type=password" \
                -d "username=${ADMIN_USER}" \
                -d "password=${ADMIN_PASSWORD}" \
                -d "client_id=admin-cli" | jq -r '.access_token')

curl "${KEYCLOAK_URI}/auth/admin/realms" --data "@${REALM_FILE}" -H "Content-Type: application/json" -H "Authorization: Bearer ${accessToken}"

echo "Created ${REALM_NAME}"
