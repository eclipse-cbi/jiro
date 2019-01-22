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
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

yml_source="${1:-}"
template="${2:-}"
config="${3:-}"
partials="${4:-}"

if [[ -z ${yml_source} ]]; then
  echo "ERROR: must give an non-empty yaml source file name" >&2
  exit 1
fi

if [[ -z ${template} ]]; then
  echo "ERROR: must give an template file" >&2
  exit 1
fi

if [[ ! -f "${template}" ]]; then
  echo "ERROR: no file exist '${template}'" >&2
  exit 1
fi

tmp=$(mktemp)

if [[ -f "${yml_source}" ]]; then
  yq m -a "${yml_source}" "${template}" > "${tmp}"
elif [[ -f "${yml_source}.override" ]]; then
  cp "${yml_source}.override" "${tmp}"
else 
  cp "${template}" "${tmp}"
fi

echo "# GENERATED FILE - DO NOT EDIT"
if [[ ! -z "${partials}" ]]; then
  hbs -s -D "${config}" -e gen -P $(dirname "${template}")'/partials/*.hbs' -P "${partials}"'/*.hbs' "${tmp}"
else
  hbs -s -D "${config}" -e gen -P $(dirname "${template}")'/partials/*.hbs' "${tmp}"
fi

rm "${tmp}"