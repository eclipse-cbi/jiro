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

JQ_PROG=$(cat <<'EOM'
.jenkins.permissions | group_by(.principal) |
  map( {
    principal: map(.principal) | unique | .[0],
    permissions:
      ((map(reduce (.grantedPermissions) as $x (null; . + $x?)) | flatten | unique | map(select(. != null)))
      -
      (map(reduce (.withheldPermissions) as $x (null; . + $x?)) | flatten | unique | map(select(. != null))))
  } )
EOM
)

for permObject in $(jq -c "${JQ_PROG} | .[]" "${json}"); do
  principal=$(jq -r .principal <<< "${permObject}")
  if [[ "${principal}" == *@* ]] || [[ "${principal}" == "anonymous" ]]; then
    echo "  - user:"
  else
    echo "  - group:"
  fi
  echo "      name: ${principal}"
  echo "      permissions:"
  for perm in $(jq -r '.permissions[]' <<< "${permObject}"); do
    echo "       - ${perm}"
  done
done
