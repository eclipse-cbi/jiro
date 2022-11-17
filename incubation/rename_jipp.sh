#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
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

old_short_name="${OLD_PROJECT_NAME##*.}"
new_short_name="${NEW_PROJECT_NAME##*.}"

if [[ "${old_short_name}" != "${new_short_name}" ]]; then
  echo "Backup PV on bambam (manually for now)..."
  echo "#########################################"
  echo
  echo "* login*"
  echo "* cp -R ${old_short_name}-jenkins-home-* ${new_short_name}-jenkins-home-*-backup"
  read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1
fi

echo
echo "JIPP for ${OLD_PROJECT_NAME} will be renamed to ${NEW_PROJECT_NAME}..."
read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1


echo "Rename instances folder..."
if [[ -d "${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME}" ]]; then
  echo "${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME} already exists, skipping..."
else
  mv "${SCRIPT_FOLDER}/../instances/${OLD_PROJECT_NAME}" "${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME}"
fi

echo "Change fullName in config.jsonnet..."
if grep "fullName: \"${NEW_PROJECT_NAME}\"" "${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME}/config.jsonnet" > /dev/null ; then
  echo "WARNING: fullName has been changed already. Skipping..."
else
  sed -i "s/fullName: \"${OLD_PROJECT_NAME}\"/fullName: \"${NEW_PROJECT_NAME}\"/" "${SCRIPT_FOLDER}/../instances/${NEW_PROJECT_NAME}/config.jsonnet"
fi

echo
echo "Deploy JIPP?"
read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1

# delete old statefulset since not all fields can be updated
if [[ "${old_short_name}" == "${new_short_name}" ]]; then
  oc delete sts "${old_short_name}" -n "${old_short_name}"
fi

pushd "${SCRIPT_FOLDER}/.."
#TODO: get rid of it
secrets/create_gerrit_ssh_keys_secret.sh "${NEW_PROJECT_NAME}"
make "deploy_${NEW_PROJECT_NAME}"
popd


if [[ "${old_short_name}" != "${new_short_name}" ]]; then
  echo "Fix PV on bambam (manually for now)..."
  echo "#########################################"
  echo
  echo "* Stop Jenkins controller pod"
  echo "  oc scale sts ${new_short_name} -n ${new_short_name} --replicas=0"
  echo "* Find out UID of files in old PV"
  echo "* Copy jobs from old PV to new PV"
  echo "  cp ${old_short_name}-jenkins-home-*/jobs/* ${new_short_name}-jenkins-home-*/jobs/"
  echo "* fix ownership"
  echo "  chown -R <old UID>:root ${new_short_name}-jenkins-home-*/jobs/* "
  echo "* Start Jenkins controller pod"
  echo "  oc scale sts ${new_short_name} -n ${new_short_name} --replicas=1"
  read -rsp $'Press any key to continue, or CTRL+C to abort...\n' -n1
fi

#TODO:
# * Add credentials?
#   * /jiro/jenkins-create-credentials.sh "${NEW_PROJECT_NAME}"
#   * /jiro/jenkins-create-credentials-token.sh auto "${NEW_PROJECT_NAME}"
# * deal with old and new namespace
# * remove backup?
# * commit changes (don't push)

