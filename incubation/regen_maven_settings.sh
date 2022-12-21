#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
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
#script_name="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ "${#}" -eq 0 ]]; then
  echo "ERROR: you must provide at least one 'instance' path"
  exit 1
fi

instance="${1:-}"
project_name="$(basename "${instance}")"
echo "${project_name}:"

"${SCRIPT_FOLDER}/../build/gen-config.sh" "${instance}"
"${SCRIPT_FOLDER}/../build/gen-jenkins.sh" "${instance}"
"${SCRIPT_FOLDER}/../build/gen-k8s.sh" "${instance}"

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
