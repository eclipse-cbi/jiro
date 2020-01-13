#! /usr/bin/env bash
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
templates="${SCRIPT_FOLDER}/../templates"

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

target="${instance}/target/k8s"
mkdir -p "${target}"

gen_resource() {
  local r="${1}"
  local t="${2:-"${r}"}"
  "${SCRIPT_FOLDER}/gen-yaml.sh" "${instance}/k8s/${r}.yml" "${templates}/k8s/${r}.yml.hbs" "${config}" > "${target}/${t}.yml"
}

# gen_resource "namespace"
rm -f "${target}/namespace.yml"

# gen_resource "route"
rm -f "${target}/route.yml"
# gen_resource "service-jenkins-ui"
rm -f "${target}/service-jenkins-ui.yml"
# gen_resource "service-jenkins-discovery"
rm -f "${target}/service-jenkins-discovery.yml"
# gen_resource "service-account"
rm -f "${target}/service-account.yml"
# gen_resource "role"
rm -f "${target}/role.yml"
# gen_resource "role-binding"
rm -f "${target}/role-binding.yml"
# gen_resource "statefulset"
rm -f "${target}/statefulset.yml"
# gen_resource "tools-pv"
rm -f "${target}/tools-pv.yml"
# gen_resource "known-hosts"
rm -rf "${target}/known-hosts.yml"
# gen_resource "m2-dir"
rm -rf "${target}/m2-dir.yml"

## Jenkins CaC config map filling
echo "# GENERATED FILE - DO NOT EDIT" >> "${target}/configmap-jenkins-config.yml"
hbs -s -D "${config}" -P "${templates}"'/k8s/partials/*.hbs' -P "${instance}"'/target/jenkins/*.yml' "${templates}/k8s/configmap-jenkins-config.yml.hbs" > "${target}/configmap-jenkins-config.yml"

# sponsorshipLevel="$(jq -r '.project.sponsorshipLevel' "${config}")"
# gen_resource "limit-range-${sponsorshipLevel}" "limit-range"
rm -f "${target}/limit-range.yml"

# gen_resource "resource-quotas-${sponsorshipLevel}" "resource-quotas"
rm -f "${target}/resource-quotas.yml"