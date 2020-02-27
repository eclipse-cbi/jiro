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

target="${instance}/target"
config="${target}/config.json"

mkdir -p "$(dirname "${config}")"
mkdir -p "$(dirname "${config}")/k8s"

"${SCRIPT_FOLDER}/../.jsonnet/jsonnet" -m "${target}" "${instance}/jiro.jsonnet"

agentImage="$(jq -r '.docker.agent.defaultImage.name' "${config}")"
agentImageTag="$(jq -r '.docker.agent.defaultImage.tag' "${config}")"
agentImageSha="$("${SCRIPT_FOLDER}/../.dockertools/dockerw" digest "${agentImage}:${agentImageTag}")"

patch='{"docker": {"agent": {"defaultImage": {"digest": "'"${agentImageSha}"'"}}}}'
"${SCRIPT_FOLDER}/../.jsonnet/jsonnet" -e 'std.mergePatch(import "'"${config}"'", '"${patch}"')' -o "${config}"
