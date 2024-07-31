#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# * Call gen-permissions.sh script
# * Call gen-yaml.sh script

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

target="${instance}/target/jenkins"
mkdir -p "${target}"

jenkinsTemplateFolder="${SCRIPT_FOLDER}/../templates/jenkins"
jenkinsActualVersion="$(jq -r '.jiroMaster.version' "${instance}/target/config.json")"
if [[ -d "${jenkinsTemplateFolder}/${jenkinsActualVersion}" ]]; then
  jenkinsTemplateFolder="${SCRIPT_FOLDER}/../templates/jenkins/${jenkinsActualVersion}"
fi

jenkinsTheme="$(jq -r '.jenkins.theme' "${instance}/target/config.json")"
echo "/* GENERATED FILE - DO NOT EDIT */" > "${target}/${jenkinsTheme}.css.override"
hbs -s -D "${instance}/target/config.json" "${jenkinsTemplateFolder}/${jenkinsTheme}.css.hbs" >> "${target}/${jenkinsTheme}.css.override"

displayName="$(jq -r '.project.displayName' "${instance}/target/config.json")"
fullName="$(jq -r '.project.fullName' "${instance}/target/config.json")"
cat <<EOF > "${target}/title.js"
document.title = "${displayName} - " + document.title;
document.addEventListener('DOMContentLoaded', function() {
    let header = document.querySelector('.page-header__brand');
    if (header) {
        let newLink = document.createElement('a');
        newLink.href = 'https://github.com/eclipse-cbi/jiro/blob/master/instances/${fullName}/target/config.json';
        newLink.textContent = 'JIRO';
        newLink.style = 'color: white; border-left: 1px solid white; padding-left: 1em; font-size: 1.1em; position: relative; top: 0.2em; left: -1.6em;';
        newLink.target = '_blank';
        newLink.title = 'JIRO Configuration as Code';
        header.appendChild(newLink);
    } else {
        console.log('Element with class "header" not found.');
    }
});
EOF

mkdir -p "${target}/partials"
"${SCRIPT_FOLDER}/gen-permissions.sh" "${instance}/target/config.json" > "${target}/partials/permissions.hbs"

"${SCRIPT_FOLDER}/gen-yaml.sh" "${instance}/jenkins/configuration.yml" "${jenkinsTemplateFolder}/configuration.yml.hbs" "${instance}/target/config.json" "${target}/partials" > "${target}/configuration.yml"
