#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2025 Eclipse Foundation and others.
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

dockerfile="maintenance.Dockerfile"
#docker_registry="docker-registry.eclipse.org/"
docker_registry=""
docker_repository="eclipsecbi"
image_name="maintenance-curtain"

docker build -t "${docker_registry}${docker_repository}/${image_name}:latest" -f "${dockerfile}" .
docker push "${docker_registry}${docker_repository}/${image_name}:latest"
