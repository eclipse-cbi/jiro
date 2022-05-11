#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generates Gradle settings file from credentials in password store 

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi"}}'
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
export PASSWORD_STORE_DIR

INSTANCE="${1:-}"

if [ -z "${INSTANCE}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${INSTANCE}" ]; then
  echo "ERROR: no 'instance' at '${INSTANCE}'"
  exit 1
fi

CONFIG="${INSTANCE}/target/config.json"
GRADLE_FOLDER="$(dirname "${CONFIG}")/.secrets/gradle"

gen_properties() {
  local properties="${1}"
  for key in $(jq -r '. | keys[]' <<<"${properties}"); do
    local value value_pass
    value="$(jq -r '.["'"${key}"'"].pass' <<< "${properties}")"
    if [[ -f "${PASSWORD_STORE_DIR}/${value}.gpg" ]]; then
      value_pass="$(pass "${value}")"
      echo "${key}=${value_pass}"
    else
      >&2 echo -e "${SCRIPT_NAME}\tWARNING: no entry in password-store for key '${key}'"
    fi
  done
}

if [[ "$(jq -r '.gradle.generate' "${CONFIG}")" == "true" ]]; then
  mkdir -p "${GRADLE_FOLDER}"
  for gradleFile in $(jq -r '.gradle.files | keys[]' "${CONFIG}"); do
    >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Gradle file ${gradleFile}"
    mkdir -p "$(dirname "${gradleFile}")"
    gen_properties "$(jq -r '.gradle.files["'"${gradleFile}"'"]' "${CONFIG}")" > "${GRADLE_FOLDER}/${gradleFile}"
  done
fi