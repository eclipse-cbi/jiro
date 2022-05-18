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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
CLI="${SCRIPT_FOLDER}/jenkins-cli.sh"

instance="${1:-}"
backup="${2:-}"

if [[ -z "${instance}" ]]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ -z "${backup}" ]]; then
  echo "ERROR: you must provide a 'backup' folder name"
  exit 1
fi

if [[ ${instance} == "ALL" ]]; then
  for i in "${SCRIPT_FOLDER}/instances/"*; do 
    >&2 echo "** Backing up instance '$(basename "${i}")'..."
    "${BASH_SOURCE[0]}" "${i}" "${backup}" || :
  done
  exit 0
elif [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

backupInstance="${backup}/$(basename "${instance}")"

rm -rf "${backupInstance}"
mkdir -p "${backupInstance}/jobs"
mkdir -p "${backupInstance}/views"

no_of_processes=4
for job in $("${CLI}" "${instance}" list-jobs); do
  while [ "$(jobs | wc -l)" -ge ${no_of_processes} ] ; do sleep 1 ; done
  >&2 echo "Backing up job '${job}'..."
  "${CLI}" "${instance}" get-job "${job}" > "${backupInstance}/jobs/${job}.xml" &
done

for view in $("${CLI}" "${instance}" groovy = < "${SCRIPT_FOLDER}/groovy/cli/list-views.groovy"); do
  while [ "$(jobs | wc -l)" -ge ${no_of_processes} ] ; do sleep 1 ; done
  >&2 echo "Backing up view '${view}'..."
  "${CLI}" "${instance}" get-view "${view}" > "${backupInstance}/views/${view}.xml" &
done

>&2 echo "Backing up credentials..."
"${CLI}" "${instance}" list-credentials-as-xml > "${backupInstance}/credentials.xml" "system::system::jenkins" &

>&2 echo "Backing up plugins list..."
"${CLI}" "${instance}" list-plugins > "${backupInstance}/plugins"