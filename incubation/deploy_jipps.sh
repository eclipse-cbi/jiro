#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"
script_folder="$(dirname $(readlink -f "${0}"))"

#printf "make "
for f in ${@}
do
  project_name="$(basename ${f})"
  short_name=${project_name##*.}
  echo "${project_name}"
  pushd ../
  make deploy_${project_name}
  popd
#  printf "deploy_${project_name} "
done
