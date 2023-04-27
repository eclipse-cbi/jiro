#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
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

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

#TODO: change display name?

OLD_PROJECT_NAME="${1:-}"
NEW_PROJECT_NAME="${2:-}"

usage() {
  printf "Usage: %s old_project_name new_project_name\n" "${SCRIPT_NAME}"
  printf "\t%-16s old project name (e.g. technology.cbi for CBI project).\n" "old_project_name"
  printf "\t%-16s new project name (e.g. technology.cbi-new for CBI project).\n" "new_project_name"
}

# check that old project name is not empty
if [[ -z "${OLD_PROJECT_NAME}" ]]; then
 printf "ERROR: an old project name must be given.\n"
 usage
 exit 1
fi

# check that new project name is not empty
if [[ -z "${NEW_PROJECT_NAME}" ]]; then
 printf "ERROR: a new project name must be given.\n"
 usage
 exit 1
fi

OLD_SHORT_NAME="${OLD_PROJECT_NAME##*.}"
NEW_SHORT_NAME="${NEW_PROJECT_NAME##*.}"

NEW_INSTANCE_FOLDER="${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME}"

shutdown_old_instance() {
  echo "Shutting down the old Jenkins instance..."
  kubectl scale -n "${OLD_SHORT_NAME}" sts "${OLD_SHORT_NAME}" --replicas=0
  kubectl wait -n "${OLD_SHORT_NAME}" "pod/${OLD_SHORT_NAME}-0" --for=delete
}

backup_pv() {
  if [[ "${OLD_SHORT_NAME}" != "${NEW_SHORT_NAME}" ]]; then
    echo
    echo "Backup PV on backend server (manually for now)..."
    echo "#################################################"
    echo
    echo "* login"
    echo "* navigate to PV folder"
    echo "* cp -R ${OLD_SHORT_NAME}-jenkins-home-* ${NEW_SHORT_NAME}-jenkins-home-*_BACKUP"
    echo
    read -rsp $'Once you are done, press any key to continue...\n' -n1
  fi
}

rename_instance_folder() {
  echo
  echo "Renaming instances folder..."
  if [[ -d "${NEW_INSTANCE_FOLDER}" ]]; then
    echo "  ${NEW_INSTANCE_FOLDER} already exists, skipping..."
  else
    mv "${SCRIPT_FOLDER}/../instances/${OLD_PROJECT_NAME}" "${NEW_INSTANCE_FOLDER}"
  fi
}

adapt_config() {
  echo
  echo "Changing fullName in config.jsonnet..."
  if grep "fullName: \"${NEW_PROJECT_NAME}\"" "${NEW_INSTANCE_FOLDER}/config.jsonnet" > /dev/null ; then
    echo "  WARNING: fullName has been changed already. Skipping..."
  else
    sed -i "s/fullName: \"${OLD_PROJECT_NAME}\"/fullName: \"${NEW_PROJECT_NAME}\"/" "${NEW_INSTANCE_FOLDER}/config.jsonnet"
  fi
#TODO: fix display name (semi-)automatically
  echo
  echo "TODO: fix display name in config.jsonnet file (manually for now)..."
  read -rsp $'Once you are done, press any key to continue...\n' -n1
}

deploy_jipp() {
  echo
  echo "Deploy JIPP?"
  read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1
#TODO: allow to skip

  echo
  echo "Connected to cluster?"
  read -rsp "Press enter to continue or CTRL-C to abort..."

  # delete old statefulset since not all fields can be updated
  if [[ "${OLD_SHORT_NAME}" == "${NEW_SHORT_NAME}" ]]; then
    oc delete sts "${OLD_SHORT_NAME}" -n "${OLD_SHORT_NAME}"
  fi

  pushd "${SCRIPT_FOLDER}/.."
  #TODO: get rid of it
  make "deploy_${NEW_PROJECT_NAME}"
  secrets/create_gerrit_ssh_keys_secret.sh "${NEW_PROJECT_NAME}"
  popd
}

fix_pv() {
  if [[ "${OLD_SHORT_NAME}" != "${NEW_SHORT_NAME}" ]]; then
    echo
    echo "Fix PV on backend server (manually for now)..."
    echo "##############################################"
    echo
    echo "* Stop Jenkins controller pod"
    echo "  oc scale sts ${NEW_SHORT_NAME} -n ${NEW_SHORT_NAME} --replicas=0"
    echo "* Find out UID of files in new PV"
    echo "* Copy jobs from old PV to new PV"
    echo "  cp -R ${OLD_SHORT_NAME}-jenkins-home-*/jobs/* ${NEW_SHORT_NAME}-jenkins-home-*/jobs/"
    echo "* fix ownership"
    echo "  chown -R <new UID>:root ${NEW_SHORT_NAME}-jenkins-home-*/jobs/* "
    echo "* Start Jenkins controller pod"
    echo "  oc scale sts ${NEW_SHORT_NAME} -n ${NEW_SHORT_NAME} --replicas=1"
    echo
    read -rsp $'Once you are done, press any key to continue...\n' -n1
  fi
}

## MAIN
echo
echo "JIPP for ${OLD_PROJECT_NAME} will be renamed to ${NEW_PROJECT_NAME}..."
read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1

shutdown_old_instance
backup_pv
rename_instance_folder
adapt_config
deploy_jipp
fix_pv

#TODO: wait until JIPP is online again

if [[ "${OLD_SHORT_NAME}" != "${NEW_SHORT_NAME}" ]]; then
  echo "Updating Jenkins credentials..."
  pushd "${SCRIPT_FOLDER}/.."
  ./jenkins-create-credentials.sh "${NEW_PROJECT_NAME}"
  ./jenkins-create-credentials-token.sh auto "${NEW_PROJECT_NAME}"
  popd
fi

echo
echo "TODO:"
if [[ "${OLD_SHORT_NAME}" != "${NEW_SHORT_NAME}" ]]; then
  echo "* clean up old namespace"
  echo "* remove backup?"
  echo "* double-check permissions in Jenkins"
fi
echo "* commit changes (don't push)"

