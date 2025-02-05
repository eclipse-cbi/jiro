#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Mass update Jenkins plugins

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

LOG_FOLDER="${SCRIPT_FOLDER}/update_plugin_log"
mkdir -p "${LOG_FOLDER}"

STILL_RUNNING_QUEUE="${LOG_FOLDER}/instances_still_running_builds.txt"

runningBuilds() {
  local url="${1}"
  local jenkins_user
  jenkins_user="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "user" "jenkins_login")"
  local jenkins_pw
  jenkins_pw="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "pw" "jenkins_login")"
  local numberOfRunningBuilds
  numberOfRunningBuilds="$(curl --retry 10 -gSs --user "${jenkins_user}:${jenkins_pw}" "${url}"'/computer/api/json' | jq -c '.busyExecutors')"
  echo "${numberOfRunningBuilds}"
}

no_of_processes=2
for instance in "${@}"; do
  while [ "$(jobs | wc -l)" -ge ${no_of_processes} ] ; do sleep 1 ; done
  project_name="$(basename "${instance}")"
  printf "%s" "${project_name}: "

  url="$(jq -r '.deployment.url' "${instance}/target/config.json")"

  buildsCount=$(runningBuilds "${url}")
  if [[ "${buildsCount}" -gt 0 ]]; then
    echo "There are still ${buildsCount} builds running!"
    echo "${project_name}" >> "${STILL_RUNNING_QUEUE}"
    continue
  fi

  echo "Update!"
  "${SCRIPT_FOLDER}/../jenkins-cli.sh" "${instance}" "groovy" "=" < "${SCRIPT_FOLDER}/../groovy/cli/update-jenkins-plugins.groovy" &> "${LOG_FOLDER}/${project_name}.log" &
done