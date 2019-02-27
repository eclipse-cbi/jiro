#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
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

SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

CONTEXT_PATH="${1:-}"
if [[ ! -d "${CONTEXT_PATH}" ]]; then
  echo "ERROR: invalid argument '${CONTEXT_PATH}'. Must be a subfolder of '${SCRIPT_FOLDER}'}"
  exit 1
fi
VERSION=$(basename ${CONTEXT_PATH})
BUILD_ARGS="${CONTEXT_PATH}/build-args.json"

DOCKER_REPO="$(jq -r '.docker.repository' "${BUILD_ARGS}")"
IMAGE="${DOCKER_REPO}/$(basename $(readlink -f ${SCRIPT_FOLDER}))"

docker build --rm -t ${IMAGE}:${VERSION} \
  -f "${CONTEXT_PATH}/Dockerfile" "${CONTEXT_PATH}"

latest_version=$(find ${SCRIPT_FOLDER} -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V | tail -n 1)
if [[ "${latest_version}" = "${VERSION}" ]]; then
  docker tag "${IMAGE}:${VERSION}" "${IMAGE}:latest"
fi