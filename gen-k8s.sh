#! /usr/bin/env bash
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
templates="${SCRIPT_FOLDER}/templates"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

tpl_config="${instance}/target/config.properties"
. "${tpl_config}"

target="${instance}/target/k8s"
mkdir -p "${target}"

gen_resource() {
  local r="${1}"
  local t="${2:-"${r}"}"
  ${SCRIPT_FOLDER}/gen-yaml.sh "${instance}/k8s/${r}.yml" "${templates}/k8s/${r}.yml.tpl" "${tpl_config}" > "${target}/${t}.yml"
}

gen_resource "namespace"
gen_resource "route"
gen_resource "service-jenkins-ui"
gen_resource "service-jenkins-discovery"
gen_resource "service-account"
gen_resource "role"
gen_resource "role-binding"
gen_resource "configmap-jenkins-config"

# For stateful set, we want to set the image sha
imageSha="$(docker inspect --format='{{index .RepoDigests 0}}' "${JENKINS_MASTER_IMAGE}:${JENKINS_MASTER_IMAGE_TAG}" | sed -E 's/.*sha256:(.*)/\1/g')"
gen_resource "statefulset"
sed -i -e "s/{{JENKINS_MASTER_IMAGE_SHA256}}/${imageSha}/g" "${target}/statefulset.yml"

## Jenkins CaC config map filling
tmp=$(mktemp)
${SCRIPT_FOLDER}/gen-yaml.sh "${instance}/jenkins/configuration.yml" "${templates}/jenkins/configuration.yml.tpl" "${tpl_config}" > "${tmp}"
for l in $(cat ${tmp}); do
  echo "    ${l}" >> "${target}/configmap-jenkins-config.yml"
done
rm "${tmp}"

gen_resource "limit-range-default"
gen_resource "limit-range-${JENKINS_RESPACK_ID}" "limit-range"
gen_resource "resource-quotas-${JENKINS_RESPACK_ID}" "resource-quotas"