#!/usr/bin/env bash
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

WEBROOT="${1:-}"
CONTROL_PORT="${2:-}"
PREFIX=${3:-}
GRACE_PERIOD_SECONDS="${4:-180}"
CONTROL_HOST="${CONTROL_HOST:-localhost}"

runningBuilds() {
  local url="${1}"
  curl -gSs "${CONTROL_HOST}/${PREFIX}"'/computer/api/json?depth=2&tree=computer[displayName,executors[currentExecutable[*]],oneOffExecutors[currentExecutable[*]]]' | jq -c '.computer | map({name: .displayName?, executors: (.executors? + .oneOffExecutors?) | map(select(.currentExecutable != null)) | map(.currentExecutable | {name: .fullDisplayName, url: .url}) })'
}

log() {
  echo "$(date -Iseconds) "
}

## quiet-down first

builds=$(runningBuilds "${url}")
buildsCount=$(echo "${builds}" | jq -r 'map(.executors[]) | length')
if [[ "${buildsCount}" -gt 0 ]]; then
  echo "INFO: There are still ${buildsCount} builds running:"
  echo "${builds}" | jq -r 'map(.executors[].name)[]'
  echo -n "INFO: Waiting for builds to complete (timeout=${GRACE_PERIOD_SECONDS}s)"

  startTime=$(date +%s)
  while [[ "${buildsCount}" -gt 0 ]]; do
    builds=$(runningBuilds "${url}")
    buildsCount=$(echo "${builds}" | jq -r 'map(.executors[]) | length')
    sleep 10
    if [[ $((startTime + GRACE_PERIOD_SECONDS)) -lt $(date +%s) ]]; then
      echo ""
      echo "INFO: Timeout after ${GRACE_PERIOD_SECONDS}s, still ${buildsCount} builds running. The following builds will be forcibly terminated"
      echo "${builds}" | jq -r 'map(.executors[].name)[]'
      break
    fi
    echo -n "."
  done

  echo -e "\b."
fi

java -cp "${WEBROOT}/winstone.jar" winstone.tools.WinstoneControl shutdown --host="${CONTROL_HOST}" --port="${CONTROL_PORT}"
