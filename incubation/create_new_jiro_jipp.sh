#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
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
script_name="$(basename "${BASH_SOURCE[0]}")"
script_folder="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

project_name="${1:-}"
display_name="${2:-}"
short_name="${project_name##*.}"
hostname="ci.eclipse.org"

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
  printf "ATTENTION: the full project name does not contain a dot (e.g. technology.cbi). Please double-check that this is intentional!\n"
  read -rp "Press enter to continue or CTRL-C to stop the script"
fi

provisioning() {
  if [[ $(oc get projects | grep -e "^${short_name} ") ]]; then
    printf "Namespace %s already exists. Skipping creation...\n" "${project_name}"
  else
    oc create namespace "${short_name}"
  fi
  "${script_folder}/../secrets/create_gerrit_ssh_keys_secret.sh" "${project_name}"
  make -C "${script_folder}/.." "deploy_${project_name}"
}

wait_for_jipp_post_setup() {
  local host="${1:-}"
  printf "Waiting for JIPP to come online..."
  echo "host: ${host}"
  n=0
  until [ $n -ge 15 ]
  do
    curl -sL -w "%{http_code}\n" "https://${host}/${short_name}" -o /dev/null | grep 200 && break
    printf "."
    n=$((n+1))
    sleep 12
  done
  printf "\n"

  if [[ $(curl -sL -w "%{http_code}\n" "https://${host}/${short_name}" -o /dev/null | grep 200) ]]; then
    printf "JIPP is online!\n"
    "${script_folder}/post_setup.sh" "${project_name}"
  else
    printf "ERROR: JIPP is not online after three minutes, please investigate and run post_setup.sh manually!\n"
  fi
}

"${script_folder}/../jenkins-new-instance.sh" "${project_name}" "${display_name}"
provisioning
wait_for_jipp_post_setup "${hostname}"
