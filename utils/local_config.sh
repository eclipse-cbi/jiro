#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Access values from local config ("${HOME}/.cbi/config")

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
LOCAL_CONFIG="${HOME}/.cbi/config"

if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the JIRO root dir and the projects-bots-api root dir. Example:"
  echo '{"jiro-root-dir": "/path/to/jiro/rootdir"}'
  echo '{"projects-bots-api-root-dir": "/path/to/projects-bots-api/rootdir"}'
  echo '{"jenkins_login": {"user": "my_user_name", "pw": "password"}}' | jq -M
  exit 1
fi

_check_if_var_exists() {
  local var="${1:-}"
  local key="${2:-}"
  if [[ -z "${var}" ]] || [[ "${var}" == "null" ]]; then
    printf "ERROR: '%s' must be set in %s.\n" "${key}" "${LOCAL_CONFIG}" > /dev/tty
    exit 1
  fi
}

#TODO: show available variables
#"jiro-root-dir"
#"projects-bots-api-root-dir"
#["jenkins_login"]["user"]
#["jenkins_login"]["pw"]

get_var() {
  local key="${1:-}"
  local lcv

  if [[ -z "${key}" ]]; then
    printf "ERROR: 'key' must be set\n" > /dev/tty
    exit 1
  fi

  #TODO: simplify
  # deal with jq's problem with special characters like '-' in keys
  if [[ "${key}" == *"."* ]]; then
    #Split the key by '.'
    readarray -d "." -t key_array <<< "${key}"
    #print the array
    for element in "${key_array[@]}"; do
      #FIXME: readarray -t should already handle that
      element="$(echo "${element}" | tr -d '\n')"
      key_escaped+="\"${element}\"."
    done
    #Remove the last trailing dot '.'
    key_escaped="${key_escaped%.}"
    #DEBUG
    #echo "key_escaped: ${key_escaped}"
  else
    #TODO: improve
    #shellcheck disable=SC2089
    key_escaped="\"${key}\""
  fi
  #TODO: improve
  #shellcheck disable=SC2090,SC2086
  lcv="$(jq -r .${key_escaped} "${LOCAL_CONFIG}")"
  _check_if_var_exists "${lcv}" "${key}"
  echo "${lcv}"
}

get_var "${1:-}"
