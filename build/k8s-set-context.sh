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

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '${LOCAL_CONFIG}' does not exists"
  echo "Create one to configure the location of the kubeconfig file and the associated context. Example:"
  echo '{"kubeconfig": { "path": "~/.kube/config", "contextMapping": { "okd-c1": "okd", "ci-c1": "openshift" }}}' | jq -M
  exit 1
fi

CONTEXT_MAPPING="${1}"

if ! jq -e '.kubeconfig.path' <"${LOCAL_CONFIG}" > /dev/null; then
  echo "ERROR: File '${LOCAL_CONFIG}' does not contain proper configuration"
  echo "Create one to configure the location of the kubeconfig file and the associated context. Example:"
  echo '{"kubeconfig": { "path": "~/.kube/config", "contextMapping": { "okd-c1": "okd", "ci-c1": "openshift" }}}' | jq -M
  exit 2
fi

KUBECONFIG="$(jq -r '.kubeconfig.path' <"${LOCAL_CONFIG}")"
KUBECONFIG="$(readlink -f "${KUBECONFIG/#~\//${HOME}/}")"

if [[ ! -f "${KUBECONFIG}" ]]; then
  echo "ERROR: Cannot find kubeconfig file '${KUBECONFIG}'"
  exit 2
fi

if ! jq -e '.kubeconfig.contextMapping["'"${CONTEXT_MAPPING}"'"]' <"${LOCAL_CONFIG}" > /dev/null; then
  echo "ERROR: Cannot find contextMapping for give '${CONTEXT_MAPPING}' in ${LOCAL_CONFIG})"
  exit 3
fi

export KUBECONFIG

CURRENT_CONTEXT="$(kubectl config current-context)"
TARGET_CONTEXT="$(jq -r '.kubeconfig.contextMapping["'"${CONTEXT_MAPPING}"'"]' <"${LOCAL_CONFIG}")"
if [[ "${CURRENT_CONTEXT}" != "${TARGET_CONTEXT}" ]]; then
  # Be sure to restore context once calling script exits
  trap "kubectl config use-context ""${CURRENT_CONTEXT}"" > /dev/null" SIGINT SIGTERM ERR EXIT

  # switch to given context 
  kubectl config use-context "${TARGET_CONTEXT}"
fi