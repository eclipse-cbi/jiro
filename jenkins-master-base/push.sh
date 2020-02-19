#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
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

BUILD_ARGS="$(mktemp)"
"${SCRIPT_FOLDER}/../.jsonnet/jsonnet" "${CONTEXT_PATH}/build-args.jsonnet" > "${BUILD_ARGS}"

DOCKER_REPO="$(jq -r '.docker.repository' "${BUILD_ARGS}")"
VERSION="$(jq -r '.jenkins.version' "${BUILD_ARGS}")"
IMAGE="${DOCKER_REPO}/$(basename "$(readlink -f "${SCRIPT_FOLDER}")")"

docker push "${IMAGE}:${VERSION}"

rm -f "${BUILD_ARGS}"

latest_version=$("${SCRIPT_FOLDER}/../.jsonnet/jsonnet" "${SCRIPT_FOLDER}/releases.libsonnet" | jq -r '.releases.latest.jenkins.version')
if [[ "${latest_version}" = "${VERSION}" ]]; then
  docker push "${IMAGE}:latest"
fi