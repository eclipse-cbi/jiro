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


stsName="$(jq -r '.kubernetes.master.stsName' "${instance}/target/config.json")"
ns="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"

. "${SCRIPT_FOLDER}/build/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"
kubectl rollout restart -n "${ns}" "sts/${stsName}"
kubectl rollout status -n "${ns}" "sts/${stsName}"
