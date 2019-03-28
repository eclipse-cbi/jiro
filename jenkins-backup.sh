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
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

instance="${1:-}"
backup="${2:-}"

if [[ -z "${instance}" ]]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ -z "${backup}" ]]; then
  echo "ERROR: you must provide an 'backup' folder name"
  exit 1
fi

if [[ ${instance} == "ALL" ]]; then
  for i in ${SCRIPT_FOLDER}/instances/*; do 
    >&2 echo "Backuping instance '$(basename ${i})'..."
    "${0}" "${i}" "${backup}" || :
  done
  exit 0
elif [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

instanceBackup="${backup}/$(basename "${instance}")"

rm -rf "${instanceBackup}"
mkdir -p "${instanceBackup}/jobs"
mkdir -p "${instanceBackup}/views"


for job in $(${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" list-jobs); do 
  >&2 echo "Backuping job '${job}'..."
  ${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" get-job "${job}" > "${instanceBackup}/jobs/${job}.xml"
done

for view in $(${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" groovy = < "${SCRIPT_FOLDER}/groovy/cli/list-views.groovy"); do 
  >&2 echo "Backuping view '${view}'..."
  ${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" get-view "${view}" > "${instanceBackup}/views/${view}.xml"
done

>&2 echo "Backuping credentials..."
${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" list-credentials-as-xml > "${instanceBackup}/credentials.xml" "system::system::jenkins"

>&2 echo "Backuping plugins list..."
${SCRIPT_FOLDER}/jenkins-cli.sh "${instance}" list-plugins > "${instanceBackup}/plugins"