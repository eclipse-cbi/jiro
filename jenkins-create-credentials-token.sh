#!/usr/bin/env bash

# This script creates string credentials in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename "${BASH_SOURCE[0]}")"
script_folder="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
JENKINS_CLI="${script_folder}/jenkins-cli.sh"
INSTANCES="${script_folder}/instances"


_create_domain_xml() {
    local project_name="${1:-}"
    local domain_name="${2:-}"
    echo "  Creating domain '${domain_name}'..."
    "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "create-credentials-domain-by-xml" "system::system::jenkins" <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
}

_create_string_credentials_xml() {
    local project_name="${1:-}"
    local domain_name="${2:-}"
    local id="${3:-}"
    local secret="${4:-}"
    local description="${5:-}"
    echo "  Creating string credential '${id}' in domain ${domain_name}..."
    "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "create-credentials-by-xml" "system::system::jenkins" "${domain_name}" <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${description}</description>
  <secret>${secret}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
}

_update_string_credentials_xml() {
    local project_name="${1:-}"
    local domain_name="${2:-}"
    local id="${3:-}"
    local secret="${4:-}"
    local description="${5:-}"
    echo "  Updating string credential '${id}'..."
    "${JENKINS_CLI}" "${INSTANCES}/${project_name}" "update-credentials-by-xml" "system::system::jenkins" "${domain_name}" "${id}" <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${description}</description>
  <secret>${secret}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
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
      read -p "Secret: " secret
    fi
    if [[ -z "${secret}" ]]; then
      printf "ERROR: secret must be given.\n"
      exit 1
    fi

    # check if credentials already exist
    reply="$("${JENKINS_CLI}" "${INSTANCES}/${project_name}" "get-credentials-as-xml" "system::system::jenkins" "${domain_name}" "${id}" 2>&1 || true)"
    #echo "reply: ${reply}"
    if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
        _create_domain_xml "${project_name}" "${domain_name}"
        _create_string_credentials_xml "${project_name}" "${domain_name}" "${id}" "${secret}" "${description}"
    elif [[ "${reply}" == "No such credential" ]]; then
        _create_string_credentials_xml "${project_name}" "${domain_name}" "${id}" "${secret}" "${description}"
    elif [[ "${reply}" == "<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"* ]]; then
        _update_string_credentials_xml "${project_name}" "${domain_name}" "${id}" "${secret}" "${description}"
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}


help() {
  printf "Available commands:\n"
  printf "Command\t\t\tDescription\n\n"
  printf "default\t\t\tCreate any kind of credentials (secret text/token).\n"
  printf "gitlab\t\t\tCreate gitlab.eclipse.org token credentials (secret text/token).\n"
  printf "sonarcloud\t\tCreate sonarcloud.io credentials (secret text/token).\n"
  printf "npmjs\t\t\tCreate npmjs credentials (secret text/token).\n"
  exit 0
}

sonarcloud() {
  local project_name="${1:-}"
  local suffix="${2:-}" # optional

  # check that project name is not empty
  if [[ -z "${project_name}" ]]; then
    printf "ERROR: a project name must be given.\n"
    exit 1
  fi

  local short_name="${project_name##*.}"
  local token
  token="$(pass "/cbi-pass/bots/${project_name}/sonarcloud.io/token")"

  _create_string_credentials "${project_name}" "sonarcloud-token${suffix}" "SonarCloud token for ${short_name}${suffix}" "${token}"
}

gitlab() {
  local project_name="${1:-}"

  # check that project name is not empty
  if [[ -z "${project_name}" ]]; then
    printf "ERROR: a project name must be given.\n"
    exit 1
  fi

  local token
  token="$(pass "/cbi-pass/bots/${project_name}/gitlab.eclipse.org/token")"

  _create_string_credentials "${project_name}" "gitlab-api-token" "GitLab token for ${project_name}" "${token}" "gitlab.eclipse.org"
}

npmjs() {
  local project_name="${1:-}"

  # check that project name is not empty
  if [[ -z "${project_name}" ]]; then
    printf "ERROR: a project name must be given.\n"
    exit 1
  fi

  local token
  token="$(pass "/cbi-pass/bots/${project_name}/npmjs.com/token")"

  _create_string_credentials "${project_name}" "npmjs-token" "npmjs.com token" "${token}"
}

_default_usage() {
  printf "%s <project_name> <secret_id> <secret_description> <secret> [domain]\n" "${script_name}"
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

  _create_string_credentials "${secret_id}" "${secret_description}" "${secret}" "${domain}"
}

"$@"

# show help menu, if no first parameter is given
if [[ -z "${1:-}" ]]; then
  help
fi
