#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

# Need pass
if ! command -v pass > /dev/null; then
  >&2 echo "ERROR: this program requires 'pass'"
  exit 1
fi

# Need readlink
if ! command -v readlink > /dev/null; then
  >&2 echo "ERROR: this program requires 'readlink'"
  exit 1
fi

LOCAL_CONFIG="${HOME}/.cbi/config"

if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi",'
  echo '                    "it-dir": "~/.password-store/it"}}'
fi

passw() {
  local store="${1:-}"
  if [ "${store}" != "cbi" ] && [ "${store}" != "it" ]; then
    printf "ERROR: only 'cbi' and 'it' are valid values.\n"
    exit 1
  fi
  # backup env variable
  local backup_pw_store_dir
  if [[ ! -z "${PASSWORD_STORE_DIR:-}" ]]; then
    backup_pw_store_dir="${PASSWORD_STORE_DIR}"
  fi

  local PASSWORD_STORE_DIR
  PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["'"${store}"'-dir"]' "${LOCAL_CONFIG}")"

  if [[ -z "${PASSWORD_STORE_DIR}" ]] || [[ "${PASSWORD_STORE_DIR}" == "null" ]]; then
    printf "ERROR: '${store}-dir' must be set in %s.\n" "$(readlink -f "${LOCAL_CONFIG}")"
    exit 1
  fi

  PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
  export PASSWORD_STORE_DIR

  local exitCode=0
  if ! pass "${@:2}"; then
    >&2 echo "ERROR: pass entry not found - " "${@:2}" "in store $store"
    exitCode=1
  fi

  # reset env variable
  if [[ ! -z "${backup_pw_store_dir:-}" ]]; then
    PASSWORD_STORE_DIR="${backup_pw_store_dir}"
    export PASSWORD_STORE_DIR
  else
    unset PASSWORD_STORE_DIR
  fi

  return ${exitCode}
}
