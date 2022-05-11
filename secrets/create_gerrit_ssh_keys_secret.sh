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
script_name="$(basename "${BASH_SOURCE[0]}")"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi"}}' | jq -M
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
export PASSWORD_STORE_DIR

project_name="${1:-}"
short_name=${project_name##*.}

site=git.eclipse.org
pw_store_path=bots/${project_name}/${site}

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

add_gerrit_secret() {
  if [[ -f "${PASSWORD_STORE_DIR}/${pw_store_path}/id_rsa.gpg" ]]; then 
    oc create secret generic gerrit-ssh-keys --namespace="${short_name}" --from-file="id_rsa=/dev/stdin" <<<"$(pass "${pw_store_path}/id_rsa")"
  else
    echo "WARNING: Project does not have a pass entry '${PASSWORD_STORE_DIR}/${pw_store_path}/id_rsa'."
  fi
}

if oc get secrets --namespace="${short_name}" | grep -q "gerrit-ssh-keys"; then
  printf "Secret gerrit-ssh-keys already exists. Skipping creation...\n"
else
  add_gerrit_secret
fi

echo "Adding user to Event Streaming Users group..."
ssh -p 29418 git.eclipse.org gerrit set-members --add "${short_name}-bot@eclipse.org" '"Event Streaming Users"'

echo "Done."
