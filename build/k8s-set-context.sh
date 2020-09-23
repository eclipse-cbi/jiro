#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
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

if [[ ! -f "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig" ]]; then
  echo "ERROR: File '$(readlink -f "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig")' does not exists"
  echo "Create one to configure the location of the kubeconfig file and the associated context. Example:"
  echo '{"kubeconfig": { "path": "~/.kube/config", "contextMapping": { "okd-c1": "okd", "ci-c1": "openshift" }}}' | jq -M
  exit 1
fi

CONTEXT_MAPPING="${1}"

KUBECONFIG="$(jq -r '.kubeconfig.path' <"$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig")"
KUBECONFIG="$(readlink -f "${KUBECONFIG/#~\//${HOME}/}")"

if [[ ! -f "${KUBECONFIG}" ]]; then
  echo "ERROR: Cannot find kubeconfig file '${KUBECONFIG}'"
  exit 2
fi

if ! jq -e '.kubeconfig.contextMapping["'"${CONTEXT_MAPPING}"'"]' <"$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig" > /dev/null; then
  echo "ERROR: Cannot find contextMapping for give '${CONTEXT_MAPPING}' in $(readlink -f "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig")"
  exit 3
fi

export KUBECONFIG

CURRENT_CONTEXT="$(kubectl config current-context)"
TARGET_CONTEXT="$(jq -r '.kubeconfig.contextMapping["'"${CONTEXT_MAPPING}"'"]' <"$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.localconfig")"
if [[ "${CURRENT_CONTEXT}" != "${TARGET_CONTEXT}" ]]; then
  # Be sure to restore context once calling script exits
  trap "kubectl config use-context ""${CURRENT_CONTEXT}""" SIGINT SIGTERM ERR EXIT

  # switch to given context 
  kubectl config use-context "${TARGET_CONTEXT}"
fi