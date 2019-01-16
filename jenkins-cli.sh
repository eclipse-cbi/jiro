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

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

. "${instance}/target/config.properties"

JENKINS_URL="https://${JENKINS_HOST}${JENKINS_PREFIX}"

# First download the jar for the running version (if needed)
CLI_JAR="${SCRIPT_FOLDER}/jenkins-master-base/${JENKINS_VERSION}/cli.jar"
if [[ ! -f ${CLI_JAR} ]]; then
  curl -sfSL ${JENKINS_URL}/jnlpJars/jenkins-cli.jar -o ${CLI_JAR}
fi

java -jar ${CLI_JAR} -noKeyAuth -auth @${SCRIPT_FOLDER}/.jenkinscreds -s ${JENKINS_URL} ${@:2}