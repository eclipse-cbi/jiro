#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Deploy instance

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

instance="${1:-}"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

# Workaround https://github.com/kubernetes/kubernetes/issues/68573
# Replace with 
# $ oc rollout status sts/dash -n dash -w
# as soon as we run K8S 1.12 or above.
waitReadyReplicas() {
  local ns=${1}
  local stsName=${2}
  local target=${3}

  while [[ $target -ne $(oc get sts "${stsName}" -n "${ns}" -o jsonpath="{.status.readyReplicas}") ]]; do
    sleep 2
    echo -n "."
  done
  echo -e "\b."
}

oc apply -f "${instance}/target/k8s/namespace.json"

"${SCRIPT_FOLDER}/../jenkins-reload.sh" "${instance}" || :

oc apply -f "${instance}/target/k8s/role.json"
oc apply -f "${instance}/target/k8s/service-account.json"
oc apply -f "${instance}/target/k8s/limit-range.json"
oc apply -f "${instance}/target/k8s/resource-quotas.json"
oc apply -f "${instance}/target/k8s/role-binding.json"
oc apply -f "${instance}/target/k8s/service-jenkins-ui.json"
oc apply -f "${instance}/target/k8s/service-jenkins-discovery.json"
oc apply -f "${instance}/target/k8s/route.json"
oc apply -f "${instance}/target/k8s/tools-pv.json"
oc apply -f "${instance}/target/k8s/known-hosts.json"
oc apply -f "${instance}/target/k8s/m2-dir.json"

if [[ -f "${instance}/target/.secrets/k8s/m2-secret-dir.json" ]]; then
  oc apply -f "${instance}/target/.secrets/k8s/m2-secret-dir.json"
fi
if [[ -f "${instance}/target/.secrets/k8s/gradle-secret-dir.json" ]]; then
  oc apply -f "${instance}/target/.secrets/k8s/gradle-secret-dir.json"
fi

sts_as_json() {
  oc get sts -n "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")" -o json
}

old_gen=""
if sts_as_json &> /dev/null; then
  old_gen=$(sts_as_json | jq -r '.metadata.generation')
fi

oc apply -f "${instance}/target/k8s/statefulset.json"

if [[ $(sts_as_json | jq -r '.metadata.generation') -gt ${old_gen} ]]; then
  echo "INFO: Cluster is rolling out StatefulSet changes"
  "${SCRIPT_FOLDER}/../jenkins-switch-maintenance.sh" "${instance}" || :
  echo -n "Waiting for Jenkins to be back online"
  waitReadyReplicas "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")" 1
  "${SCRIPT_FOLDER}/../jenkins-switch-maintenance.sh" "${instance}" || :
else 
  echo "INFO: StatefulSet has no change that Kubernetes consider as requiring a restart"
  ## TODO: compare pod .status.containerStatuses[].imageID vs latest pull from docker registry and check if restart is required.
  "${SCRIPT_FOLDER}/../jenkins-safe-restart.sh" "${instance}" || :
fi
