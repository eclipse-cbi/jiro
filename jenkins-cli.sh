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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ ${instance} == "ALL" ]]; then
  for i in "${SCRIPT_FOLDER}/instances/"*; do 
    >&2 echo "Calling CLI for '$(basename "${i}")'..."
    "${BASH_SOURCE[0]}" "${i}" "${@:2}" || :
  done
  exit 0
elif [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

jenkinsUrl="$(jq -r '.deployment.url' "${instance}/target/config.json")"
jenkinsVersion="$(jq -r '.jiroMaster.version' "${instance}/target/config.json")"

# First download the jar for the running version (if needed)
mkdir -p "${SCRIPT_FOLDER}/.cli_temp_dir"
CLI_JAR="${SCRIPT_FOLDER}/.cli_temp_dir/${jenkinsVersion}-cli.jar"
if [[ ! -f ${CLI_JAR} ]]; then
  curl -sfSL "${jenkinsUrl}/jnlpJars/jenkins-cli.jar" -o "${CLI_JAR}"
fi

jenkins_user="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "user" "jenkins_login")"
jenkins_pw="$("${SCRIPT_FOLDER}/utils/local_config.sh" "get_var" "pw" "jenkins_login")"

java -jar "${CLI_JAR}" -webSocket -auth "${jenkins_user}:${jenkins_pw}" -s "${jenkinsUrl}" "${@:2}"

