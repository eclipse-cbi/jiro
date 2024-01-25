#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
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

# Usage: ./check_version.sh ../instances/foundation-internal.*

if [[ "${#}" -eq 0 ]]; then
  echo "ERROR: you must provide at least one 'instance' path"
  exit 1
fi

for instance in "${@}"; do
  project_name="$(basename "${instance}")"
  url="$(jq -r '.deployment.url' "${instance}/target/config.json")"
  # version="$(curl -sLI "${url}" | grep -i 'x-jenkins' | grep -v 'x-jenkins-session' | awk '{print $2}')"
  echo "${project_name} ${url} $(curl -sLI "${url}" | grep -i 'x-jenkins' | grep -v 'x-jenkins-session' | awk '{print $2}')"
done | column -t
