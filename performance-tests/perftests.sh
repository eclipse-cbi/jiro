#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
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

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
export CONTEXT="${CONTEXT:-"okd-admin"}"

BUILD_SCRIPT="${1:-"${SCRIPT_FOLDER}/tests/dummy/run.sh"}"
TEST_NAME="$(basename "$(dirname "${BUILD_SCRIPT}")")"
LOG_FOLDER="${2:-"${SCRIPT_FOLDER}/results/${CONTEXT}-${TEST_NAME}-$(date -Iseconds)"}"

mkdir -p "${LOG_FOLDER}"

if [[ ${CONTEXT} =~ okd.* ]]; then
  NODE_ROLE="node-role.kubernetes.io/worker,role!=storage_node"
else
  NODE_ROLE="node-role.kubernetes.io/compute"
fi

kubectl --context="${CONTEXT}" get nodes -l "${NODE_ROLE}" -o json | jq -r '.items[]|select(.spec.unschedulable != true)|.metadata.labels["kubernetes.io/hostname"]' | \
  SHELL=$(type -p bash) parallel --eta --line-buffer --no-notice -j8 "${SCRIPT_FOLDER}/run-perftests.sh" "${BUILD_SCRIPT}" "${LOG_FOLDER}"

jq -s '.' "${LOG_FOLDER}"/*.json > "${LOG_FOLDER}/all.json"