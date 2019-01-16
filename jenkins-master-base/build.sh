#!/usr/bin/env bash
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

PATH=${SCRIPT_FOLDER}/../bin:${PATH}

DOCKER_REPO="$(head -n 1 ${SCRIPT_FOLDER}/../repositoryName)"
IMAGE="${DOCKER_REPO}/$(basename $(readlink -f ${SCRIPT_FOLDER}))"

if [[ ! -d "${1:-}" ]]; then
  echo "ERROR: invalid argument '${1:-}'. Must be a subfolder of '${SCRIPT_FOLDER}'}"
  exit 1
fi

VERSION=$(basename ${1:-})

. "${SCRIPT_FOLDER}/${VERSION}/build-args.shsource"

mapfile -t tpl_vars < <(compgen -A variable | grep "^JENKINS_")

docker_build_arg=()
for v in ${tpl_vars[@]}; do 
  docker_build_arg+=( "--build-arg" )
  docker_build_arg+=( "${v}=${!v}" )
done

docker build --rm -t ${IMAGE}:${VERSION} \
  --build-arg JENKINS_VERSION=${VERSION} "${docker_build_arg[@]}" \
  -f "${SCRIPT_FOLDER}/${VERSION}/Dockerfile" "${SCRIPT_FOLDER}/${VERSION}"

latest_version=$(find ${SCRIPT_FOLDER} -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V | tail -n 1)

if [[ "${latest_version}" = "${VERSION}" ]]; then
  docker tag "${IMAGE}:${VERSION}" "${IMAGE}:latest"
fi