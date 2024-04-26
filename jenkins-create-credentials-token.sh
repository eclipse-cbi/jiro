#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script creates string credentials (token) in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
JENKINS_CLI="${SCRIPT_FOLDER}/jenkins-cli.sh"
INSTANCES="${SCRIPT_FOLDER}/instances"

#shellcheck disable=SC1091
source "${SCRIPT_FOLDER}/pass/pass_wrapper.sh"

_verify_inputs() {
  local project_name="${1:-}"

  # check that project name is not empty
  #if [ "${project_name}" == "" ]; then
  if [[ -z "${project_name}" ]]; then
    printf "ERROR: a project name must be given.\n"
    exit 1
  fi
}

_create_domain_xml() {
  local project_name="${1:-}"
  local domain_name="${2:-}"
  echo "  Creating domain '${domain_name}'..."
  "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "create-credentials-domain-by-xml" "system::system::jenkins" <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
  <specifications/>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
}

_create_string_credentials() {
  local project_name="${1:-}"
  local id="${2:-}"
  local description="${3:-}"
  local secret="${4:-}"
  local domain_name="${5:-_}" #if no domain is given, use "_" for system domain

  # read secret from stdin
  if [[ -z "${secret}" ]]; then
    read -rp "Secret: " secret
  fi
  if [[ -z "${secret}" ]]; then
    printf "ERROR: secret must be given.\n"
    exit 1
  fi

  echo "  Creating string credential '${id}' in domain '${domain_name}'..."

  # check if credentials already exist, update secret if yes
  local reply
  reply="$("${JENKINS_CLI}" "${INSTANCES}/${project_name}" "get-credentials-as-xml" "system::system::jenkins" "${domain_name}" "${id}" 2>&1 || true)"
  #echo "reply: ${reply}"
  local cli_command
  local update_id
  if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
    _create_domain_xml "${project_name}" "${domain_name}"
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"* ]]; then
    echo "    Credential '${id}' already exists. Overwriting..."
    cli_command="update-credentials-by-xml"
    update_id="${id}"
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  # shellcheck disable=SC2086 # ${update_id} is deliberatly not put in quotes to be only used if credentials are updated. and yes, this is a hack
  "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "${cli_command}" "system::system::jenkins" "${domain_name}" ${update_id} <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${description}</description>
  <secret>${secret}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
}

_create_username_token_credentials() {
  local project_name="${1:-}"
  local id="${2:-}"
  local description="${3:-}"
  local username="${4:-}"
  local token="${5:-}"
  local domain_name="${6:-_}" #if no domain is given, use "_" for system domain

  if [[ -z "${username}" ]]; then
    printf "ERROR: username must be given.\n"
    exit 1
  fi
  if [[ -z "${token}" ]]; then
    printf "ERROR: token must be given.\n"
    exit 1
  fi

  echo "  Creating username/token credential '${id}' in domain '${domain_name}'..."

  # check if credentials already exist, update token if yes
  local reply
  reply="$("${JENKINS_CLI}" "${INSTANCES}/${project_name}" "get-credentials-as-xml" "system::system::jenkins" "${domain_name}" "${id}" 2>&1 || true)"
  local cli_command
  local update_id
  if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
    _create_domain_xml "${project_name}" "${domain_name}"
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"* ]]; then
    echo "    Credential '${id}' already exists. Overwriting..."
    cli_command="update-credentials-by-xml"
    update_id="${id}"
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  # shellcheck disable=SC2086 # ${update_id} is deliberatly not put in quotes to be only used if credentials are updated. and yes, this is a hack
  "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "${cli_command}" "system::system::jenkins" "${domain_name}" ${update_id} <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <username>${username}</username>
  <password>${token}</password>
  <description>${description}</description>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
}


