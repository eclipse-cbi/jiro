#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generate Nexus Pro token

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ $# -ne 4 ]]; then
  echo "ERROR: ${SCRIPT_NAME} requires 4 arguments"
  exit 1
fi

cmd="${1}"
nexusProUrl="${2}"
username="${3}"
password="${4}"

commonCurlOpts='header = "Accept: application/json"\nheader = "Content-Type: application/json"'
# Passing 'user = "u:p"' to curl -K- with heredoc, must escape '\' and '"'
escapedPassword="$(printf "%s" "${password}" | sed -e 's/\\/\\\\\\\\/g' | sed -e 's/"/\\"/g')"
basicAuth="$(printf 'user = "%s:%s"' "${username}" "${escapedPassword}")"
curlOpts="${commonCurlOpts}\n${basicAuth}"

_authTicket() {
  local payload
  payload='{"u":"'$(printf "%s" "${username}" | base64)'","p":"'$(printf "%s" "${password}" | base64)'"}'
  local out
  out="$(mktemp)"
  local status
  status="$(curl -sSL -X POST -o "${out}" -w "%{http_code}" -K- --data "${payload}" "${nexusProUrl}/service/siesta/wonderland/authenticate" <<< "$(echo -e "${curlOpts}")")"
  if [[ "${status}" -ge 400 ]]; then
    >&2 echo "ERROR: unable to retrieve authentication ticket at ${nexusProUrl} (status=${status})"
    exit 1
  fi
  jq -r '.t' "${out}" && rm -f "${out}"
}

get_or_create() {
  local out
  out="$(mktemp)"
  local status
  status="$(curl -sSL -K- -o "${out}" -w "%{http_code}" -H "X-NX-AuthTicket: $(_authTicket)" "${nexusProUrl}/service/siesta/usertoken/current" <<< "$(echo -e "${curlOpts}")")"
  if [[ "${status}" -ge 400 ]]; then
    >&2 echo "ERROR: unable to retrieve user token at ${nexusProUrl} (status=${status})"
    exit 1
  fi
  jq -cM '.' "${out}" && rm -f "${out}"
}

delete() {
  local status
  status="$(curl -X DELETE -sSL -K- -w "%{http_code}" -o /dev/null -H "X-NX-AuthTicket: $(_authTicket)" "${nexusProUrl}/service/siesta/usertoken/current" <<< "$(echo -e "${curlOpts}")")"
  if [[ "${status}" -ge 400 ]]; then
    >&2 echo "ERROR: unable to delete user token at ${nexusProUrl} (status=${status})"
    exit 1
  fi
}

${cmd}