#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script creates credentials in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename "${BASH_SOURCE[0]}")"
script_folder="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

LOCAL_CONFIG="${HOME}/.cbi/config"

if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi",'
  echo '                    "it-dir": "~/.password-store/it"}}'
fi

PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
export PASSWORD_STORE_DIR

source "${SCRIPT_FOLDER}/../pass/pass_wrapper.sh"

PROJECT_NAME="${1:-}"
SHORT_NAME="${PROJECT_NAME##*.}"

usage() {
  printf "%s <project_name>\n" "${script_name}"
  printf "\t%-16s the name of the project to add credentials to Jenkins\n" "project_name"
}

# check that project name is not empty
if [[ -z "${PROJECT_NAME}" ]]; then
  printf "ERROR: a project name must be given.\n"
  usage
  exit 1
fi

PROJECTS_STORAGE_PASS_DOMAIN="projects-storage.eclipse.org"
GIT_ECLIPSE_PASS_DOMAIN="git.eclipse.org"
GITHUB_PASS_DOMAIN="github.com"
GITLAB_PASS_DOMAIN="gitlab.eclipse.org"
GPG_PASS_DOMAIN="gpg"


create_domain() {
    local domain_name="${1:-}"
    echo "  Creating domain '${domain_name}'..."
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-domain-by-xml system::system::jenkins <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
  <specifications/>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
}

create_username_password_credentials() {
  local domain_name="${1:-}"
  local id="${2:-}"
  local username="${3:-}"
  local password="${4:-}"
  local description="${5:-}"
  echo "  Creating username/password credential '${id}'..."

  # check if credentials already exist, update password if yes
  local reply
  reply=$("${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" get-credentials-as-xml system::system::jenkins "${domain_name}" "${id}" 2>&1 || true)
  local cli_command
  local update_id
  if [[ "${reply}" == "No such domain" ]]; then
    create_domain "${domain_name}"
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"* ]]; then
    echo "  Credential ${id} already exists. Overwriting..."
    cli_command="update-credentials-by-xml"
    update_id="${id}"
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  # ${update_id} is deliberatly not put in quotes to be only used if credentials are updated. and yes, this is a hack
  "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" "${cli_command}" "system::system::jenkins" "${domain_name}" "${update_id}" <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <username>${username}</username>
  <password>${password}</password>
  <description>${description}</description>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}

create_ssh_credentials_xml() {
  local domain_name="${1:-}"
  local id="${2:-}"
  local username="${3:-}"
  local id_rsa="${4:-}"
  local passphrase="${5:-}"
  local description="${6:-}"
  echo "  Creating SSH credential '${id}'..."

  # check if credentials already exist
  local reply
  reply=$("${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" get-credentials-as-xml system::system::jenkins "${domain_name}" "${id}" 2>&1 || true)
  local cli_command
  local update_id
  if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then #skip for global domain ("_")
    create_domain "${domain_name}"
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"* ]]; then
    echo "  Credential ${id} already exists. Overwriting..."
    cli_command="update-credentials-by-xml"
    update_id="${id}"
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  # ${update_id} is deliberatly not put in quotes to be only used if credentials are updated. and yes, this is a hack
  "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" "${cli_command}" "system::system::jenkins" "${domain_name}" "${update_id}" <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <username>${username}</username>
  <description>${description}</description>
  <passphrase>${passphrase}</passphrase>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>${id_rsa}</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
}

