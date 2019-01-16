#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

instance="${1:-}"
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

. "${instance}/target/config.properties"

oc apply -f ${instance}/target/k8s/namespace.yml
oc apply -f ${instance}/target/k8s/configmap-jenkins-config.yml
oc apply -f ${instance}/target/k8s/role.yml
oc apply -f ${instance}/target/k8s/service-account.yml
oc apply -f ${instance}/target/k8s/limit-range-default.yml
oc apply -f ${instance}/target/k8s/limit-range.yml
oc apply -f ${instance}/target/k8s/resource-quotas.yml
oc apply -f ${instance}/target/k8s/role-binding.yml
oc apply -f ${instance}/target/k8s/service-jenkins-ui.yml
oc apply -f ${instance}/target/k8s/service-jenkins-discovery.yml
oc apply -f ${instance}/target/k8s/route.yml

oc create secret generic "jenkins-secrets" -n ${JENKINS_NAMESPACE} 2> /dev/null || true

sleep 5
${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" "reload-jcasc-configuration" 2> /dev/null || true
oc apply -f ${instance}/target/k8s/statefulset.yml