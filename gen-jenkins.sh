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

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

target="${instance}/target"

if [[ -f "${instance}/jenkins/plugins-list" ]]; then
  echo "# GENERATED FILE - DO NOT EDIT" > "${target}/jenkins-plugins-list"
  cat "${instance}/jenkins/plugins-list" >> "${target}/jenkins-plugins-list"
fi

tmp=$(mktemp)
echo "/* GENERATED FILE - DO NOT EDIT */" > "${tmp}"
cat "${SCRIPT_FOLDER}/templates/jenkins/eclipse-theme.css.tpl" >> "${tmp}"
${SCRIPT_FOLDER}/apply-template.sh "${tmp}" "${target}/config.properties" > "${target}/eclipse-theme.css.override"
rm "${tmp}"