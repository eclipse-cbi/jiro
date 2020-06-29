#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
#script_name="$(basename "${BASH_SOURCE[0]}")"
script_folder="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

for f in "${@}"; do
  project_name="$(basename "${f}")"
  echo "${project_name}"
  make -C "${script_folder}/.." "deploy_${project_name}"
done
