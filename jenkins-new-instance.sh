#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
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
script_name="$(basename "${0}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

project_name="${1:-}"
display_name="${2:-}"
short_name=${project_name##*.}

usage() {
  printf "Usage: %s project_name display_name\n" "$script_name"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
  printf "\t%-16s display name (e.g. 'Eclipse CBI' for CBI project).\n" "display_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

# check that display name is not empty
if [[ -z "${display_name}" ]]; then
 printf "ERROR: a display name must be given.\n"
 usage
 exit 1
fi

# check that project name contains a dot
if [[ "$project_name" != *.* ]]; then
  printf "ERROR: the full project name with a dot must be given (e.g. technology.cbi).\n"
  usage
  exit 1
fi

mkdir -p "${SCRIPT_FOLDER}/instances/${project_name}"
{
  printf '{\n'
  printf '  "project": {\n'
  printf '    "fullName": "%s",\n' "${project_name}"
  printf '    "shortName": "%s",\n' "${short_name}"
  printf '    "displayName": "%s"\n' "${display_name}"
  printf '  }\n'
  printf '}\n'
} >  "${SCRIPT_FOLDER}/instances/${project_name}/config.json"
