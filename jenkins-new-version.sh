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
SCRIPT_NAME="$(basename "${0}")"
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

version="${1:-}"
is_latest="${2:-true}"

usage() {
  printf "Usage: %s version [is_latest=true]\n" "${SCRIPT_NAME}"
  printf "\t%-16s The new Jenkins version you want to create an image for (e.g. 2.150.3).\n" "version"
  printf "\t%-16s Whether the specified Jenkins version should be considered the latest one (default to true).\n" "is_latest"
}

# check that version is not empty
if [[ -z "${version}" ]]; then
 printf "ERROR: a version must be given.\n"
 usage
 exit 1
fi

mkdir -p "${SCRIPT_FOLDER}/jenkins-master-base/${version}"
cp -rf "${SCRIPT_FOLDER}/jenkins-master-base/latest/"* "${SCRIPT_FOLDER}/jenkins-master-base/${version}/"
rm "${SCRIPT_FOLDER}/jenkins-master-base/${version}/cli.jar"

if [[ "${is_latest}" = "true" ]]; then
  rm "${SCRIPT_FOLDER}/jenkins-master-base/latest"
  ln -s "${version}" "${SCRIPT_FOLDER}/jenkins-master-base/latest"
fi