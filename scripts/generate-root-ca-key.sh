#!/usr/bin/env bash

set -e

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
OUTPUT_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "${OUTPUT_DIR}"
}

trap cleanup EXIT

export CAROOT="${OUTPUT_DIR}"

cd "${OUTPUT_DIR}"

HOST_IDENTITY_FILE="/etc/ssh/ssh_host_ed25519_key.pub"
USER_IDENTITY_FILE="${HOME}/.ssh/id_ed25519.pub"
AGE="age -R ${HOST_IDENTITY_FILE} -R ${USER_IDENTITY_FILE}"

echo ":: Generating a new root CA key..."

mkcert localhost

rm localhost*.pem

${AGE} "${OUTPUT_DIR}"/rootCA-key.pem >"${ROOT}"/secrets/rootCA-key.pem.age
${AGE} "${OUTPUT_DIR}"/rootCA.pem >"${ROOT}"/secrets/rootCA.pem.age

cd "${ROOT}/secrets"

echo ":: Re-encrypting all keys"

agenix -r

rm -rf "${OUTPUT_DIR}"

echo ":: Done!"
