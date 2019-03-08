#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script generates a secret in OpenShift that contains the private key for Gerrit.
# It takes the private key from the keystore and adds the user to "Event Streaming Users" group.

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

project_name="${1:-}"
short_name=${project_name##*.}

site=git.eclipse.org
pw_store_path=cbi-pass/bots/${project_name}/${site}
temp_path=/tmp/${short_name}


usage() {
  printf "Usage: %s project_name\n" "$script_name"
  printf "\t%-16s project name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

# check that project name contains a dot
if [[ "$project_name" != *.* ]]; then
  printf "ERROR: the full project name with a dot must be given (e.g. technology.cbi).\n"
  usage
  exit 1
fi

add_gerrit_secret() {
  mkdir -p ${temp_path}

  pass ${pw_store_path}/id_rsa > ${temp_path}/id_rsa
  if [ -f ${temp_path}/id_rsa ]; then
    oc create secret generic gerrit-ssh-keys --namespace=${short_name} --from-file=${temp_path}/id_rsa
  else
    echo "ERROR: ${temp_path} does not exist."
  fi

  rm -rf ${temp_path}
}
add_gerrit_secret

echo "Adding user to Event Streaming Users group..."
ssh -p 29418 git.eclipse.org gerrit set-members --add "${short_name}-bot@eclipse.org" '"Event Streaming Users"'

echo "Done."
