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
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

PROJECT_NAME="${1:-}"
SHORT_NAME="${PROJECT_NAME##*.}"

usage() {
  printf "Usage: %s project_name\n" "${SCRIPT_NAME}"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${PROJECT_NAME}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

create_and_copy_templates() {
  mkdir -p tmp

  echo "Creating Xvnc config template..."
  local xvnc_commandline='Xvnc :$DISPLAY_NUMBER -geometry 1024x768 -depth 24 -ac -SecurityTypes none -noreset'
  cat <<EOH > tmp/hudson.plugins.xvnc.Xvnc.xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.xvnc.Xvnc_-DescriptorImpl plugin="xvnc@1.24">
  <xvnc>${xvnc_commandline}</xvnc>
  <minDisplayNumber>10</minDisplayNumber>
  <maxDisplayNumber>99</maxDisplayNumber>
  <skipOnWindows>true</skipOnWindows>
  <cleanUp>true</cleanUp>
  <allocators>
  </allocators>
</hudson.plugins.xvnc.Xvnc_-DescriptorImpl>
EOH

  echo "Creating credentials..."
  "${SCRIPT_FOLDER}/../jenkins-create-credentials.sh" "${PROJECT_NAME}"

  echo "Copy files to Jiro pod ${SHORT_NAME}-0..."
  oc rsync tmp/ "${SHORT_NAME}-0:/var/jenkins/" -n="${SHORT_NAME}" --no-perms
  rm -rf tmp
  #TODO: restart Jenkins via Jenkins CLI?
  echo "Force restart of Jenkins..."
  oc delete pod "${SHORT_NAME}-0" -n="${SHORT_NAME}" --force
}

create_and_copy_templates
