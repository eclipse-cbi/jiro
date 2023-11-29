#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generate Jenkins permissions

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

json=${1:-}

if [[ ! -f "${json}" ]]; then
  >&2 echo "ERROR: no json file at location '${json}'"
  exit 1
fi

# removes duplicate entries, but does not merge entries
jq -c '.jenkins.permissions | unique' "${json}" | yq -P 'sort_keys(..)' -p json -o yaml -
