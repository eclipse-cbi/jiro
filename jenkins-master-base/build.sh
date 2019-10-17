#!/usr/bin/env bash
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

CONTEXT_PATH="${1:-}"
if [[ ! -d "${CONTEXT_PATH}" ]]; then
  echo "ERROR: invalid argument '${CONTEXT_PATH}'. Must be a subfolder of '${SCRIPT_FOLDER}'}"
  exit 1
fi
BUILD_ARGS="${CONTEXT_PATH}/build-args.json"

DOCKER_REPO="$(jq -r '.docker.repository' "${BUILD_ARGS}")"
VERSION="$(jq -r '.jenkins.version' "${BUILD_ARGS}")"
IMAGE="${DOCKER_REPO}/$(basename "$(readlink -f "${SCRIPT_FOLDER}")")"

docker build --rm -t "${IMAGE}:${VERSION}" \
  --build-arg JENKINS_VERSION="${VERSION}" \
  --build-arg USERNAME="$(jq -r '.docker.master.username' "${BUILD_ARGS}")" \
  --build-arg JENKINS_HOME="$(jq -r '.docker.master.home' "${BUILD_ARGS}")" \
  --build-arg JENKINS_REF="$(jq -r '.docker.master.ref' "${BUILD_ARGS}")" \
  --build-arg JENKINS_WEB_ROOT="$(jq -r '.docker.master.webroot' "${BUILD_ARGS}")" \
  --build-arg JENKINS_PLUGIN_ROOT="$(jq -r '.docker.master.pluginroot' "${BUILD_ARGS}")" \
  --build-arg JENKINS_WAR="$(jq -r '.docker.master.war' "${BUILD_ARGS}")" \
  --build-arg JENKINS_UC="$(jq -r '.docker.master.updateCenter' "${BUILD_ARGS}")" \
  -f "${CONTEXT_PATH}/Dockerfile" "${CONTEXT_PATH}"

latest_version=$("${SCRIPT_FOLDER}/../.jsonnet/jsonnet" "${SCRIPT_FOLDER}/releases.libsonnet" | jq -r '.latest.jenkins.version')
if [[ "${latest_version}" = "${VERSION}" ]]; then
  docker tag "${IMAGE}:${VERSION}" "${IMAGE}:latest"
fi