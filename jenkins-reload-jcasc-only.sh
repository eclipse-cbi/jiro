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

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ "${#}" -eq 0 ]]; then
  echo "ERROR: you must provide at least one 'instance' path"
  exit 1
fi

reload() {
  local instance="${1}"
  local projectShortName
  local configjson="${instance}/target/config.json"
  projectShortName="$(jq -r '.project.shortName' "${instance}/target/config.json")"
  projectFullName="$(jq -r '.project.fullName' "${instance}/target/config.json")"

  . "${SCRIPT_FOLDER}/build/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"

  local previousConfigMapVersion
  if "${SCRIPT_FOLDER}/build/kubectlw" -p "${projectFullName}" -- get configmap jenkins-config &> /dev/null; then
    previousConfigMapVersion="$("${SCRIPT_FOLDER}/build/kubectlw" -p "${projectFullName}" -- get configmap jenkins-config -o json | jq -r '.metadata.resourceVersion')"
  fi
  "${SCRIPT_FOLDER}/build/kubectlw" -p "${projectFullName}" -- apply -f "${instance}/target/k8s/configmap-jenkins-config.yml"
  if [[ -n "${previousConfigMapVersion:-}" ]]; then
    local newConfigMapVersion
    newConfigMapVersion="$("${SCRIPT_FOLDER}/build/kubectlw" -p "${projectFullName}" -- get configmap jenkins-config -o json | jq -r '.metadata.resourceVersion')"
    if [[ "${previousConfigMapVersion}" != "${newConfigMapVersion}" ]]; then
      local remoteConfig
      remoteConfig=$(mktemp)
      "${SCRIPT_FOLDER}/build/ocw" -p "${projectFullName}" -- rsh "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
      diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" || :
      echo -n "Waiting for the Jenkins CasC config map to be updated on the pod..."
      while ! diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" > /dev/null; do
        sleep 5
        echo -n "."
        "${SCRIPT_FOLDER}/build/ocw" -p "${projectFullName}" -- rsh "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
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
    echo "INFO: Reloading configuration of $(basename "${instance}")"
    reload "${instance}"
  fi
done
