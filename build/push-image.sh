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

${SCRIPT_FOLDER}/gen-jenkins.sh "${instance}"
${SCRIPT_FOLDER}/gen-dockerfile.sh "${instance}"

masterImage="$(jq -r '.docker.master.image' "${config}")"
masterImageTag="$(jq -r '.docker.master.imageTag' "${config}")"

${SCRIPT_FOLDER}/dockerw push "${masterImage}" "${masterImageTag}"

if [[ "${masterImageTag}" != "latest" ]]; then
  ./build/dockerw push "${masterImage}" "latest"
fi

imageSha="$(docker inspect --format='{{index .RepoDigests 0}}' "${masterImage}:${masterImageTag}" | sed -E 's/.*sha256:(.*)/\1/g')"
configForSha=$(mktemp)
echo '{"docker": {"master": {"imageSha256": "'${imageSha}'"}}}' > "${configForSha}"
jq -s '.[0] * .[1]' "${config}" "${configForSha}" > "${config}.out"
mv "${config}.out" "${config}"
rm "${configForSha}"