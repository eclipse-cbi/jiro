#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
#script_name="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

STILL_RUNNING_QUEUE="instances_still_running_builds.txt"
#> "${STILL_RUNNING_QUEUE}"

DEPLOY_LOG_FOLDER="${SCRIPT_FOLDER}/deploy_log"
mkdir -p "${DEPLOY_LOG_FOLDER}"

runningBuilds() {
  local url="${1}"
  curl --retry 10 -gSs --user "$(cat "${SCRIPT_FOLDER}"/../.jenkinscreds)" "${url}"'/computer/api/json?depth=2&tree=computer[displayName,executors[currentExecutable[*]],oneOffExecutors[currentExecutable[*]]]' | jq -c '.computer | map({name: .displayName?, executors: (.executors? + .oneOffExecutors?) | map(select(.currentExecutable != null)) | map(.currentExecutable | {name: .fullDisplayName, url: .url}) })'
}

no_of_processes=2
for instance in "${@}"; do
  while [ "$(jobs | wc -l)" -ge ${no_of_processes} ] ; do sleep 1 ; done
  project_name="$(basename "${instance}")"
  printf "%s: " "${project_name}"
  
  url="$(jq -r '.deployment.url' "${instance}/target/config.json")"
  
  builds=$(runningBuilds "${url}")
  buildsCount=$(echo "${builds}" | jq -r 'map(.executors[]) | length')
  if [[ "${buildsCount}" -gt 0 ]]; then
    echo "There are still ${buildsCount} builds running!"
    echo "${project_name}" >> "${STILL_RUNNING_QUEUE}"
    continue
  fi
  echo "deploy!"
  make -C "${SCRIPT_FOLDER}/.." "deploy_${project_name}" &> "${DEPLOY_LOG_FOLDER}/${project_name}.log" &
done
