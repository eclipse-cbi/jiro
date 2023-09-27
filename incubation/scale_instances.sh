#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

#TODO: improve script to allow scaling sets of JIPPs (e.g. automotive.*)

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

COMMAND="${1:-}"

# check that project name is not empty
if [[ -z "${COMMAND}" ]]; then
  printf "ERROR: a command must be given ('up' or 'down').\n"
  exit 1
fi

if [[ "${COMMAND}" != "up" ]] && [[ "${COMMAND}" != "down" ]]; then
  printf "ERROR: command must be 'up' or 'down'.\n"
  exit 1
fi


counter=0
for instance in ../instances/*; do
  instance_name="$(basename "${instance}")"
  short_name="${instance_name##*.}"
  #echo "Short name: ${short_name}"

  namespace="$(jq -r '.clouds.kubernetes.namespace' < "${instance}/target/config.json")"
  if [[ "${COMMAND}" == "down" ]]; then
    replicas="0"
  else
    replicas="1"
  fi
  if [[ "$(oc get sts -n 4diac 4diac -o "jsonpath={.spec.replicas}")" != "${replicas}" ]]; then
    echo "oc scale statefulset ${short_name} -n=${namespace} --replicas=${replicas}"
    oc scale statefulset "${short_name}" -n="${namespace}" --replicas="${replicas}"
    if [[ "${replicas}" -eq "1" ]]; then
      sleep 5
    fi
  else
    echo "${short_name} already scaled to ${replicas}."
  fi
  counter=$((counter +1))
  echo "Counter: ${counter}"
done

echo "Scaled ${COMMAND} ${counter} CI instances."
