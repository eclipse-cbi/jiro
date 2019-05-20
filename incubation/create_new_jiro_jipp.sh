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

${script_folder}/../jenkins-new-instance.sh ${project_name} ${display_name}
pushd ${ci_admin_dir}
./add_creds_gerrit.sh ${project_name}
popd
oc create namespace ${short_name}
${script_folder}/../secrets/create_gerrit_ssh_keys_secret.sh ${project_name}
make -C ${script_folder}/.. deploy_${project_name}

printf "Waiting for JIPP to come online..."
n=0
until [ $n -ge 10 ]
do
  curl -sL -w "%{http_code}\n" "https://ci-staging.eclipse.org/${short_name}" -o /dev/null | grep 200 && break
  printf "."
  n=$[$n+1]
  sleep 12
done
printf "\n"

if [[ $(curl -sL -w "%{http_code}\n" "https://ci-staging.eclipse.org/${short_name}" -o /dev/null | grep 200) ]]; then
  printf "JIPP is online!\n"
  ./post_setup.sh ${project_name}
else
  printf "ERROR: JIPP is not online after two minutes, please investigate and run post_setup.sh manually!\n"
fi

