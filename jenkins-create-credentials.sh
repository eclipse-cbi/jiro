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

projects_storage_pass_domain="projects-storage.eclipse.org"
git_eclipse_pass_domain="git.eclipse.org"
github_pass_domain="github.com"
gpg_pass_domain="gpg"


create_domain_xml() {
    local domain_name="${1:-}"
    echo "  Creating domain '${domain_name}'..."
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-domain-by-xml system::system::jenkins <<EOF
<com.cloudbees.plugins.credentials.domains.Domain>
  <name>${domain_name}</name>
  <specifications/>
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
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
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
    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
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
create_file_credentials_xml() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local file_name="${3:-}"
    local subkeys="${4:-}"
    echo "  Creating file credential '${id}'..."

    ## TODO: find out how secret bytes need to be encoded
    echo "  IMPORTANT: file needs to be uploaded manually in the WebUI for now!"
    #<secretBytes>${subkeys}</secretBytes>

    "${script_folder}/jenkins-cli.sh" "${script_folder}/instances/${PROJECT_NAME}" create-credentials-by-xml system::system::jenkins "${domain_name}" <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>${id}</id>
  <fileName>${file_name}</fileName>
</org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
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
    reply=$(${script_folder}/jenkins-cli.sh ${script_folder}/instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
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

    user=$(pass /bots/${PROJECT_NAME}/${pass_domain}/username)

    # TODO: does not seem to work
    # translate line feeds to LF_XENTITY 
    #LF_XENTITY="&#xA;"
    #id_rsa=$(pass /bots/${PROJECT_NAME}/${pass_domain}/id_rsa | tr '\n' ',' | sed 's/,/\'${LF_XENTITY}'/g')

    id_rsa=$(pass /bots/${PROJECT_NAME}/${pass_domain}/id_rsa)

    # remove trailing line feed (already translated to LF_XENTITY)
    if [ "$(echo ${id_rsa} | wc -c)" -ne 0 ] && [ "$(echo ${id_rsa} | tail -c -6)" == "${LF_XENTITY}" ]; then
      id_rsa="$(echo ${id_rsa} | head -c -6)"
    fi

    # escape XML special chars (<, >, &, ", and ' to their matching entities)
    passphrase=$(pass /bots/${PROJECT_NAME}/${pass_domain}/id_rsa.passphrase | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')



    # check if credentials already exist
    reply=$(${script_folder}/jenkins-cli.sh ${script_folder}/instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
    if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then #skip for global domain ("_")
        create_domain_xml "${domain_name}"
        create_ssh_credentials_xml "${domain_name}" "${id}" "${user}" "${id_rsa}" "${passphrase}" "${description}"
    elif [[ "${reply}" == "No such credential" ]]; then
        create_ssh_credentials_xml "${domain_name}" "${id}" "${user}" "${id_rsa}" "${passphrase}" "${description}"
    elif [[ "${reply}" == "<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"* ]]; then
        echo "  Credential ${id} already exists."
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}

create_file_credentials() {
    local domain_name="${1:-}"
    local id="${2:-}"
    local file_name="${id}" # id == filename
    local pass_domain="${3:-}"

    # read credentials from pass
    subkeys=$(pass /bots/${PROJECT_NAME}/${pass_domain}/secret-subkeys.asc)

    # check if credentials already exist
    reply=$(${script_folder}/jenkins-cli.sh ${script_folder}/instances/${PROJECT_NAME} get-credentials-as-xml system::system::jenkins ${domain_name} ${id} 2>&1 || true)
    if [[ "${reply}" == "No such domain" && "${domain_name}" != "_" ]]; then
        create_domain_xml "${domain_name}"
        create_file_credentials_xml "${domain_name}" "${id}" "${file_name}" "${subkeys}"
    elif [[ "${reply}" == "No such credential" ]]; then
        create_file_credentials_xml "${domain_name}" "${id}" "${file_name}" "${subkeys}"
    elif [[ "${reply}" == "<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl"* ]]; then
        echo "  Credential ${id} already exists."
    else
        echo "Unexpected reply: ${reply}"
        exit 1
    fi
}

## projects-storage.eclipse.org ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${projects_storage_pass_domain}/id_rsa.gpg" ]]; then
    echo "Found ${projects_storage_pass_domain} SSH credentials in password store..."
    create_ssh_credentials "_" "projects-storage.eclipse.org-bot-ssh" "ssh://genie.${SHORT_NAME}@projects-storage.eclipse.org" "${projects_storage_pass_domain}"
fi

## git.eclipse.org ##

# always create by default ?
if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${git_eclipse_pass_domain}/id_rsa.gpg" ]]; then
    echo "Found ${git_eclipse_pass_domain} SSH credentials in password store..."
    create_ssh_credentials "_" "git.eclipse.org-bot-ssh" "ssh://genie.${SHORT_NAME}@git.eclipse.org" "${git_eclipse_pass_domain}"
fi

## GitHub.com ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${github_pass_domain}/password.gpg" ]]; then
    echo "Found ${github_pass_domain} username/password credentials in password store..."
    create_username_password_credentials "api.github.com" "github-bot" "GitHub bot" "${github_pass_domain}"
fi

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${github_pass_domain}/id_rsa.gpg" ]]; then
    echo "Found ${github_pass_domain} SSH credentials in password store..."
    create_ssh_credentials "api.github.com" "github-bot-ssh_webmaster-test2" "GitHub bot (SSH) Webmaster Test2" "${github_pass_domain}"
fi

## GPG (for OSSRH) ##

if [[ -f "${PASSWORD_STORE_DIR}/bots/${PROJECT_NAME}/${gpg_pass_domain}/secret-subkeys.asc.gpg" ]]; then
    echo "Found ${gpg_pass_domain} credentials in password store..."
    create_file_credentials "_" "secret-subkeys.asc" "${gpg_pass_domain}"
fi


