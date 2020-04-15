#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"
script_folder="$(dirname $(readlink -f "${0}"))"

search_term="${1:-}"
default_host="ci.eclipse.org"

open_url() {
  local url=$1
  if which xdg-open > /dev/null; then
    xdg-open ${url}
  fi
}

for f in ../instances/*${search_term}*
do
  project_name=$(basename ${f})
  short_name=${project_name##*.}
  echo "${short_name}"
  if [[ $(grep -e '"host": "ci-staging.eclipse.org"' ../instances/${project_name}/config.jsonnet) ]]; then
    host="ci-staging.eclipse.org"
  else
    host="${default_host}"
  fi
  open_url "https://${host}/${short_name}"
done 
# check if staging or not
# check if project name or short name


