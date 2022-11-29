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
timeout_sec="${2:-180}"

if [[ -z "${instance}" ]]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

if [[ "${timeout_sec}" =~ ^?[0-9]+$ ]]; then
  echo "ERROR: timeout must be a valid integer"
fi

stsName="$(jq -r '.kubernetes.master.stsName' "${instance}/target/config.json")"
ns="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"
url="$(jq -r '.deployment.url' "${instance}/target/config.json")"

runningBuilds() {
  local url="${1}"
  local jenkins_user
  jenkins_user="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "user" "jenkins_login")"
  local jenkins_pw
  jenkins_pw="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "pw" "jenkins_login")"
  curl --retry 10 -gSs --user "${jenkins_user}:${jenkins_pw}" "${url}"'/computer/api/json?depth=2&tree=computer[displayName,executors[currentExecutable[*]],oneOffExecutors[currentExecutable[*]]]' | jq -c '.computer | map({name: .displayName?, executors: (.executors? + .oneOffExecutors?) | map(select(.currentExecutable != null)) | map(.currentExecutable | {name: .fullDisplayName, url: .url}) })'
}

echo "INFO: Safe restarting Jenkins @ ${url}"
echo "INFO: Putting Jenkins instance in quiet mode"
"${SCRIPT_FOLDER}/jenkins-cli.sh" "${instance}" quiet-down || :

builds=$(runningBuilds "${url}")
buildsCount=$(echo "${builds}" | jq -r 'map(.executors[]) | length')
if [[ "${buildsCount}" -gt 0 ]]; then
  echo "INFO: There are still ${buildsCount} builds running:"
  echo "${builds}" | jq -r 'map(.executors[].name)[]'
  echo -n "INFO: Waiting for builds to complete (timeout=${timeout_sec}s)"

  startTime=$(date +%s)
  while [[ "${buildsCount}" -gt 0 ]]; do
    buildsCount=$(runningBuilds "${url}" | jq -r 'map(.executors[]) | length')
    sleep 10
    if [[ $((startTime + timeout_sec)) -lt $(date +%s) ]]; then
      echo ""
      echo "INFO: Timeout after ${timeout_sec}s, still ${buildsCount} builds running. The following builds will be forcibly terminated"
      runningBuilds "${url}" | jq -r 'map(.executors[].name)[]'
      break
    fi
    echo -n "."
  done

  echo -e "\b."
fi

#"${SCRIPT_FOLDER}/jenkins-switch-maintenance.sh" "${instance}" "on"

#shellcheck disable=SC1091
. "${SCRIPT_FOLDER}/build/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"

echo -n "INFO: Restarting Jenkins"

kubectl rollout restart -n "${ns}" "sts/${stsName}"
kubectl rollout status -n "${ns}" "sts/${stsName}"

#"${SCRIPT_FOLDER}/jenkins-switch-maintenance.sh" "${instance}" "off"

echo "INFO: Jenkins is ready"
