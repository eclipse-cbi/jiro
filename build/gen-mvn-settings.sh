#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"
SCRIPT_NAME="$(basename "$(readlink -f "${0}")")"

if [[ ! -f "${SCRIPT_FOLDER}/../.localconfig" ]]; then
  echo "ERROR: File '$(readlink -f "${SCRIPT_FOLDER}/../.localconfig")' does not exists"
  echo "Create one to configure the location of the password store"
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${SCRIPT_FOLDER}/../.localconfig")"
PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
export PASSWORD_STORE_DIR

INSTANCE="${1:-}"

if [ -z "${INSTANCE}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${INSTANCE}" ]; then
  echo "ERROR: no 'instance' at '${INSTANCE}'"
  exit 1
fi

CONFIG="${INSTANCE}/target/config.json"
SETTINGS_SECURITY_XML="$(dirname "${CONFIG}")/.secrets/maven/settings-security.xml"
SETTINGS_XML="$(dirname "${CONFIG}")/.secrets/maven/settings.xml"

gen_pw() {
  # If pwgen is not installed, use /dev/urandom instead
  if hash pwgen 2>/dev/null; then
    pwgen -1 -s -y "${1}"
  else
    </dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c "${1}"
  fi
}

gen_settings_security() {
  local password_length="${1:-"32"}"
  # encrypt master pw
  local master_pw
  master_pw=$(gen_pw "${password_length}")
  local master_pw_enc
  master_pw_enc=$(mvn --encrypt-master-password "${master_pw}")

  # generate security-settings.xml file
  cat <<EOG
<?xml version="1.0" encoding="UTF-8"?>
<settingsSecurity>
  <master>${master_pw_enc}</master>
</settingsSecurity>
EOG
}

nexus_pro_token() {
  local username="${1}"
  local password="${2}"
  local nexusProUrl="${3}"

  local commonCurlOpts='header = "Accept: application/json"\nheader = "Content-Type: application/json"'
  local basicAuth='user = "'${username}':'${password}'"'
  local curlOpts="${commonCurlOpts}\n${basicAuth}"
  local payload
  payload='{"u":"'$(printf "%s" "${username}" | base64)'","p":"'$(printf "%s" "${password}" | base64)'"}'

  # deleting any previous token
  local authTicket
  authTicket="$(curl -sS -X POST -K- --data "${payload}" "${nexusProUrl}/service/siesta/wonderland/authenticate" <<< "$(echo -e "${curlOpts}")" | jq -r '.t')"
  >&2 curl -X DELETE -sS -K- -H "X-NX-AuthTicket: ${authTicket}" "${nexusProUrl}/service/siesta/usertoken/current" <<< "$(echo -e "${curlOpts}")"

  # getting a new user token
  authTicket="$(curl -sS -X POST -K- --data "${payload}" "${nexusProUrl}/service/siesta/wonderland/authenticate" <<< "$(echo -e "${curlOpts}")" | jq -r '.t')"

  curl -sS -K- -H "X-NX-AuthTicket: ${authTicket}" "${nexusProUrl}/service/siesta/usertoken/current" <<< "$(echo -e "${curlOpts}")" | jq -cM
}

gen_server() {
  local serverId="${1}"
  local server="${2}"
  local username_pass password_pass
  username_pass="$(jq -r '.username.pass' <<< "${server}")"
  password_pass="$(jq -r '.password.pass' <<< "${server}")"
  if [[ -f "${PASSWORD_STORE_DIR}/${username_pass}.gpg" ]] \
  && [[ -f "${PASSWORD_STORE_DIR}/${password_pass}.gpg" ]]; then
    >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating server entry '${serverId}'"
    local username password
    username="$(pass "${username_pass}")"
    password="$(pass "${password_pass}")"
    
    local server_password server_username nexusProUrl
    nexusProUrl="$(jq -r '.nexusProUrl | select (.!=null)' <<< "${server}")"
    if [[ -n "${nexusProUrl}" ]]; then
      >&2 echo -e "${SCRIPT_NAME}\tINFO: Server '${serverId}' will use Nexus Pro token for credentials"
      # this server has a nexus Pro URL set, get a token to authenticate instead of using the account username/password
      local token
      token="$(nexus_pro_token "${username}" "${password}" "${nexusProUrl}")"
      server_username="$(jq -r '.nameCode' <<< "${token}")"
      server_password=$(mvn --encrypt-password "$(jq -r '.passCode' <<< "${token}")" -Dsettings.security="${SETTINGS_SECURITY_XML}")
    else
      server_username="${username}"
      server_password=$(mvn --encrypt-password "$(printf "%s" "${password}")" -Dsettings.security="${SETTINGS_SECURITY_XML}")
    fi

    cat <<EOF
    <server>
      <id>${serverId}</id>
      <username>${server_username}</username>
      <password>${server_password}</password>
    </server>
EOF
  else
    >&2 echo -e "${SCRIPT_NAME}\tWARNING: no entry in password-store for ${username_pass} or ${password_pass}"
  fi
}

gen_mirror() {
  local mirrorId="${1}"
  local mirror="${2}"
  cat <<EOF
    <mirror>
      <id>${mirrorId}</id>
      <name>$(jq -r '.name' <<< "${mirror}")</name>
      <url>$(jq -r '.url' <<< "${mirror}")</url>
      <mirrorOf>$(jq -r '.mirrorOf' <<< "${mirror}")</mirrorOf>
    </mirror>
EOF
}

gen_servers() {
  local config="${1}"
  echo "  <servers>"

  local serverId
  for serverId in $(jq -r '.maven.files[] | select(.name == "settings.xml") | .servers | keys | .[]' "${config}"); do
    gen_server "${serverId}" "$(jq -c '.maven.files[] | select(.name == "settings.xml").servers["'"${serverId}"'"]' "${config}")"
  done

  echo "  </servers>"
}

gen_mirrors() {
  local config="${1}"
  echo "  <mirrors>"

  local mirrorId
  for mirrorId in $(jq -r '.maven.files[] | select(.name == "settings.xml") | .mirrors | keys | .[]' "${config}"); do
    gen_mirror "${mirrorId}" "$(jq -c '.maven.files[] | select(.name == "settings.xml").mirrors["'"${mirrorId}"'"]' "${config}")";
  done

  echo "  </mirrors>"
}

gen_settings() {
  local config="${1}"
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo "<settings>"

  gen_servers "${config}"
  gen_mirrors "${config}"

  echo "</settings>"
}

>&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven settings-security.xml"
mkdir -p "$(dirname "${SETTINGS_SECURITY_XML}")"
gen_settings_security 32 > "${SETTINGS_SECURITY_XML}"

>&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven settings.xml file"
mkdir -p "$(dirname "${SETTINGS_XML}")"
gen_settings "${CONFIG}" > "${SETTINGS_XML}"