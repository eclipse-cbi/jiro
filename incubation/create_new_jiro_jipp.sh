#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"
script_folder="$(dirname $(readlink -f "${0}"))"

ci_admin_dir="${script_folder}/../../ci-admin"

project_name="${1:-}"
display_name="${2:-}"
short_name=${project_name##*.}
default_host="ci.eclipse.org"
migration_host="ci-staging.eclipse.org"

usage() {
  printf "Usage: %s project_name display_name\n" "$script_name"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
  printf "\t%-16s display name (e.g. 'Eclipse CBI' for CBI project).\n" "display_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

# check that display name is not empty
if [[ -z "${display_name}" ]]; then
 printf "ERROR: a display name must be given.\n"
 usage
 exit 1
fi

# check that project name contains a dot
if [[ "$project_name" != *.* ]]; then
  printf "ERROR: the full project name with a dot must be given (e.g. technology.cbi).\n"
  usage
  exit 1
fi

new_migration_instance() {
  mkdir -p "${script_folder}/../instances/${project_name}"
  {
    printf '{\n'
    printf '  "project": {\n'
    printf '    "fullName": "%s",\n' "${project_name}"
    printf '    "shortName": "%s",\n' "${short_name}"
    printf '    "displayName": "%s"\n' "${display_name}"
    printf '  },\n'
    printf '  "deployment": {\n'
    printf '    "host": "ci-staging.eclipse.org"\n'
    printf '  }\n'
    printf '}\n'
  } >  "${script_folder}/../instances/${project_name}/config.json"
}

migration_or_not() {
  read -p "Is this a migration from the old infrastructure? (Y)es, (N)o, E(x)it: " yn
  case $yn in
    [Yy]* ) new_migration_instance;hostname=${migration_host};;
    [Nn]* ) ${script_folder}/../jenkins-new-instance.sh ${project_name} ${display_name};hostname=${default_host};;
    [Xx]* ) exit;;
        * ) echo "Please answer (Y)es, (N)ooo, E(x)it";;
  esac
}

provisioning() {
  pushd ${ci_admin_dir}
  ./add_creds_gerrit.sh ${project_name} || : # if creds already exist, ignore exit code 1
  ./add_creds_projects-storage.sh ${project_name} || : # if creds already exist, ignore exit code 1
  popd
  if [[ $(oc get projects | grep ${short_name}) ]]; then
    printf "Namespace ${project_name} already exists. Skipping creation...\n"
  else
    oc create namespace ${short_name}
  fi
  ${script_folder}/../secrets/create_gerrit_ssh_keys_secret.sh ${project_name}
  make -C ${script_folder}/.. deploy_${project_name}
}

wait_for_jipp_post_setup() {
  local host=$1
  printf "Waiting for JIPP to come online..."
  echo "host: ${host}"
  n=0
  until [ $n -ge 15 ]
  do
    curl -sL -w "%{http_code}\n" "https://${host}/${short_name}" -o /dev/null | grep 200 && break
    printf "."
    n=$[$n+1]
    sleep 12
  done
  printf "\n"
  
  if [[ $(curl -sL -w "%{http_code}\n" "https://${host}/${short_name}" -o /dev/null | grep 200) ]]; then
    printf "JIPP is online!\n"
    ./post_setup.sh ${project_name}
  else
    printf "ERROR: JIPP is not online after three minutes, please investigate and run post_setup.sh manually!\n"
  fi
}

migration_or_not
provisioning
wait_for_jipp_post_setup ${hostname}
