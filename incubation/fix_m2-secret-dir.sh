#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"
script_folder="$(dirname $(readlink -f "${0}"))"

#list_of_projects=$(oc get projects -l org.eclipse.cbi.jiro/kind=master | tail -n +2 | awk '{print $1}')
list_of_instances=$(ls -1 ${script_folder}/../instances/)

create_m2_secret_dir() {
  local project_name="${1:-}"
  printf "Creating M2 secret dir for ${project_name}...\n"
  build="${script_folder}/../build"
  instance="${script_folder}/../instances/${project_name}"
  templates="${script_folder}/../templates"
  config="${instance}/target/config.json"
  tmp_dir="$(mktemp -d)"
  "${build}/gen-yaml.sh" "${instance}/k8s/m2-secret-dir.yml" "${templates}/k8s/m2-secret-dir.yml.hbs" "${config}" > "${tmp_dir}/m2-secret-dir.yml"
  oc apply -f "${tmp_dir}/m2-secret-dir.yml"
  rm -rf ${tmp_dir}
}

while read instance;
 do
  #check if secret exists, if not, create it
  short_name=${instance##*.}
  if [[ $(oc get secret m2-secret-dir -n=${short_name} 2> /dev/null) ]]; then
    echo "DONE ${instance}"
  else
    create_m2_secret_dir ${instance}
  fi
done <<<"${list_of_instances}"