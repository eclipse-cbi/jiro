#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

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

config="${instance}/target/config.json"

mkdir -p ${instance}/target

# merge default values and instance specific values
${SCRIPT_FOLDER}/merge-json.sh "${SCRIPT_FOLDER}/../templates/default.json" "${instance}/config.json" "${config}"

# merge previous with parent image build args
buildArgsJsonFile="${SCRIPT_FOLDER}/../jenkins-master-base/$(jq -r '.jenkins.version' "${config}")/build-args.json"
${SCRIPT_FOLDER}/merge-json.sh "${config}" "${buildArgsJsonFile}" "${config}"

# add the actual version based on parent image folder name
jenkinsVersion="$(jq -r '.jenkins.version' "${config}")"
actualJenkinsVersion="$(basename $(readlink -f jenkins-master-base/${jenkinsVersion}))"
${SCRIPT_FOLDER}/merge-json.sh "${config}" '{"jenkins": {"actualVersion": "'${actualJenkinsVersion}'"}}' "${config}"

# expand all templates in there
${SCRIPT_FOLDER}/expand-self-template.sh "${config}"