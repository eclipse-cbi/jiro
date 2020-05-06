#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018-2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# * Call gen-jenkinss.sh script
# * Call gen-dockerfile.sh script
# * Build dockerfile
export LOG_LEVEL="${LOG_LEVEL:-600}"
# shellcheck disable=SC1090
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.bashtools/bashtools"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"
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
"${SCRIPT_FOLDER}/gen-dockerfile.sh" "${INSTANCE}"

TOOLS_IMAGE="eclipsecbi/adoptopenjdk-coreutils:openjdk8-openj9-alpine-slim"
CONFIG_JSON="${INSTANCE}/target/config.json"

install_additional_plugins() {
  local build_dir
  build_dir="$(readlink -f "${INSTANCE}/target/jenkins")"
  
  INFO "Downloading support scripts for plugins installation"
  download ifmodified "$(jq -r '.jiroMaster.scripts.install_plugins' "${CONFIG_JSON}")" "${build_dir}/tools/install-plugins.sh"
  download ifmodified "$(jq -r '.jiroMaster.scripts.jenkins_support' "${CONFIG_JSON}")" "${build_dir}/scripts/jenkins-support"
  chmod u+x "${build_dir}/tools/"*.sh

  rm -rf "${build_dir}/ref"
  mkdir -p "${build_dir}/ref"

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
    -w "${image_wd}" \
    -e HOME="${image_wd}" \
    --entrypoint "" \
    "${TOOLS_IMAGE}" \
    /bin/bash -c \
      "export REF='${image_wd}/ref' \
      && export JENKINS_WAR='${image_wd}/$(basename "${war_file}")' \
      && export JENKINS_UC='${update_center}' \
      && export CURL_RETRY='8' \
      && export CURL_RETRY_MAX_TIME='120' \
      && ./tools/install-plugins.sh < plugins-list" |& TRACE
}

if [[ -f "${INSTANCE}/jenkins/plugins-list" ]]; then
  INFO "Some additional plugins need to be installed"
  install_additional_plugins
fi

image="$(jq -r '.docker.master.registry' "${CONFIG_JSON}")/$(jq -r '.docker.master.repository' "${CONFIG_JSON}")/$(jq -r '.docker.master.image' "${CONFIG_JSON}")"
tag="$(jq -r '.docker.master.tag' "${CONFIG_JSON}")"
dockerfile="${INSTANCE}/target/Dockerfile"

INFO "Building ${image}:${tag} from ${dockerfile} (push=${PUSH_IMAGES})"
dockerw build "${image}" "${tag}" "${dockerfile}" "$(dirname "${dockerfile}")" "${PUSH_IMAGES}" false