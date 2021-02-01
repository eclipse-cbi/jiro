#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018-2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# * Call gen-jenkins.sh script
# * Call gen-dockerfile.sh script
# * Build dockerfile
export LOG_LEVEL="${LOG_LEVEL:-600}"
# shellcheck disable=SC1090
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.bashtools/bashtools"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PATH="${SCRIPT_FOLDER}/../.dockertools:${PATH}"

PUSH_IMAGES="${PUSH_IMAGES:-"true"}"

INSTANCE="${1:-}"
if [ -z "${INSTANCE}" ]; then
  ERROR "you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${INSTANCE}" ]; then
  ERROR "no 'instance' at '${INSTANCE}'"
  exit 1
fi

"${SCRIPT_FOLDER}/gen-jenkins.sh" "${INSTANCE}"

TOOLS_IMAGE="eclipsecbi/adoptopenjdk-coreutils:openjdk11-openj9-alpine-slim"
CONFIG_JSON="${INSTANCE}/target/config.json"

install_additional_plugins() {
  local build_dir
  build_dir="$(readlink -f "${INSTANCE}/target/jenkins")"
  
  INFO "Downloading plugin manager tool"
  download ifmodified "$(jq -r '.jiroMaster.plugin_manager.jar' "${CONFIG_JSON}")" "${build_dir}/tools/jenkins-plugin-manager.jar"

  rm -rf "${build_dir}/ref"
  mkdir -p "${build_dir}/ref"
  mkdir -p "${SCRIPT_FOLDER}/../.cache"

  local war_file parent_image
  war_file="$(jq -r '.jiroMaster.war' "${CONFIG_JSON}")"
  parent_image="$(jq -r '.jiroMaster.docker.registry' "${CONFIG_JSON}")/$(jq -r '.jiroMaster.docker.repository' "${CONFIG_JSON}")/$(jq -r '.jiroMaster.docker.image' "${CONFIG_JSON}"):$(jq -r '.jiroMaster.docker.tag' "${CONFIG_JSON}")"
  local image_wd="/workdir"

  INFO "Retrieving installed plugins from parent image ${parent_image}"
  docker run -u "$(id -u):$(id -g)" --rm \
    -v "${build_dir}:${image_wd}" \
    --entrypoint "" \
    "${parent_image}" \
    /bin/bash -c \
      "cp -rf '$(jq -r '.jiroMaster.ref' "${CONFIG_JSON}")/plugins' ${image_wd}/ref/plugins/ \
      && cp '${war_file}' ${image_wd}" |& TRACE

  INFO "Downloading additional plugins"
  local update_center 
  update_center="$(jq -r '.jiroMaster.updateCenter' "${CONFIG_JSON}")"
  docker run -u "$(id -u):$(id -g)" --rm \
    -v "${build_dir}:${image_wd}" \
    -v "${build_dir}/scripts:/usr/local/bin" \
    -v "$(readlink -f "${SCRIPT_FOLDER}/../.cache"):/cache" \
    -w "${image_wd}" \
    -e HOME="${image_wd}" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "export CACHE_DIR=/cache && \
      java -jar ./tools/jenkins-plugin-manager.jar \
        --plugin-file plugins-list.txt \
        --list \
        --view-security-warnings \
        --plugin-download-directory '${image_wd}/ref/plugins' \
        --jenkins-update-center '${update_center}' \
        --war '${image_wd}/$(basename "${war_file}")' > ${image_wd}/plugins.log" | TRACE
}

mkdir -p "${INSTANCE}/target/jenkins/ref/plugins"
if [[ -f "${INSTANCE}/jenkins/plugins-list" ]]; then
  INFO "Some additional plugins need to be installed"
  install_additional_plugins
fi

image="$(jq -r '.docker.master.registry' "${CONFIG_JSON}")/$(jq -r '.docker.master.repository' "${CONFIG_JSON}")/$(jq -r '.docker.master.image' "${CONFIG_JSON}")"
tag="$(jq -r '.docker.master.tag' "${CONFIG_JSON}")"
dockerfile="${INSTANCE}/target/Dockerfile"

INFO "Generating ${dockerfile}"
jq -r '.docker.master.dockerfile' "${CONFIG_JSON}" > "${dockerfile}"

INFO "Building ${image}:${tag} from ${dockerfile} (push=${PUSH_IMAGES})"
dockerw build "${image}" "${tag}" "${dockerfile}" "$(dirname "${dockerfile}")" "${PUSH_IMAGES}" false