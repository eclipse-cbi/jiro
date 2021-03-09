#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generates SBT settings file from credentials in password store 

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ ! -f "${SCRIPT_FOLDER}/../.localconfig" ]]; then
  echo "ERROR: File '$(readlink -f "${SCRIPT_FOLDER}/../.localconfig")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi"}}'
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${SCRIPT_FOLDER}/../.localconfig")"
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
SBT_FOLDER="$(dirname "${CONFIG}")/.secrets/sbt"

gen_properties() {
  local properties="${1}"
  for key in $(jq -r '. | keys[]' <<<"${properties}"); do
    if jq -e '.["'"${key}"'"] | has("pass")' <<<"${properties}" 2>/dev/null; then 
      local value value_pass
      value="$(jq -r '.["'"${key}"'"].pass' <<< "${properties}")"
      if [[ -f "${PASSWORD_STORE_DIR}/${value}.gpg" ]]; then
        value_pass="$(pass "${value}")"
        echo "${key}=${value_pass}"
      else
        >&2 echo -e "${SCRIPT_NAME}\tWARNING: no entry in password-store for key '${key}'"
      fi
    else
      value="$(jq -r '.["'"${key}"'"]' <<< "${properties}")"
      echo "${key}=${value}"
    fi
  done
}

if [[ "$(jq -r '.sbt.generate' "${CONFIG}")" == "true" ]]; then
  mkdir -p "${SBT_FOLDER}"
  for sbtFile in $(jq -r '.sbt.files | keys[]' "${CONFIG}"); do
    >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating sbt file ${sbtFile}"
    mkdir -p "$(dirname "${sbtFile}")"
    gen_properties "$(jq -r '.sbt.files["'"${sbtFile}"'"]' "${CONFIG}")" > "${SBT_FOLDER}/${sbtFile}"
  done
fi