#TODO: how can the bytes be added?
create_file_credentials() {
  local domain_name="${1:-}"
  local id="${2:-}"
  local file_name="${3:-}"
  local subkeys="${4:-}"
  echo "  Creating file credential '${id}'..."

  # check if credentials already exist
  local reply
  reply="$("${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" get-credentials-as-xml system::system::jenkins "${domain_name}" "${id}" 2>&1 || true)"
  local cli_command
  if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
    create_domain "${domain_name}"
    cli_command="create-credentials-by-xml"
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
  elif [[ "${reply}" == "<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl"* ]]; then
    echo "  Credential ${id} already exists."
    # Do not overwrite, since we can't set the a secret file automatically (yet)
    return
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" "${cli_command}" "system::system::jenkins" "${domain_name}" <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <fileName>${file_name}</fileName>
</org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
EOF

  ## TODO: find out how secret bytes need to be encoded
  echo "  IMPORTANT: secret file needs to be uploaded manually in the WebUI for now!"
  #<secretBytes>${subkeys}</secretBytes>
}

create_ssh_credentials() {
  local domain_name="${1:-}"
  local id="${2:-}"
  local description="${3:-}"
  local pass_domain="${4:-}"

  # read credentials from pass

  user="$(passw cbi "/bots/${PROJECT_NAME}/${pass_domain}/username")"

  LF_XENTITY="&#xA;"

  # TODO: does not seem to work
  # translate line feeds to LF_XENTITY 
  #id_rsa=$(passw cbi "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${pass_domain}/id_rsa" | tr '\n' ',' | sed 's/,/\'${LF_XENTITY}'/g')

  id_rsa="$(passw cbi "/bots/${PROJECT_NAME}/${pass_domain}/id_rsa")"

  # remove trailing line feed (already translated to LF_XENTITY)
  if [ "$(echo "${id_rsa}" | wc -c)" -ne 0 ] && [ "$(echo "${id_rsa}" | tail -c -6)" == "${LF_XENTITY}" ]; then
    id_rsa="$(echo "${id_rsa}" | head -c -6)"
  fi

  # escape XML special chars (<, >, &, ", and ' to their matching entities)
  passphrase="$(passw cbi "/bots/${PROJECT_NAME}/${pass_domain}/id_rsa.passphrase" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')"
  create_ssh_credentials_xml "${domain_name}" "${id}" "${user}" "${id_rsa}" "${passphrase}" "${description}"
}




## projects-storage.eclipse.org ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${PROJECTS_STORAGE_PASS_DOMAIN}/id_rsa.gpg" ]]; then
  echo "Found ${PROJECTS_STORAGE_PASS_DOMAIN} SSH credentials in password store..."
  create_ssh_credentials "_" "projects-storage.eclipse.org-bot-ssh" "ssh://genie.${SHORT_NAME}@projects-storage.eclipse.org" "${PROJECTS_STORAGE_PASS_DOMAIN}"
fi

## git.eclipse.org ##

# always create by default ?
if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${GIT_ECLIPSE_PASS_DOMAIN}/id_rsa.gpg" ]]; then
  echo "Found ${GIT_ECLIPSE_PASS_DOMAIN} SSH credentials in password store..."
  create_ssh_credentials "_" "git.eclipse.org-bot-ssh" "ssh://genie.${SHORT_NAME}@git.eclipse.org" "${GIT_ECLIPSE_PASS_DOMAIN}"
fi

## GitHub.com ##

# GitHub username/password credentials are deprecated
if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${GITHUB_PASS_DOMAIN}/api-token.gpg" ]]; then
  echo "Found ${GITHUB_PASS_DOMAIN} username/token credentials in password store..."
  # read credentials from pass
  user="$(passw cbi "/bots/${PROJECT_NAME}/${GITHUB_PASS_DOMAIN}/username")"
  token="$(passw cbi "/bots/${PROJECT_NAME}/${GITHUB_PASS_DOMAIN}/api-token")"
  create_username_password_credentials "api.github.com" "github-bot" "${user}" "${token}" "GitHub bot (username/token)"
fi

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${GITHUB_PASS_DOMAIN}/id_rsa.gpg" ]]; then
  echo "Found ${GITHUB_PASS_DOMAIN} SSH credentials in password store..."
  create_ssh_credentials "api.github.com" "github-bot-ssh" "GitHub bot (SSH)" "${GITHUB_PASS_DOMAIN}"
fi

## GitLab ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${GITLAB_PASS_DOMAIN}/id_rsa.gpg" ]]; then
  echo "Found ${GITLAB_PASS_DOMAIN} SSH credentials in password store..."
  create_ssh_credentials "gitlab.eclipse.org" "gitlab-bot-ssh" "GitLab bot (SSH)" "${GITLAB_PASS_DOMAIN}"
fi

## GPG (for OSSRH) ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${GPG_PASS_DOMAIN}/secret-subkeys.asc.gpg" ]]; then
  echo "Found ${GPG_PASS_DOMAIN} credentials in password store..."
  # read credentials from pass
  subkeys="$(passw cbi "/bots/${PROJECT_NAME}/${GPG_PASS_DOMAIN}/secret-subkeys.asc")"
  create_file_credentials "_" "secret-subkeys.asc" "secret-subkeys.asc" "${subkeys}" # id == filename
fi


