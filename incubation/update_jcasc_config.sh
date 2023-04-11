#!/usr/bin/env bash

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

log_file="jcasc_update.log"
# shellcheck disable=SC2188
>${log_file}

regen() {
  local instance="${1:-}"
  "${SCRIPT_FOLDER}/../build/gen-config.sh" "${instance}"
  "${SCRIPT_FOLDER}/../build/gen-jenkins.sh" "${instance}"
  "${SCRIPT_FOLDER}/../build/gen-k8s.sh" "${instance}"
}

for instance in "${@}"; do
  project_name="$(basename "${instance}")"
  echo
  echo "${project_name}:"
  regen "${instance}"
  oc apply -f "${instance}/target/k8s/configmap-jenkins-config.yml"
  oc apply -f "${instance}/target/k8s/known-hosts.json"
  oc apply -f "${instance}/target/k8s/m2-dir.json"
  printf "Sleeping for 120 seconds...\n\n"
  (sleep 120s && "${SCRIPT_FOLDER}/../jenkins-cli.sh" "${instance}" reload-jcasc-configuration && echo "Done ${project_name}" >> ${log_file}) &
done
