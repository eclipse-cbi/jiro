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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

. "${SCRIPT_FOLDER}/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"

scc_tmp="$(mktemp)"

question() {
  local message="${1:-}"
  local action="${2:-}"
  read -rp "Do you want to ${message}? (Y)es, (N)o, E(x)it: " yn
  case $yn in
    [Yy]* ) ${action};;
    [Nn]* ) return ;;
    [Xx]* ) exit 0;;
        * ) echo "Please answer (Y)es, (N)o, E(x)it"; question "${message}" "${action}";
  esac
}

apply_scc() {
  oc apply -f "${scc_tmp}"
}

update_scc(){
  SHORTNAME="${instance##*.}"
  if oc get scc restricted-v2-selinux-scc -o json | jq -r '.users[]' | grep "${SHORTNAME}:${SHORTNAME}" > /dev/null; then 
    echo "SCC already contains user for project ${SHORTNAME}. Skipping..."
  else
    echo "Update SCC for project ${SHORTNAME}"
    oc get scc restricted-v2-selinux-scc -o json | jq ".users += [\"system:serviceaccount:${SHORTNAME}:${SHORTNAME}\"]" > "${scc_tmp}"
    jq '.users[]' "${scc_tmp}"
    question "apply the changes to the SCC" apply_scc
  fi
}

update_scc

oc apply -f "${instance}/target/k8s/namespace.json"

oc apply -f "${instance}/target/k8s/configmap-jenkins-config.yml"

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
if [[ -f "${instance}/target/.secrets/k8s/sbt-secret-dir.json" ]]; then
  oc apply -f "${instance}/target/.secrets/k8s/sbt-secret-dir.json"
fi

"${SCRIPT_FOLDER}/gen-dockerconfig-secrets.sh" "${instance}"

sts_as_json() {
  oc get sts -n "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")" -o json
}

old_gen=""
if sts_as_json &> /dev/null; then
  old_gen=$(sts_as_json | jq -r '.metadata.generation')
fi

oc apply -f "${instance}/target/k8s/statefulset.json"

if [[ -z "${old_gen}" ]]; then
  echo "INFO: Deploying a brand new instance..."
elif [[ $(sts_as_json | jq -r '.metadata.generation') -gt ${old_gen} ]]; then
  echo "INFO: Cluster is rolling out StatefulSet changes"
#  "${SCRIPT_FOLDER}/../jenkins-switch-maintenance.sh" "${instance}" "on"
  echo -n "Waiting for Jenkins to be back online"
  kubectl rollout status -n "$(jq -r '.metadata.name' "${instance}/target/k8s/namespace.json")" "sts/$(jq -r '.metadata.name' "${instance}/target/k8s/statefulset.json")"
#  "${SCRIPT_FOLDER}/../jenkins-switch-maintenance.sh" "${instance}" "off"
else
  echo "INFO: StatefulSet has no change that Kubernetes consider as requiring a restart"
  ## TODO: compare pod .status.containerStatuses[].imageID vs latest pull from docker registry and check if restart is required.
  "${SCRIPT_FOLDER}/../jenkins-safe-restart.sh" "${instance}" || :
fi

echo "Access: $(jq -r '.deployment.url' "${instance}/target/config.json")"
