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

CBI_PASS_DIR="$("${SCRIPT_FOLDER}/../utils/local_config.sh" "get_var" "cbi-dir" "password-store")"

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

#git_commit_push() {
  #TODO: add method
#}

commit_jiro_changes() {
  local JIRO_DEFAULT_BRANCH="master"
  echo
  echo "Commiting jiro changes..."
  # TODO: make sure that the git index is empty
  # TODO: deal with case where files have already been added
  git add "../instances/${PROJECT_NAME}"
  #TODO: diff index
  if git diff --staged --exit-code > /dev/null; then
    echo "INFO: Found no differences, skipping commit..."
    return
  else
    #TODO: diff index
    git diff --staged --compact-summary
  fi
  read -rsp $'Press enter to continue or CTRL-C to stop the script...\n'
  echo
  git commit -m "Retire ${PROJECT_NAME}"
  git log -1
  read -rsp $'Press enter to continue or CTRL-C to stop the script...\n'
  git push origin "${JIRO_DEFAULT_BRANCH}"
}

delete_pass_credentials() {
  local CBI_PASS_DEFAULT_BRANCH="master"
  # TODO: make sure that the git index is empty
  # TODO: pull before push
  pushd "${CBI_PASS_DIR}" > /dev/null
    git rm -r "${CBI_PASS_DIR}/bots/${PROJECT_NAME}"
    if git diff --staged --exit-code > /dev/null; then
      echo "INFO: Found no differences, skipping commit..."
      popd > /dev/null
      return
    else
      #TODO: diff index
      git diff --staged --compact-summary
    fi
    read -rsp $'Press enter to continue or CTRL-C to stop the script...\n'
    echo
    git commit -m "Retire ${PROJECT_NAME}"
    git log -1
    read -rsp $'Press enter to continue or CTRL-C to stop the script...\n'
    git push origin "${CBI_PASS_DEFAULT_BRANCH}"
  popd > /dev/null
}

update_list_of_jipps() {
  echo "Updating the list of JIPPs on ci.eclipse.org..."
  local ci_dashboard_folder="${SCRIPT_FOLDER}/../../ci.eclipse.org-dashboard"
  #check if ci.eclipse.org-dashboard repo is available
  if [[ ! -d "${ci_dashboard_folder}" ]]; then
    echo "ci.eclipse.org-dashboard git repo not found! It is expected to exist here: ${ci_dashboard_folder}"
    echo "Clone the ci.eclipse.org-dashboard git repo and try again!"
    #TODO: offer checkout
    return
  fi
  pushd "${ci_dashboard_folder}" > /dev/null
    ./build_site.sh
    echo "TODO: Commit and push changes in ${ci_dashboard_folder}"
    #git_commit_push "${ci_dashboard_folder}"
  popd > /dev/null
  # double-check that the list was updated
}

update_prometheus_scrape_targets() {
  local prometheus_folder="${SCRIPT_FOLDER}/../../prometheus"
  #check if prometheus repo is available
  if [[ ! -d "${prometheus_folder}" ]]; then
    echo "prometheus git repo not found! It is expected to exist here: ${prometheus_folder}"
    echo "Clone the prometheus git repo and try again!"
    #TODO: offer checkout
    return
  fi
  pushd "${prometheus_folder}" > /dev/null
    ./fix_jenkins_targets.sh
    echo "TODO: Commit and push changes in ${prometheus_folder}"
    #git_commit_push "${prometheus_folder}"
  popd > /dev/null
}



# Main

#TODO: check if namespace & jiro dir still exist
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

_question_action "collect the backup" collect_backup

_question_action "copy the backup to the archive" copy_backup_to_archive

_question_action "delete the ${PROJECT_NAME} project on the cluster and in Jiro" delete_project

_question_action "commit and push the changes to the Jiro repo" commit_jiro_changes

_question_action "delete credentials from pass" delete_pass_credentials

_question_action "update list of JIPPs on ci.eclipse.org" update_list_of_jipps

_question_action "update prometheus scrape targets" update_prometheus_scrape_targets


echo
echo "TODO:"
echo "- comment on HelpDesk issue"
