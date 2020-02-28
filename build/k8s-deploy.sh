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
  echo ""
}

oc apply -f "${instance}/target/k8s/namespace.json"

"${SCRIPT_FOLDER}/../jenkins-reload-jcasc.sh" "${instance}" || :

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

statefulset_json_old=$(mktemp)
oc get sts -n "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")" -o json > "${statefulset_json_old}"

statefulset_json="${instance}/target/k8s/statefulset.json"

sts_image_jq='.spec.template.spec.containers[].image'
sts_resources_jq='.spec.template.spec.containers[].resources'
sts_annotations_jq='.spec.template.metadata.annotations'
if [[ "$(jq -r "${sts_image_jq}" "${statefulset_json}")" == "$(jq -r "${sts_image_jq}" "${statefulset_json_old}")" ]] || \
   [[ "$(jq -r "${sts_resources_jq}" "${statefulset_json}")" == "$(jq -r "${sts_resources_jq}" "${statefulset_json_old}")" ]] || \
   [[ "$(jq -r "${sts_annotations_jq}" "${statefulset_json}")" == "$(jq -r "${sts_annotations_jq}" "${statefulset_json_old}")" ]]; then
   oc apply -f "${statefulset_json}"
   echo "Cluster does not rollout StatefulSet changes when container images, resource requests and/or limits, labels, and annotations of the Pods in a StatefulSet are identical to the deployed one. Forcing safe restart now!"
  "${SCRIPT_FOLDER}/../jenkins-safe-restart.sh" "${instance}" || :
else 
  "${SCRIPT_FOLDER}/jenkins-switch-maintenance.sh" "${instance}" || :
  oc apply -f "${statefulset_json}"
  echo "Cluster is rolling out StatefulSet changes"
  waitReadyReplicas "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")" 1
fi

rm -f "${statefulset_json_old}"

