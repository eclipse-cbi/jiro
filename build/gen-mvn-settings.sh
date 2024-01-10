#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Generates Maven settings file from credentials in password store

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store. Example:"
  echo '{"password-store": {"cbi-dir": "~/.password-store/cbi"}}' | jq -M
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
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
WORKDIR="$(dirname "${CONFIG}")/.secrets/maven"
SETTINGS_SECURITY_XML="${WORKDIR}/settings-security.xml"

gen_pw() {
  # If pwgen is not installed, use /dev/urandom instead
  if hash pwgen 2>/dev/null; then
    pwgen -1 -s -y -r \''"`{}$#\\!' "${1}"
  else
    </dev/urandom tr -dc 'A-Za-z0-9#%&()*+,-./:;<=>?@[]^_|~' | head -c "${1}"
  fi
}

gen_settings_security() {
  local password_length="${1:-"32"}"
  # encrypt master pw
  local master_pw

  local projectFullName
  projectFullName="$(jq -r '.project.fullName' "${CONFIG}")"

  if [[ -f "${PASSWORD_STORE_DIR}/bots/${projectFullName}/apache-maven-security-settings/master-password.gpg" ]]; then
    master_pw="$(pass "bots/${projectFullName}/apache-maven-security-settings/master-password")"
  else
    master_pw=$(gen_pw "${password_length}")
  fi

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

gen_server() {
  local serverId="${1}"
  local server="${2}"
  local username_pass password_pass passphrase_pass
  username_pass="$(jq -r '.username.pass' <<< "${server}")"
  password_pass="$(jq -r '.password.pass' <<< "${server}")"
  passphrase_pass="$(jq -r '.passphrase.pass' <<< "${server}")"
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
      >&2 echo -e "${SCRIPT_NAME}\tINFO: Nexus Pro URL: '${nexusProUrl}'"
      # this server has a nexus Pro URL set, get a token to authenticate instead of using the account username/password
      local token
      token="$("${SCRIPT_FOLDER}/nexus-pro-token.sh" get_or_create "${nexusProUrl}" "${username}" "${password}")"
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
  elif [[ -f "${PASSWORD_STORE_DIR}/${passphrase_pass}.gpg" ]]; then
    >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating server entry '${serverId}'"
    local passphrase server_passphrase
    passphrase="$(pass "${passphrase_pass}")"
    server_passphrase=$(mvn --encrypt-password "$(printf "%s" "${passphrase}")" -Dsettings.security="${SETTINGS_SECURITY_XML}")
    cat <<EOF
    <server>
      <id>${serverId}</id>
      <passphrase>${server_passphrase}</passphrase>
    </server>
EOF
  else
    >&2 echo -e "${SCRIPT_NAME}\tWARNING: no entry in password-store for server ${serverId}"
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
  local settingsFilename="${1}"
  local config="${2}"
  echo "  <servers>"

  local serverId
  for serverId in $(jq -r '.maven.files["'"${settingsFilename}"'"] | .servers | keys | .[]' "${config}"); do
    gen_server "${serverId}" "$(jq -c '.maven.files["'"${settingsFilename}"'"].servers["'"${serverId}"'"]' "${config}")"
  done

  echo "  </servers>"
}

gen_mirrors() {
  local settingsFilename="${1}"
  local config="${2}"
  echo "  <mirrors>"

  local mirrorId
  for mirrorId in $(jq -r '.maven.files["'"${settingsFilename}"'"] | .mirrors | keys | .[]' "${config}"); do
    gen_mirror "${mirrorId}" "$(jq -c '.maven.files["'"${settingsFilename}"'"].mirrors["'"${mirrorId}"'"]' "${config}")";
  done

  echo "  </mirrors>"
}

gen_settings() {
  local settingsFilename="${1}"
  local config="${2}"
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo "<settings>"

  echo "  <interactiveMode>$(jq '.maven.interactiveMode' "${config}")</interactiveMode>"
  gen_servers "${settingsFilename}" "${config}"
  gen_mirrors "${settingsFilename}" "${config}"

  echo "</settings>"
}

gen_mavenrc() {
  local config="${1}"

  printf 'set --'

  if [[ "$(jq -r '.maven.showVersion' "${config}")" == "true" ]]; then
    printf ' -V'
  fi

  local transferListenerLogLevel
  transferListenerLogLevel="$(jq -r '.maven.transferListenerLogLevel' "${config}")"
  if [[ -n "${transferListenerLogLevel}" ]]; then
    printf ' -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=%s' "${transferListenerLogLevel}"
  fi

  if [[ "$(jq -r '.maven.interactiveMode' "${config}")" == "false" ]]; then
    printf ' --batch-mode'
  fi

  local mavenrc
  mavenrc="$(jq -r '.maven.mavenrc' "${config}")"
  if [[ -n "${mavenrc}" ]]; then
    printf ' %s' "${mavenrc}"
  fi

  # shellcheck disable=SC2016
  printf ' "${@}"'
}

gen_maven_toolchains () {
  local maxJDK="${1:-}"
  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>CDC-1.0/Foundation-1.0</id>
      <vendor>cdc</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/ee/CDC-1.0_Foundation-1.0</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>CDC-1.1/Foundation-1.1</id>
      <vendor>cdc</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/ee/CDC-1.1_Foundation-1.1</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>OSGi/Minimum-1.0</id>
      <vendor>osgi</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/ee/OSGi_Minimum-1.0</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>OSGi/Minimum-1.1</id>
      <vendor>osgi</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/ee/OSGi_Minimum-1.1</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>OSGi/Minimum-1.2</id>
      <vendor>osgi</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/ee/OSGi_Minimum-1.2</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>J2SE-1.5</id>
      <version>1.5</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/java/oracle/jdk-5/latest</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>JavaSE-1.6</id>
      <version>1.6</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/java/oracle/jdk-6/latest</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>JavaSE-1.7</id>
      <version>1.7</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/java/oracle/jdk-7/latest</jdkHome></configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>JavaSE-1.8</id>
      <version>1.8</version>
      <vendor>oracle</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/java/oracle/jdk-8/latest</jdkHome></configuration>
  </toolchain>
EOF
  for version in $(seq 9 ${maxJDK}); do
    cat <<EOF
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>JavaSE-${version}</id>
      <version>${version}</version>
      <vendor>openjdk</vendor>
    </provides>
    <configuration><jdkHome>/opt/tools/java/openjdk/jdk-${version}/latest</jdkHome></configuration>
  </toolchain>
EOF
  done
  echo "</toolchains>"
#  cat <<EOF
#</toolchains>
#EOF
}

if [[ "$(jq -r '.maven.generate' "${CONFIG}")" == "true" ]]; then
  >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven settings-security.xml"
  mkdir -p "${WORKDIR}"
  gen_settings_security 32 > "${SETTINGS_SECURITY_XML}"

  for settingsFilename in $(jq -r '.maven.files | keys - ["settings-security.xml"] | .[]' "${CONFIG}"); do
    >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven ${settingsFilename} file"
    mkdir -p "$(dirname "${WORKDIR}/${settingsFilename}")"
    gen_settings "${settingsFilename}" "${CONFIG}" > "${WORKDIR}/${settingsFilename}"
  done

  >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven .mavenrc"
  gen_mavenrc "${CONFIG}" > "${WORKDIR}/.mavenrc"

  >&2 echo -e "${SCRIPT_NAME}\tINFO: Generating Maven toolchains.xml"
  #TODO: update max version when new JDK has been released
  gen_maven_toolchains "22" > "${WORKDIR}/toolchains.xml"
fi