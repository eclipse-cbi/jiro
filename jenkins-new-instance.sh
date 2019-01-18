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

full_name="${1}"
short_name="${2}"
display_name="${3}"

mkdir -p "${SCRIPT_FOLDER}/instances/${full_name}"
>  "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '{\n'
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '  "project": {\n'
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '    "fullName": "%s",\n' $full_name
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '    "shortName": "%s",\n' $short_name
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '    "displayName": "%s"\n' $display_name
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '  }\n'
>> "${SCRIPT_FOLDER}/instances/${full_name}/config.json" printf '}\n'
