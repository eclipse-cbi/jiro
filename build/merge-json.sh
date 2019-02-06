#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

json1="${1:-"{}"}"
json2="${2:-"{}"}"
out="${3:-/dev/stdout}"

MELD=$(cat <<EOM
def meld(a; b):
  if (a|type) == "object" and (b|type) == "object" then 
    reduce ([a,b]|add|keys_unsorted[]) as \$k (
      {}; .[\$k] = meld( a[\$k]; b[\$k]) 
    )
  elif (a|type) == "array" and (b|type) == "array" then 
    a+b
  elif b == null then 
    a
  else b
end;
EOM
)

if [[ "${out}" != "${json1}" ]] && [[ "${out}" != "${json2}" ]]; then
  tmp="${out}"
else
  tmp=$(mktemp)
fi

if [[ -f "${json1}" ]]; then
  if [[ -f "${json2}" ]]; then
    jq -s "${MELD}"'. as [$a, $b] | meld($a; $b)' "${json1}" "${json2}" > "${tmp}"
  else
    (cat "${json1}"; echo "${json2}") | jq -s "${MELD}"'. as [$a, $b] | meld($a; $b)' > "${tmp}"
  fi
else 
  if [[ -f "${json2}" ]]; then
    (echo "${json1}"; cat "${json2}") | jq -s "${MELD}"'. as [$a, $b] | meld($a; $b)' > "${tmp}"
  else
    (echo "${json1}"; echo "${json2}") | jq -s "${MELD}"'. as [$a, $b] | meld($a; $b)' > "${tmp}"
  fi
fi

if [[ "${out}" = "${json1}" ]] || [[ "${out}" = "${json2}" ]]; then
  mv "${tmp}" "${out}"
fi