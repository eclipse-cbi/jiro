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
#script_name="$(basename "${BASH_SOURCE[0]}")"
script_folder="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

open_url() {
  local url=$1
  if which xdg-open > /dev/null; then # most Linux
    xdg-open "${url}"
  elif which open > /dev/null; then # macOS
    open "${url}"
  fi
}

for f in "${@}"; do
  project_name="$(basename "${f}")"
  short_name=${project_name##*.}
  echo "${short_name}"
  url="$(jsonnet "${script_folder}/../instances/${project_name}/jiro.jsonnet" | jq -r '.["config.json"].deployment.url')"

  open_url "${url}"
done
# check if staging or not
# check if project name or short name


