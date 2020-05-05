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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ ${instance} == "ALL" ]]; then
  for i in "${SCRIPT_FOLDER}/instances/"*; do 
    >&2 echo "Calling CLI for '$(basename "${i}")'..."
    "${0}" "${i}" "${@:2}" || :
  done
  exit 0
elif [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

jenkinsUrl="$(jq -r '.deployment.url' "${instance}/target/config.json")"
jenkinsVersion="$(jq -r '.jiroMaster.version' "${instance}/target/config.json")"

# First download the jar for the running version (if needed)
CLI_JAR="${SCRIPT_FOLDER}/jenkins-master-base/${jenkinsVersion}/cli.jar"
if [[ ! -f ${CLI_JAR} ]]; then
  curl -sfSL "${jenkinsUrl}/jnlpJars/jenkins-cli.jar" -o "${CLI_JAR}"
fi

if [[ ! -f ${SCRIPT_FOLDER}/.jenkinscreds ]]; then
  echo ".jenkinscreds file is missing. Please enter your credentials, so it can be generated:"
  read -rp "Username: " username
  read -rsp "Password: " pw
  echo "${username}:${pw}" > "${SCRIPT_FOLDER}/.jenkinscreds"
  echo ""
fi
java -jar "${CLI_JAR}" -noKeyAuth -auth @"${SCRIPT_FOLDER}/.jenkinscreds" -s "${jenkinsUrl}" "${@:2}"

