#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

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

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

config="${instance}/target/config.json"

mkdir -p "${instance}/target"

# merge default values and instance specific values
"${SCRIPT_FOLDER}/merge-json.sh" "${SCRIPT_FOLDER}/../templates/default.json.hbs" "${instance}/config.json" "${config}"

# merge previous with parent image build args
buildArgsJsonFile="${SCRIPT_FOLDER}/../jenkins-master-base/$(jq -r '.jenkins.version' "${config}")/build-args.json"
"${SCRIPT_FOLDER}/merge-json.sh" "${config}" "${buildArgsJsonFile}" "${config}"

# add the actual version based on parent image folder name
jenkinsVersion="$(jq -r '.jenkins.version' "${config}")"
actualJenkinsVersion="$(basename "$(readlink -f "jenkins-master-base/${jenkinsVersion}")")"
"${SCRIPT_FOLDER}/merge-json.sh" "${config}" '{"jenkins": {"actualVersion": "'"${actualJenkinsVersion}"'"}}' "${config}"

jenkinsRemotingVersion="$(jq -r '.jenkins.remotingVersion' "${config}")"
actualJenkinsRemotingVersion="$(basename "$(readlink -f "jenkins-agent/${jenkinsRemotingVersion}")")"
"${SCRIPT_FOLDER}/merge-json.sh" "${config}" '{"jenkins": {"actualRemotingVersion": "'"${actualJenkinsRemotingVersion}"'"}}' "${config}"

agentImage="$("${SCRIPT_FOLDER}/expand-template.sh" "${config}" "$(jq -r '.docker.agent.defaultImage.name' "${config}")")"
agentImageTag="$("${SCRIPT_FOLDER}/expand-template.sh" "${config}" "$(jq -r '.docker.agent.defaultImage.tag' "${config}")")"
agentImageSha="$(docker inspect --format='{{index .RepoDigests 0}}' "${agentImage}:${agentImageTag}" | sed -E 's/.*sha256:(.*)/\1/g')"
"${SCRIPT_FOLDER}/merge-json.sh" "${config}" '{"docker": {"agent": {"defaultImage": {"sha256": "'"${agentImageSha}"'"}}}}' "${config}"

# expand all templates in there
"${SCRIPT_FOLDER}/expand-self-template.sh" "${config}"