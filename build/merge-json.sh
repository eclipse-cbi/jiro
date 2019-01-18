#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
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

json1="${1:-"{}"}"
json2="${2:-"{}"}"
out="${3:-/dev/stdout}"

if [[ "${out}" != "${json1}" ]] && [[ "${out}" != "${json2}" ]]; then
  tmp="${out}"
else
  tmp=$(mktemp)
fi

if [[ -f "${json1}" ]]; then
  if [[ -f "${json2}" ]]; then
    jq -s '.[0] * .[1]' "${json1}" "${json2}" > "${tmp}"
  else
    (cat "${json1}"; echo "${json2}") | jq -s '.[0] * .[1]' > "${tmp}"
  fi
else 
  if [[ -f "${json2}" ]]; then
    (echo "${json1}"; cat "${json2}") | jq -s '.[0] * .[1]' > "${tmp}"
  else
    (echo "${json1}"; echo "${json2}") | jq -s '.[0] * .[1]' > "${tmp}"
  fi
fi

if [[ "${out}" = "${json1}" ]] || [[ "${out}" = "${json2}" ]]; then
  mv "${tmp}" "${out}"
fi