_create_gitlab_pat_token_credentials() {
  local project_name="${1:-}"
  local id="${2:-}"
  local description="${3:-}"
  local token="${4:-}"
  local domain_name="${5:-_}" #if no domain is given, use "_" for system domain

  if [[ -z "${token}" ]]; then
    printf "ERROR: token must be given.\n"
    exit 1
  fi

  echo "  Creating GitLab Personal Access Token credential '${id}' in domain '${domain_name}'..."

  # check if credentials already exist, update password if yes
  local reply
  reply="$("${JENKINS_CLI}" "${INSTANCES}/${project_name}" "get-credentials-as-xml" "system::system::jenkins" "${domain_name}" "${id}" 2>&1 || true)"
  local cli_command
  local update_id
  if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
    _create_domain_xml "${project_name}" "${domain_name}"
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "No such credential" ]]; then
    cli_command="create-credentials-by-xml"
    update_id=
  elif [[ "${reply}" == "<io.jenkins.plugins.gitlabserverconfig.credentials.PersonalAccessTokenImpl"* ]]; then
    echo "    Credential '${id}' already exists. Overwriting..."
    cli_command="update-credentials-by-xml"
    update_id="${id}"
  else
    echo "Unexpected reply: ${reply}"
    exit 1
  fi

  # shellcheck disable=SC2086 # ${update_id} is deliberatly not put in quotes to be only used if credentials are updated. and yes, this is a hack
  "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "${cli_command}" "system::system::jenkins" "${domain_name}" ${update_id} <<EOF
<io.jenkins.plugins.gitlabserverconfig.credentials.PersonalAccessTokenImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${description}</description>
  <token>${token}</token>
</io.jenkins.plugins.gitlabserverconfig.credentials.PersonalAccessTokenImpl>
EOF
}

help() {
  printf "Available commands:\n"
  printf "Command\t\t\tDescription\n\n"
  printf "auto\t\t\tTest which token credentials exist and create them (except for sonarcloud).\n"
  printf "default\t\t\tCreate any kind of credentials (secret text/token).\n"
  printf "docker\t\t\tCreate docker.com token credentials (secret text/token).\n"
  printf "quay\t\t\tCreate quay.io token credentials (secret text/token).\n"
  printf "github\t\t\tCreate github.com token credentials (secret text/token) and username/token credentials (username/token).\n"
  printf "gitlab\t\t\tCreate gitlab.eclipse.org token credentials (secret text/token).\n"
  printf "gitlab_pat\t\tCreate gitlab.eclipse.org PAT credentials (GitLab PAT token).\n"
  printf "gitlab_webhook_secret\tCreate gitlab.eclipse.org Webhook Secret credentials.\n"
  printf "sonarcloud\t\tCreate sonarcloud.io credentials (secret text/token).\n"
  printf "npmjs\t\t\tCreate npmjs credentials (secret text/token).\n"
  printf "pypi\t\t\tCreate pypi credentials (secret text/token).\n"
  printf "matrix\t\t\tCreate matrix credentials (secret text/token).\n"
  exit 0
}

auto() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  echo "Checking for docker.com API token..."
  if passw cbi "bots/${project_name}/docker.com/api-token" 2&> /dev/null; then
    docker "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for quay.io API token..."
  if passw cbi "bots/${project_name}/quay.io/api-token" 2&> /dev/null; then
    quay "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for github.com API token..."
  if passw cbi "bots/${project_name}/github.com/api-token" 2&> /dev/null; then
    github "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for gitlab.eclipse.org API token..."
  if passw cbi "bots/${project_name}/gitlab.eclipse.org/api-token" 2&> /dev/null; then
    gitlab "${project_name}"
    gitlab_pat "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for gitlab.eclipse.org webhook secret token..."
  if passw cbi "bots/${project_name}/gitlab.eclipse.org/webhook-secret" 2&> /dev/null; then
    gitlab_webhook_secret "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for npmjs.com API token..."
  if passw cbi "bots/${project_name}/npmjs.com/token" 2&> /dev/null; then
    npmjs "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for pypi.org API token..."
  if passw cbi "bots/${project_name}/pypi.org/token" 2&> /dev/null; then
    pypi "${project_name}"
  else
    echo "  No API token found."
  fi
  echo "Checking for matrix.eclipse.org API token..."
  if passw cbi "bots/${project_name}/matrix.eclipse.org/token" 2&> /dev/null; then
    matrix "${project_name}"
  else
    echo "  No API token found."
  fi

  #sonarcloud is excluded for now due to possible suffixes
}

