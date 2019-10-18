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
oc apply -f "${instance}/target/k8s/tools-pv.yml"
oc apply -f "${instance}/target/k8s/known-hosts.yml"
oc apply -f "${instance}/target/k8s/m2-dir.yml"

oc apply -f "${instance}/target/k8s/statefulset.yml"