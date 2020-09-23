#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Delete instance

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

echo "Warning: you are about to delete ${instance}. This may result in data loss."
echo "To confirm that you know what you're doing, please type in the path to the"
echo "instance (relative to current directory) you would like to remove."

read -rp "Instance path: " confirm

if [[ "$(readlink -f "${confirm}")" == "$(readlink -f "${instance}")" ]]; then
  echo "Deleting ${instance}..."
  . "${SCRIPT_FOLDER}/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"
  oc delete -f "${instance}/target/k8s/namespace.yml"
else
  echo "Cannot delete, $(readlink -f "${confirm}") != $(readlink -f "${instance}")"
fi