docker() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local username
  username="$(passw cbi "bots/${project_name}/docker.com/username")"
  local token
  token="$(passw cbi "bots/${project_name}/docker.com/api-token")"

  _create_username_token_credentials "${project_name}" "docker-bot-token" "Docker Bot token" "${username}" "${token}" "docker.com"
}

quay() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local username
  username="$(passw cbi "bots/${project_name}/quay.io/robot-username")"
  local token
  token="$(passw cbi "bots/${project_name}/quay.io/robot-token")"

  _create_username_token_credentials "${project_name}" "quay-bot" "Quay bot (Robot username/token)" "${username}" "${token}" "quay.io"
}

github() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local username
  username="$(passw cbi "bots/${project_name}/github.com/username")"
  local token
  token="$(passw cbi "bots/${project_name}/github.com/api-token")"

  _create_string_credentials "${project_name}" "github-bot-token" "GitHub Bot token" "${token}" "api.github.com"

  _create_username_token_credentials "${project_name}" "github-bot" "GitHub bot (username/token)" "${username}" "${token}" "api.github.com"
}

gitlab() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/gitlab.eclipse.org/api-token")"

  _create_string_credentials "${project_name}" "gitlab-api-token" "GitLab token for ${project_name}" "${token}" "gitlab.eclipse.org"
}

gitlab_pat() {
  local project_name="${1:-}"

 _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/gitlab.eclipse.org/api-token")"

  _create_gitlab_pat_token_credentials "${project_name}" "gitlab-personal-access-token" "GitLab personal access token for ${project_name}" "${token}" "gitlab.eclipse.org"
}

gitlab_webhook_secret() {
  local project_name="${1:-}"

 _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/gitlab.eclipse.org/webhook-secret")"

  _create_string_credentials "${project_name}" "gitlab-webhook-secret" "GitLab Webhook Secret" "${token}" "gitlab.eclipse.org"
}

sonarcloud() {
  local project_name="${1:-}"
  local suffix="${2:-}" # optional

  _verify_inputs "${project_name}"

  local short_name="${project_name##*.}"
  local token
  token="$(passw cbi "bots/${project_name}/sonarcloud.io/token")"

  if [[ -n "${suffix}" ]]; then
    suffix="-${suffix}"
  fi

  _create_string_credentials "${project_name}" "sonarcloud-token${suffix}" "SonarCloud token for ${short_name}${suffix}" "${token}"
}

npmjs() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/npmjs.com/token")"

  _create_string_credentials "${project_name}" "npmjs-token" "npmjs.com token" "${token}"
}

pypi() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/pypi.org/token")"

  _create_string_credentials "${project_name}" "pypi-token" "pypi.org token" "${token}"
}

matrix() {
  local project_name="${1:-}"

  _verify_inputs "${project_name}"

  local token
  token="$(passw cbi "bots/${project_name}/matrix.eclipse.org/token")"

  _create_string_credentials "${project_name}" "matrix-token" "matrix.eclipse.org token" "${token}"
}

_default_usage() {
  printf "%s <project_name> <secret_id> <secret_description> <secret> [domain]\n" "${SCRIPT_NAME}"
  printf "\t%-20s the name of the project to add credentials to Jenkins (e.g. technology.cbi) \n" "project_name"
  printf "\t%-20s the id of the secret\n" "secret_id"
  printf "\t%-20s the description of the secret\n" "secret_description"
  printf "\t%-20s the secret\n" "secret"
  printf "\t%-20s the domain of the secret (optional)\n" "domain"
}

default() {
  local project_name="${1:-}"
  local secret_id="${2:-}"
  local secret_description="${3:-}"
  local secret="${4:-}"
  local domain="${5:-}"

  local short_name="${project_name##*.}"

  # check that project name is not empty
  if [[ -z "${project_name}" ]]; then
    printf "ERROR: a project name must be given.\n"
    _default_usage
    exit 1
  fi

  # check that secret id is not empty
  if [[ -z "${secret_id}" ]]; then
    printf "ERROR: a secret id must be given.\n"
    _default_usage
    exit 1
  fi

  _create_string_credentials "${project_name}" "${secret_id}" "${secret_description}" "${secret}" "${domain}"
}

"$@"

# show help menu, if no first parameter is given
if [[ -z "${1:-}" ]]; then
  help
fi
