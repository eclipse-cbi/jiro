#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Check for "queueItemAuthenticator" JCasC race condition(?)

# Bash strict-mode
#set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
#script_name="$(basename "${BASH_SOURCE[0]}")"
#SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

CI_HOST="https://ci.eclipse.org"

if [[ "${#}" -eq 0 ]]; then
  echo "ERROR: you must provide at least one 'instance' path"
  exit 1
fi

#no_of_processes=4
for instance in "${@}"; do
  #while [ $(jobs | wc -l) -ge ${no_of_processes} ] ; do sleep 1 ; done
  project_name="$(basename "${instance}")"
  printf "%s: " "${project_name}"
  short_name="${project_name##*.}"

  if [[ "${short_name}" == "webdev" ]] || [[ "${short_name}" == "infra" ]]; then
    CI_HOST="https://foundation.eclipse.org/ci"
  fi

  #TODO: wrap with &

  if curl -SsL "${CI_HOST}/${short_name}" | grep "queueItemAuthenticator" > /dev/null; then
    echo "ERROR"
  else
    echo "OK"
  fi
done
