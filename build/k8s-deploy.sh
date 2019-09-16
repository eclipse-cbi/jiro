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

namespace="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"
projectShortName="$(jq -r '.project.shortName' "${instance}/target/config.json")"

oc apply -f "${instance}/target/k8s/namespace.yml"

if oc get configmap -n "${namespace}" jenkins-config &> /dev/null; then
  previousConfigMapVersion="$(oc get configmap -n "${namespace}" jenkins-config -o json | jq -r '.metadata.resourceVersion')"
fi
oc apply -f "${instance}/target/k8s/configmap-jenkins-config.yml"
if [[ -n "${previousConfigMapVersion:-}" ]]; then
  newConfigMapVersion="$(oc get configmap -n "${namespace}" jenkins-config -o json | jq -r '.metadata.resourceVersion')"
  if [[ "${previousConfigMapVersion}" != "${newConfigMapVersion}" ]]; then
    remoteConfig=$(mktemp)
    oc rsh -n "${namespace}" "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
    diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" || :
    echo -n "Waiting for the Jenkins CasC config map to be updated on the pod..."
    while ! diff -Z -B "${remoteConfig}" "${instance}/target/jenkins/configuration.yml" > /dev/null; do
      sleep 5
      echo -n "."
      oc rsh -n "${namespace}" "${projectShortName}-0" cat "/etc/jenkins/jenkins.yaml" > "${remoteConfig}"
    done
    echo -e "\nReloading Jenkins CasC file..."
    "${SCRIPT_FOLDER}/../jenkins-cli.sh" "${instance}" "reload-jcasc-configuration" || :
    rm "${remoteConfig}"
  fi
fi

oc apply -f "${instance}/target/k8s/role.yml"
oc apply -f "${instance}/target/k8s/service-account.yml"
oc apply -f "${instance}/target/k8s/limit-range.yml"
oc apply -f "${instance}/target/k8s/resource-quotas.yml"
oc apply -f "${instance}/target/k8s/role-binding.yml"
oc apply -f "${instance}/target/k8s/service-jenkins-ui.yml"
oc apply -f "${instance}/target/k8s/service-jenkins-discovery.yml"
oc apply -f "${instance}/target/k8s/route.yml"
oc apply -f "${instance}/target/k8s/tools-pv.yml"
oc apply -f "${instance}/target/k8s/known-hosts.yml"
oc apply -f "${instance}/target/k8s/m2-dir.yml"

oc apply -f "${instance}/target/k8s/statefulset.yml"