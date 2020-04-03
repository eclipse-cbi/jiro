#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

project_name="${1:-}"

usage() {
  printf "Usage: %s project_name\n" "$script_name"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

pushd ../
make k8s_${project_name}
oc apply -f instances/${project_name}/target/k8s/configmap-jenkins-config.yml
echo "Sleeping for 120 seconds..."
sleep 120s
./jenkins-cli.sh instances/${project_name} reload-jcasc-configuration
popd
echo "Done."
