#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
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
SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

tpl_config="${instance}/target/config.properties"

if [[ ! -f "${tpl_config}" ]]; then
  echo "ERROR: no configuration file '${tpl_config}'"
  exit 1
fi

. "${tpl_config}"

oc scale sts ${JENKINS_STS_NAME} --replicas=0 -n ${JENKINS_NAMESPACE}
sleep 5
oc scale sts ${JENKINS_STS_NAME} --replicas=1 -n ${JENKINS_NAMESPACE}
