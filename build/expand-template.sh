#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
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

config="${1:-}"
template="${2:-"-"}"

if [[ -z "${config}" ]]; then
  echo "ERROR: you must provide a json config file"
  exit 1
fi

templateFile="$(mktemp)"
if [[ "${template}" = "-" ]]; then
  cat - > "${templateFile}"
else
  echo "${template}" > "${templateFile}"
fi
hbs -s -D "${config}" "${templateFile}"
rm "${templateFile}"