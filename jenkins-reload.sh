#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
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

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

if [[ "${#}" -eq 0 ]]; then
  echo "ERROR: you must provide at least one 'instance' path"
  exit 1
fi

regen() {
  local instance="${1}"
  "${SCRIPT_FOLDER}/build/gen-config.sh" "${instance}"
	"${SCRIPT_FOLDER}/build/gen-jenkins.sh" "${instance}"
	"${SCRIPT_FOLDER}/build/gen-k8s.sh" "${instance}"
}

reload() {
  local instance="${1}"
  local namespace projectShortName
  namespace="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"
  projectShortName="$(jq -r '.project.shortName' "${instance}/target/config.json")"

  local previousConfigMapVersion
  if oc get configmap -n "${namespace}" jenkins-config &> /dev/null; then
    previousConfigMapVersion="$(oc get configmap -n "${namespace}" jenkins-config -o json | jq -r '.metadata.resourceVersion')"
  fi
  oc apply -f "${instance}/target/k8s/configmap-jenkins-config.yml"
  if [[ -n "${previousConfigMapVersion:-}" ]]; then
    local newConfigMapVersion
    newConfigMapVersion="$(oc get configmap -n "${namespace}" jenkins-config -o json | jq -r '.metadata.resourceVersion')"
    if [[ "${previousConfigMapVersion}" != "${newConfigMapVersion}" ]]; then
      local remoteConfig
      remoteConfig=$(mktemp)
      oc rsh -n "${namespace}" "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
      diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" || :
      echo -n "Waiting for the Jenkins CasC config map to be updated on the pod..."
      while ! diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" > /dev/null; do
        sleep 5
        echo -n "."
        oc rsh -n "${namespace}" "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
      done
      echo -e "\n"
      rm -f "${remoteConfig}"
    fi
  fi
  echo "Reloading Jenkins CasC file..."
  "${SCRIPT_FOLDER}/jenkins-cli.sh" "${instance}" "reload-jcasc-configuration" || :
}

for instance in "${@}"; do
  if [[ ! -d "${instance}" ]] || [[ ! -f "${instance}/jiro.jsonnet" ]]; then
    echo "ERROR: no 'instance' at path '${instance}'"
    exit 1
  else 
    echo "INFO: Regenerating and reloading configuration of $(basename "${instance}")"
    regen "${instance}"
    reload "${instance}"
  fi
done
