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
: "${TEMPLATE_VARIABLE_PREFIX:="JENKINS_"}"

template="${1}"
tpl_config="${2}"

if [[ ! -f "${tpl_config}" ]]; then
  echo "ERROR: no configuration file '${tpl_config}'"
  exit 1
fi

. "${tpl_config}"

tmp=$(mktemp)

cp "${template}" "${tmp}"
mapfile -t tpl_vars < <(compgen -A variable | grep "^${TEMPLATE_VARIABLE_PREFIX}")
for v in ${tpl_vars[@]}; do 
  value=$(echo ${!v} | sed -e 's#/#\\/#g')
  sed -i -e "s/{{${v}}}/${value}/g" "${tmp}"
done

cat "${tmp}"

rm "${tmp}"