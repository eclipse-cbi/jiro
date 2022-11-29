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

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

PROJECT_NAME="${1:-}"
JOB_NAME="${2:-}"
SHORT_NAME="${PROJECT_NAME##*.}"

# check that project name is not empty
if [ -z "${PROJECT_NAME}" ]; then
  printf "ERROR: a project name must be given.\n"
  exit 1
fi

if [ -z "${JOB_NAME}" ]; then
  printf "ERROR: a job name must be given.\n"
  exit 1
fi

LOCAL_CONFIG="${HOME}/.cbi/config"

if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the jenkins login credentials. Example:"
  echo '{"jenkins_login": {"user": "my_user_name", "pw": "password"}}' | jq -M
  exit 1
fi

JENKINS_USER="$(jq -r '.["jenkins_login"]["user"]' "${LOCAL_CONFIG}")"
JENKINS_PW="$(jq -r '.["jenkins_login"]["pw"]' "${LOCAL_CONFIG}")"

if [[ -z "${JENKINS_USER}" ]] || [[ "${JENKINS_USER}" == "null" ]]; then
  printf "ERROR: 'jenkins_login/user' must be set in %s.\n" "${LOCAL_CONFIG}. Example:"
  echo '{"jenkins_login": {"user": "my_user_name", "pw": "password"}}' | jq -M
  exit 1
fi

if [[ -z "${JENKINS_PW}" ]] || [[ "${JENKINS_PW}" == "null" ]]; then
  printf "ERROR: 'jenkins_login/pw' must be set in %s.\n" "${LOCAL_CONFIG}. Example:"
  echo '{"jenkins_login": {"user": "my_user_name", "pw": "password"}}' | jq -M
  exit 1
fi


ARCHIVE_NAME="jiro_backup.tar.gz"
BACKUP_ARCHIVE_URL="https://foundation.eclipse.org/ci/infra/job/jiro/job/backup/lastSuccessfulBuild/artifact/${ARCHIVE_NAME}"
TEMP_DIR="jiro_backup"
JOBS_DIR="${TEMP_DIR}/${PROJECT_NAME}/jobs"

reload_jobs() {
  local project_name="${1:-}"
  "${SCRIPT_FOLDER}/../jenkins-cli.sh" "${SCRIPT_FOLDER}/../instances/${project_name}" "reload-configuration" #"reload-job" might work as well
}

reload_question(){
  local project_name="${1:-}"
  read -rp "Do you want to reload the jobs for the ${SHORT_NAME} JIPP? (Y)es, (N)o, E(x)it: " yn
  case "${yn}" in
    [Yy]* ) reload_jobs "${project_name}";;
    [Nn]* ) echo "Skipping reloading jobs... ";return;;
    [Xx]* ) exit;;
        * ) echo "Please answer (Y)es, (N)o, E(x)it";reload_question "${project_name}";;
  esac
}

## MAIN

# download latest backup archive from infra CI instance
printf "\nDowloading backup archive...:\n"
curl -sSL -u "${JENKINS_USER}:${JENKINS_PW}" "${BACKUP_ARCHIVE_URL}" > "${ARCHIVE_NAME}"
#TODO: use wget instead?
#wget --user "${JENKINS_USER}" --password "${JENKINS_PW}" "${BACKUP_ARCHIVE_URL}"

# unpack archive
tar xzf "${ARCHIVE_NAME}" "${JOBS_DIR}/${JOB_NAME}.xml"

# create job structure
mkdir "${JOBS_DIR}/${JOB_NAME}"
mv "${JOBS_DIR}/${JOB_NAME}.xml" "${JOBS_DIR}/${JOB_NAME}/config.xml"

# push job to Jenkins controller pod
printf "\nPushing job to Jenkins controller...:\n"
oc rsync "${JOBS_DIR}/" "${SHORT_NAME}-0:/var/jenkins/jobs/" -n="${SHORT_NAME}" --no-perms

# list jobs
printf "\nJOBS:\n"
oc rsh -n="${SHORT_NAME}" "${SHORT_NAME}-0" ls -al /var/jenkins/jobs

# ask for confirmation before reloading config from disk
printf "\n\n"
reload_question "${PROJECT_NAME}"

# clean up
rm -rf "${TEMP_DIR}" "${ARCHIVE_NAME}"
printf "Done.\n"
