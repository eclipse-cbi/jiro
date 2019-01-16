#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
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
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

project_full_name="${1}"
project_short_name="${2}"
project_display_name="${3}"

mkdir -p "${SCRIPT_FOLDER}/instances/${project_full_name}"
echo "#!/usr/bin/env bash" > "${SCRIPT_FOLDER}/instances/${project_full_name}/config.properties"
echo "JENKINS_FULL_NAME=\"${project_full_name}\"" >> "${SCRIPT_FOLDER}/instances/${project_full_name}/config.properties"
echo "JENKINS_SHORT_NAME=\"${project_short_name}\"" >> "${SCRIPT_FOLDER}/instances/${project_full_name}/config.properties"
echo "JENKINS_DISPLAY_NAME=\"${project_display_name}\"" >> "${SCRIPT_FOLDER}/instances/${project_full_name}/config.properties"
