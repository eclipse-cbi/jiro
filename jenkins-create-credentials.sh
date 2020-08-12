#!/usr/bin/env bash

# This script creates credentials in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"
script_folder="$(dirname $(readlink -f "${0}"))"

export PASSWORD_STORE_DIR=~/.password-store/cbi-pass

PROJECT_NAME="${1:-}"
SHORT_NAME="${PROJECT_NAME##*.}"

create_domain_xml() {
    local domain_name="${1:-}"
    echo "  Creating domain '${domain_name}'..."
    ./jenkins-cli.sh "instances/${PROJECT_NAME}" create-credentials-domain-by-xml system::system::jenkins <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
</com.cloudbees.plugins.credentials.domains.Domain>
EOF
}

create_username_password_credentials_xml() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local username="${3:-}"
    local password="${4:-}"
    local description="${5:-}"
    echo "  Creating username/password credential '${id}'..."
    ./jenkins-cli.sh "instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
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
    local idrsa="${4:-}"
    local passphrase="${5:-}"
    local description="${6:-}"
    echo "  Creating SSH credential '${id}'..."
    ./jenkins-cli.sh "instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.18.1">
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <username>${username}</username>
  <description>${description}</description>
  <passphrase>${passphrase}</passphrase>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>${idrsa}</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
}

create_username_password_credentials() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local description="${3:-}"
    local pass_domain="${4:-}"

    # read credentials from pass
    user=$(pass /bots/${PROJECT_NAME}/${pass_domain}/username)
    password=$(pass /bots/${PROJECT_NAME}/${pass_domain}/password)

    # check if credentials already exist
    reply=$(./jenkins-cli.sh instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
    if [[ "${reply}" == "No such domain" ]]; then
        create_domain_xml "${domain_name}"
        create_username_password_credentials_xml "${domain_name}" "${id}" "${user}" "${password}" "${description}"
    elif [[ "${reply}" == "No such credential" ]]; then
        create_username_password_credentials_xml "${domain_name}" "${id}" "${user}" "${password}" "${description}"
    elif [[ "${reply}" == "<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"* ]]; then
        echo "  Credential ${id} already exists."
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}

create_ssh_credentials() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local description="${3:-}"
    local pass_domain="${4:-}"

    # read credentials from pass

    # exception for projects-storage :/
    if [[ "${pass_domain}" == "projects-storage.eclipse.org" ]]; then
        user="genie.${SHORT_NAME}"
    else
        user=$(pass /bots/${PROJECT_NAME}/${pass_domain}/username)
    fi
    idrsa=$(pass /bots/${PROJECT_NAME}/${pass_domain}/id_rsa)
    passphrase=$(pass /bots/${PROJECT_NAME}/${pass_domain}/id_rsa.passphrase)

    # check if credentials already exist
    reply=$(./jenkins-cli.sh instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
    if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then #skip for global domain ("_")
        create_domain_xml "${domain_name}"
        create_ssh_credentials_xml "${domain_name}" "${id}" "${user}" "${idrsa}" "${passphrase}" "${description}"
    elif [[ "${reply}" == "No such credential" ]]; then
        create_ssh_credentials_xml "${domain_name}" "${id}" "${user}" "${idrsa}" "${passphrase}" "${description}"
    elif [[ "${reply}" == "<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"* ]]; then
        echo "  Credential ${id} already exists."
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}



projects_storage_pass_domain="projects-storage.eclipse.org"
if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${projects_storage_pass_domain}/id_rsa.gpg" ]]; then
    echo "Found ${projects_storage_pass_domain} SSH credentials in password store..."
    create_ssh_credentials "_" "projects-storage.eclipse.org-bot-ssh" "ssh://genie.${SHORT_NAME}@projects-storage.eclipse.org" "projects-storage.eclipse.org"
fi

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/github.com/password.gpg" ]]; then
    echo "Found github.com username/password credentials in password store..."
    create_username_password_credentials "api.github.com" "github-bot" "GitHub bot" "github.com"
fi

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/github.com/id_rsa.gpg" ]]; then
    echo "Found github.com SSH credentials in password store..."
    create_ssh_credentials "api.github.com" "github-bot-ssh" "GitHub bot (SSH)" "github.com"
    
fi

