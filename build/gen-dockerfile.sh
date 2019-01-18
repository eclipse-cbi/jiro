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
templates="${SCRIPT_FOLDER}/../templates"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

target="${instance}/target"
mkdir -p "${target}"

echo -e "# GENERATED FILE - DO NOT EDIT\n" > "${target}/Dockerfile"
if [ -f "${instance}/Dockerfile.override" ]; then
  # if a Dockerfile.override exists, take it and quit
  echo "# <instances/${instance}/Dockerfile.override>" >> "${target}/Dockerfile"
  sed -e '$s/$/\n/' "${instance}/Dockerfile.override" >> "${target}/Dockerfile"
  echo -e "# </instances/${instance}/Dockerfile.override>\n" >> "${target}/Dockerfile"
else 
  cat "${templates}/docker/Dockerfile.hbs" >> "${target}/Dockerfile"
  # if Dockefile exists, append it to the template
  if [ -f "${instance}/Dockerfile" ]; then
    echo "# <instances/${instance}/Dockerfile>" >> "${target}/Dockerfile"
    sed -e '$s/$/\n/' "${instance}/Dockerfile" >> "${target}/Dockerfile"
    echo -e "# </instances/${instance}/Dockerfile>\n" >> "${target}/Dockerfile"
  fi
fi
# apply template
hbs -s -D "${target}/config.json" "${target}/Dockerfile" > "${target}/Dockerfile.gen"
mv "${target}/Dockerfile.gen" "${target}/Dockerfile"

# Then add the variable parts of Dockerfile depending on instance configuration
echo "# <gen-dockerfile.sh>" >> "${target}/Dockerfile"

if [[ -f "${instance}/jenkins/plugins-list" ]]; then
  echo "COPY jenkins/plugins-list /usr/share/jenkins/ref/plugins-list" >> "${target}/Dockerfile"
  echo "RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins-list" >> "${target}/Dockerfile"
fi

echo "USER 10001" >> "${target}/Dockerfile"

echo -e "# </gen-dockerfile.sh>\n" >> "${target}/Dockerfile"
