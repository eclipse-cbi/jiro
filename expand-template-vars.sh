#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
: "${TEMPLATE_VARIABLE_PREFIX:="JENKINS_"}"

echo "# GENERATED FILE - DO NOT EDIT"

for properties in ${@}; do 
    source ${properties}
done

mapfile -t tpl_vars < <(compgen -A variable | grep "^${TEMPLATE_VARIABLE_PREFIX}")
for tpl_var in "${tpl_vars[@]}"; do
  mapfile -t placeholders < <(echo ${!tpl_var} | grep -o "{{[^}]*}}" | tr -d "{}")
  while [[ "${!tpl_var}" =~ {{.*}} ]]; do
    for placeholder in "${placeholders[@]}"; do 
      value=$(echo ${!placeholder} | sed -e 's#/#\\/#g')
      declare ${tpl_var}=$(echo ${!tpl_var} | sed -e "s/{{${placeholder}}}/${value}/g")
    done
  done
  echo "declare -r ${tpl_var}=\"${!tpl_var}\""
done