#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
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

PROJECT_NAME="${1:-}"
SHORT_NAME="${PROJECT_NAME##*.}"
BACKUP_FILE_NAME="jenkins_backup-${PROJECT_NAME}.tar.gz"

CI_ADMIN_ROOT="${SCRIPT_FOLDER}/../../ci-admin"

#shellcheck disable=SC1091
source "${CI_ADMIN_ROOT}/utils/common.sh"

usage() {
  printf "Usage: %s project_name\n" "${SCRIPT_NAME}"
  printf "\t%-16s project name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${PROJECT_NAME}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

FILE_SERVER="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "server" "file_server")"
FILE_SERVER_USER="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "user" "file_server")"
FILE_SERVER_PW="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "pw" "file_server")"
FILE_SERVER_PW_ROOT="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "pw_root" "file_server")"

create_retire_script() {
  local backup_file_name="${BACKUP_FILE_NAME}"
  local jenkins_home="/var/jenkins"
  mkdir -p tmp

  echo
  echo "Creating retire script..."
  cat <<EOF > tmp/retire.sh
#!/usr/bin/env bash
rm -rf "${jenkins_home}/backup"
mkdir -p "${jenkins_home}/backup"
pushd "${jenkins_home}/plugins"
find . -type f -name '*.jpi' > "${jenkins_home}/plugins/plugins.lst"
popd
tar -czf "${jenkins_home}/backup/${backup_file_name}"\
 --exclude='*/backup'\
 --exclude='*/war'\
 --exclude='*/workspace'\
 --exclude='*/updates'\
 --exclude='*/users'\
 --exclude='*/plugins/**/*'\
 --exclude='*/plugins/*.jpi*'\
 --exclude='*/plugins/*.bak'\
 --exclude='*/fingerprints'\
 --exclude='*/org.jenkinsci.plugins.github_branch_source.GitHubSCMProbe.cache'\
 --exclude='*/caches'\
 --exclude='*/.cache'\
 --exclude='*/.java'\
 --exclude='*/.groovy'\
 --exclude='*/logs'\
 --exclude='*/jobs/*/workspace*'\
 --exclude='*/jobs/*/configurations'\
 --exclude='*/jobs/*/promotions/*/builds'\
 --exclude='*/jobs/*/javadoc'\
 --exclude='*/jobs/*/builds/*/jacoco'\
 --exclude='*/jobs/*/builds/*/archive'\
 "${jenkins_home}"

ls -al "${jenkins_home}/backup"
EOF

  chmod +x tmp/retire.sh
  echo
  echo "Copying retire script to Jiro pod ${SHORT_NAME}-0..."
  oc rsync tmp/ "${SHORT_NAME}-0:/var/jenkins/" -n="${SHORT_NAME}" --no-perms
  oc exec -n="${SHORT_NAME}" "${SHORT_NAME}-0" -i -t -- chmod +x /var/jenkins/retire.sh

  rm -rf tmp
}

collect_backup() {
  create_retire_script
  echo
  echo "Collecting jobs on Jiro pod ${SHORT_NAME}-0..."

  oc exec -n="${SHORT_NAME}" "${SHORT_NAME}-0" -i -t -- /var/jenkins/retire.sh

  echo "Copying files from Jiro pod ${SHORT_NAME}-0..."
  mkdir -p backup
  oc rsync -n="${SHORT_NAME}" "${SHORT_NAME}-0:/var/jenkins/backup/" backup/ --no-perms
}

copy_backup_to_archive() {
  local file_name="${BACKUP_FILE_NAME}"
  local genie_user="genie.${SHORT_NAME}"

  local server="${FILE_SERVER}"
  local user="${FILE_SERVER_USER}"
  local pw="${FILE_SERVER_PW}"
  local pwRoot="${FILE_SERVER_PW_ROOT}"

  local userPrompt="$user@$server:~> *"
  local passwordPrompt="\[Pp\]assword: *"
  local serverRootPrompt="$server:~ # *"

  local archive_folder="/opt/public/hipp/archive/${genie_user}"

  echo
  echo "Copying backup tar.gz to ${FILE_SERVER}:/tmp..."
  scp "backup/${BACKUP_FILE_NAME}" "${FILE_SERVER}:/tmp/"

  echo
  echo "Moving backup from /tmp/${file_name} to ${archive_folder}/..."

  expect -c "
  #5 seconds timeout
  set timeout 5

  # ssh to remote
  spawn ssh $user@$server

  expect {
    -re \"$passwordPrompt\" {
      send [exec pass $pw]\r
    }
    #TODO: only works one time
    -re \"passphrase\" {
      interact -o \"\r\" return
    }
  }
  expect -re \"$userPrompt\"

  # su to root
  send \"su -\r\"
  interact -o -nobuffer -re \"$passwordPrompt\" return
  send [exec pass $pwRoot]\r
  expect -re \"$serverRootPrompt\"

  # move file
  send \"mkdir -p $archive_folder/\r\"
  send \"mv /tmp/$file_name $archive_folder/\r\"
  send \"ls -al $archive_folder\r\"

  # exit su, exit su and exit ssh
  send \"exit\rexit\rexit\r\"
  expect eof
"
}

delete_project() {
  echo
  echo "Deleting project/namespace on the cluster..."
  oc delete project "${SHORT_NAME}"
  oc delete pv "tools-jiro-${SHORT_NAME}"

  echo
  echo "Deleting project in Jiro..."
  rm -rf "../instances/${PROJECT_NAME}"
}


# Main

#TODO: check if namespace & jiro dir still exist
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

_question_action "collect the backup" collect_backup

_question_action "copy the backup to the archive" copy_backup_to_archive

_question_action "delete the ${PROJECT_NAME} project on the cluster and in Jiro" delete_project

echo
echo "TODO:"
echo "- commit and push changes to jiro repo"
echo "- comment on issue"
echo "- remove credentials from pass"
echo "- update ci.eclipse.org dashboard"
