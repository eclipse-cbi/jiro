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

gen_resource "namespace"
gen_resource "route"
gen_resource "service-jenkins-ui"
gen_resource "service-jenkins-discovery"
gen_resource "service-account"
gen_resource "role"
gen_resource "role-binding"
gen_resource "statefulset"
gen_resource "tools-pv"
gen_resource "known-hosts"
gen_resource "m2-dir"

## Jenkins CaC config map filling
echo "# GENERATED FILE - DO NOT EDIT" >> "${target}/configmap-jenkins-config.yml"
hbs -s -D "${config}" -P "${templates}"'/k8s/partials/*.hbs' -P "${instance}"'/target/jenkins/*.yml' "${templates}/k8s/configmap-jenkins-config.yml.hbs" > "${target}/configmap-jenkins-config.yml"

sponsorshipLevel="$(jq -r '.project.sponsorshipLevel' "${config}")"
gen_resource "limit-range-${sponsorshipLevel}" "limit-range"
gen_resource "resource-quotas-${sponsorshipLevel}" "resource-quotas"