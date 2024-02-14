#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generate YAML files

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

yml_source="${1:-}"
template="${2:-}"
config="${3:-}"
partials="${4:-}"

if [[ -z ${yml_source} ]]; then
  echo "ERROR: must give an non-empty yaml source file name" >&2
  exit 1
fi

if [[ -z ${template} ]]; then
  echo "ERROR: must give an template file" >&2
  exit 1
fi

if [[ ! -f "${template}" ]]; then
  echo "ERROR: no file exist '${template}'" >&2
  exit 1
fi

expand_templated_yaml() {
  local yml_source="${1}"
  local template_dirname="${2}"
  local config="${3}"
  local partials="${4:-}"

  if [[ -n "${partials}" ]]; then
    hbs -s -D "${config}" -H "${template_dirname}"'/helpers/*.js' -P "${template_dirname}"'/partials/*.hbs' -P "${partials}"'/*.hbs' "${yml_source}"
  else
    hbs -s -D "${config}" -H "${template_dirname}"'/helpers/*.js' -P "${template_dirname}"'/partials/*.hbs' "${yml_source}"
  fi
}

tmp=$(mktemp)

if [[ -f "${yml_source}" ]]; then

  expanded_src=$(mktemp)
  expand_templated_yaml "${yml_source}" "$(dirname "${template}")" "${config}" "${partials}" > "${expanded_src}"
  expanded_tpl=$(mktemp)
  expand_templated_yaml "${template}" "$(dirname "${template}")" "${config}" "${partials}" > "${expanded_tpl}"
  # shellcheck disable=SC2016
  yq eval-all '. as $item ireduce ({}; . * $item )' "${expanded_tpl}" "${expanded_src}" > "${tmp}"
  rm "${expanded_src}" "${expanded_tpl}"
elif [[ -f "${yml_source}.override" ]]; then
  cp "${yml_source}.override" "${tmp}"
else
  cp "${template}" "${tmp}"
fi

echo "# GENERATED FILE - DO NOT EDIT"

expand_templated_yaml "${tmp}" "$(dirname "${template}")" "${config}" "${partials}"| yq

