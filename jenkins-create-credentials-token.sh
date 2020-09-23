#!/usr/bin/env bash

# This script creates string credentials in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${BASH_SOURCE[0]})"
script_folder="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

PROJECT_NAME="${1:-}"
secret_id="${2:-}"
secret_description="${3:-}"
SHORT_NAME="${PROJECT_NAME##*.}"

usage() {
  printf "%s <project_name> <secret_id> [secret_description]\n" "${script_name}"
  printf "\t%-20s the name of the project to add credentials to Jenkins (e.g. technology.cbi) \n" "project_name"
  printf "\t%-20s the id of the secret\n" "secret_id"
  printf "\t%-20s the description of the secret (optional)\n" "secret_description"
}

# check that project name is not empty
if [[ -z "${PROJECT_NAME}" ]]; then
  printf "ERROR: a project name must be given.\n"
  usage
  exit 1
fi

# check that secret id is not empty
if [[ -z "${secret_id}" ]]; then
 printf "ERROR: a secret id must be given.\n"
 usage
 exit 1
fi

create_domain_xml() {
    local domain_name="${1:-}"
    echo "  Creating domain '${domain_name}'..."
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-domain-by-xml system::system::jenkins <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
}

create_string_credentials_xml() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local secret="${3:-}"
    local description="${4:-}"
    echo "  Creating string credential '${id}'..."
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <description>${description}</description>
  <secret>${secret}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
}

create_string_credentials() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local description="${3:-}"

    # read secret from stdin
    read -p "Secret: " secret
    if [[ -z "${secret}" ]]; then
        printf "ERROR: secret must be given.\n"
        exit 1
    fi

    # check if credentials already exist
    reply=$(${script_folder}/jenkins-cli.sh ${script_folder}/instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
    if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
        create_domain_xml "${domain_name}"
        create_string_credentials_xml "${domain_name}" "${id}" "${secret}" "${description}"
    elif [[ "${reply}" == "No such credential" ]]; then
        create_string_credentials_xml "${domain_name}" "${id}" "${secret}" "${description}"
    elif [[ "${reply}" == "<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"* ]]; then
        echo "  Credential ${id} already exists."
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}

create_string_credentials "_" "${secret_id}" "${secret_description}"

