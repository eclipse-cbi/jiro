#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************


set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi"}}' | jq -M
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
export PASSWORD_STORE_DIR

INSTANCE="${1:-}"
JIRO="${INSTANCE}/jiro.jsonnet"

if [ -z "${INSTANCE}" ]; then
  echo "ERROR: you must provide an 'INSTANCE' name argument"
  exit 1
fi

if [ ! -d "${INSTANCE}" ]; then
  echo "ERROR: no 'INSTANCE' at '${INSTANCE}'"
  exit 1
fi

check_pass_exist() {
  local entryPath="${1}"
  if [[ ! -f "${PASSWORD_STORE_DIR}/${entryPath}.gpg" ]]; then 
    >&2 echo "ERROR: Cannot find entry in pass '${entryPath}'"
    exit 3
  fi
}

server_auth() {
  local server="${1}"

  local usernamePass passwordPass
  usernamePass="$(jq -r '.username.pass' <<<"${server}")"
  check_pass_exist "${usernamePass}"
  passwordPass="$(jq -r '.password.pass' <<<"${server}")"
  check_pass_exist "${passwordPass}"
  
  local username password
  username="$(pass "${usernamePass}")"
  password="$(pass "${passwordPass}")"
  cat <<EOL
    "username": "${username}",
    "password": "${password}",
    "auth": "$(tr -d '\n' <<<"${username}:${password}" | base64)"
EOL
}

dockerconfigjson() {
  local secretConfig="${1}"
  local serverUrl
  echo '{"auths":{'
  for serverUrl in $(jq -r '.servers | keys[]' <<<"${secretConfig}"); do
    printf '"%s": {' "${serverUrl}"
    server_auth "$(jq -r '.servers["'"${serverUrl}"'"]' <<<"${secretConfig}")"
    echo "},"
  done
  echo "}}"
}

deploy_secret() {
  local secretName="${1}"
  local secretConfig="${2}"

  local serviceAccount namespace
  serviceAccount="$(jq -r '.serviceAccount' <<<"${secretConfig}")"
  namespace="$(jq -r '.namespace' <<<"${secretConfig}")"
  
  >&2 echo "INFO: Generating and deploying dockerconfigjson secrets '${secretName}'"

  # See https://docs.okd.io/latest/openshift_images/managing_images/using-image-pull-secrets.html#images-allow-pods-to-reference-images-from-secure-registries_using-image-pull-secrets
  oc create secret generic "${secretName}" -n "${namespace}" \
    --from-file=.dockerconfigjson=/dev/stdin \
    --type=kubernetes.io/dockerconfigjson \
    --dry-run=client -o yaml <<<"$(dockerconfigjson "${secretConfig}" | jsonnet -)" \
  | kubectl apply -f -
  
  local type
  type="$(jq -r '.type | join(",")' <<<"${secretConfig}")"
  oc secrets link "${serviceAccount}" "${secretName}" -n "${namespace}" --for="${type}"
}

. "${SCRIPT_FOLDER}/k8s-set-context.sh" "$(jsonnet "${JIRO}" | jq -r '.["config.json"].deployment.cluster')"

for SECRET_NAME in $(jsonnet "${JIRO}" | jq -cr '.["config.json"].secrets.dockerconfigjson | keys[]'); do
  deploy_secret "${SECRET_NAME}" "$(jsonnet "${JIRO}" | jq '.["config.json"].secrets.dockerconfigjson["'"${SECRET_NAME}"'"]')"
done