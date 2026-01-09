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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REMOTING_FILE="${SCRIPT_FOLDER}/../../jiro-agents/remoting/remoting.json"
CONTROLLER_FILE="${SCRIPT_FOLDER}/../../jiro-masters/controller_definition.json"
DEFAULT_BRANCH="master"

# shellcheck disable=SC1091
source "${SCRIPT_FOLDER}/../utils/common.sh"

NEW_LTS_VERSION="${1:-}"

# check that input parameter is not empty
if [[ -z "${NEW_LTS_VERSION}" ]]; then
 printf "ERROR: a version must be given (e.g. '2.492.3').\n"
 exit 1
fi

change_latest() {
  jq -r ".latest=\"${remoting_version}\"" "${REMOTING_FILE}" > "${REMOTING_FILE}.tmp"
  mv "${REMOTING_FILE}.tmp" "${REMOTING_FILE}"
  #jq . "${REMOTING_FILE}"
}

check_latest() {
  if [[ "$(jq -r '.latest' "${REMOTING_FILE}")" != "${remoting_version}" ]]; then
    printf "  "
    _question_action "change the latest version" change_latest
  else
    echo "  Latest version is already set to ${remoting_version}. Skipping..."
  fi
}

git_check_diff() {
  local file="${1:-}"
  local folder="${2:-}"
  pushd "${SCRIPT_FOLDER}/../../${folder}" > /dev/null
  local rc
  rc=$(git diff --quiet "${file}"; echo $?)
  popd > /dev/null
  return ${rc}
}

git_commit() {
  local file="${1:-}"
  local folder="${2:-}"
  pushd "${SCRIPT_FOLDER}/../../${folder}" > /dev/null
  git add "${file}"
  git diff --cached
  read -rsp $'Once you are done, press any key to continue...\n' -n1
  git commit -m "Add new remoting version for Jenkins LTS ${NEW_LTS_VERSION}"
  echo
  git log -1
  read -rsp $'If you are ready to push, press any key to continue...\n' -n1
  git push origin "${DEFAULT_BRANCH}"
  popd > /dev/null
}

remoting_commit() {
  git_commit "${REMOTING_FILE}" "jiro-agents"
}

controller_commit() {
  git_commit "${CONTROLLER_FILE}" "jiro-masters"
}


remoting() {
  echo
  echo "Checking remoting version..."
  
  #curl -SJOL http://mirrors.jenkins.io/war-stable/${NEW_LTS_VERSION}/jenkins.war
  wget -cq "http://mirrors.jenkins.io/war-stable/${NEW_LTS_VERSION}/jenkins.war"
  remoting_version="$(unzip -p jenkins.war META-INF/MANIFEST.MF | grep Remoting-Embedded | sed 's/Remoting-Embedded-Version://' | tr -d '[:space:]')"
  
  printf "\n  Remoting version: %s\n\n" "${remoting_version}"
  
  #TODO: check if remoting version already exists in jiro-agents/remoting/remoting.libsonnet
  echo "1. Adding new remoting version (if applicable)..."
  echo
  echo "  TODO:"
  echo "  * check https://github.com/jenkinsci/docker-agent/releases to find startup script version"
  echo "  * adding remoting version in jiro-agents/remoting/remoting.json"
  echo
  read -p "  Enter the startup script version: " -r startupScript_version

  #trim string
  startupScript_version="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< ${startupScript_version})"

  if [[ -z "${startupScript_version}" ]]; then
   printf "  ERROR: a version must be given.\n"
   exit 1
  fi
  
  if grep "${NEW_LTS_VERSION}" "${REMOTING_FILE}" > /dev/null; then
    echo "  Remoting definition already contains an entry for Jenkins version ${NEW_LTS_VERSION}. Skipping..."
  else
    if jq -e "any(.releases[].remotingVersion == \"${remoting_version}\";.)" "${REMOTING_FILE}"; then
      #https://jqlang.github.io/jq/manual/#complex-assignments
      echo "Adding new version"
      jq "(.releases[] | select(.remotingVersion == \"${remoting_version}\") | .jenkinsVersion) |= . + [\"${NEW_LTS_VERSION}\"]" "${REMOTING_FILE}" > "${REMOTING_FILE}.tmp"
    else
      jq ".releases+=[{\"jenkinsVersion\": [\"${NEW_LTS_VERSION}\"], \"remotingVersion\": \"${remoting_version}\", \"startupScriptVersion\": \"${startupScript_version}\"}]" "${REMOTING_FILE}" > "${REMOTING_FILE}.tmp"
    fi
    cp "${REMOTING_FILE}.tmp" "${REMOTING_FILE}"
    jq . "${REMOTING_FILE}"
    rm "${REMOTING_FILE}.tmp"
  fi
  
  #TODO: add newer startupScript_version if required
  
  echo
  check_latest
  
  echo
  echo "  * remove old versions (optional)"
  echo
  if ! git_check_diff "${REMOTING_FILE}" "jiro-agents"; then
    printf "  "
    _question_action "commit the change to the jiro-agents repo" remoting_commit
    ## TODO: only wait if a change was committed
    echo "  * wait for CI build to finish: https://ci.eclipse.org/cbi/view/Jiro/job/jiro-agents/job/master/"
    echo
    read -rsp $'Once you are done, press any key to continue...\n' -n1
  else
    echo "  No differences found in remoting file, therefore skipping the git commit step."
  fi
  echo
}

controller() {
  #FIXME try to avoid calling this twice
  remoting_version="$(unzip -p jenkins.war META-INF/MANIFEST.MF | grep Remoting-Embedded | sed 's/Remoting-Embedded-Version://' | tr -d '[:space:]')"
  echo
  echo "2. Adding new Jiro controller..."
  echo
  if grep "${NEW_LTS_VERSION}" "${CONTROLLER_FILE}" > /dev/null; then
    echo "  Controller definition already contains an entry for Jenkins version ${NEW_LTS_VERSION}. Skipping..."
  else
    echo "Adding new version"
    jq ".controllers |= . + [{ \"jenkinsVersion\": \"${NEW_LTS_VERSION}\", \"remotingVersion\": \"${remoting_version}\"}]" "${CONTROLLER_FILE}" > "${CONTROLLER_FILE}.tmp"
    cp "${CONTROLLER_FILE}.tmp" "${CONTROLLER_FILE}"
    jq . "${CONTROLLER_FILE}"
    rm "${CONTROLLER_FILE}.tmp"
  fi

#TODO: check latest

  echo "  TODO:"
  echo "  * remove old versions (optional)"
  echo
  if ! git_check_diff "${CONTROLLER_FILE}" "jiro-masters"; then
    printf "  "
    _question_action "commit the change to the jiro-masters repo" controller_commit
    #TODO: only wait if a change was committed
    echo "  * wait for CI build to finish: https://ci.eclipse.org/cbi/view/Jiro/job/jiro-masters/job/master/"
    echo
    read -rsp $'Once you are done, press any key to continue...\n' -n1
  else
    echo "  No differences found in controllers file, therefore skipping the git commit step."
  fi
  echo

  #TODO: Check that new tag is available from docker hub (https://hub.docker.com/r/eclipsecbi/jiro-master/tags)
}

echo
echo "Preparations for Jenkins LTS release version ${NEW_LTS_VERSION}:"
echo "--------------------------------------------------------------"

remoting
controller

echo "  TODO:"
echo "  * Change Jenkins version in config.jsonnet of CBI Jenkins instance"
echo "  * Re-deploy CBI Jenkins instance"

read -rsp $'Once you are done, press any key to continue...\n' -n1

rm jenkins.war

echo "DONE"

