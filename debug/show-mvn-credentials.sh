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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

instance="${1:-}"
secret_name="${2:-"m2-secret-dir"}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

LOCAL_CONFIG="${HOME}/.cbi/config"
if [[ ! -f "${LOCAL_CONFIG}" ]]; then
  echo "ERROR: File '$(readlink -f "${LOCAL_CONFIG}")' does not exists"
  echo "Create one to configure the location of the password store"
fi
PASSWORD_STORE_DIR="$(jq -r '.["password-store"]["cbi-dir"]' "${LOCAL_CONFIG}")"
PASSWORD_STORE_DIR="$(readlink -f "${PASSWORD_STORE_DIR/#~\//${HOME}/}")"
export PASSWORD_STORE_DIR

config="${instance}/target/config.json"
namespace="$(jq -r '.kubernetes.master.namespace' "${config}")"
projectFullName="$(jq -r '.project.fullName' "${config}")"

. "${SCRIPT_FOLDER}/../build/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${config}")"

if [[ ! -f "${SCRIPT_FOLDER}/.maven-decrypter.jar" ]]; then
  curl -sSL -o "${SCRIPT_FOLDER}/.maven-decrypter.jar" "https://github.com/completeworks/maven-settings-decrypter/releases/download/ea-0/maven-settings-decrypter-1.0.0-shaded.jar"
  if [[ ! -f "${SCRIPT_FOLDER}/.gitignore" ]] ||  ! grep .maven-decrypter.jar "${SCRIPT_FOLDER}/.gitignore" &> /dev/null; then
    echo ".maven-decrypter.jar" >> "${SCRIPT_FOLDER}/.gitignore"
  fi
fi

settings_security_xml="$(mktemp)"
kubectl get secret -n "${namespace}" "${secret_name}" -o json | jq -r '.data["settings-security.xml"]' | base64 -d > "${settings_security_xml}"

if ! grep "settingsSecurity" "${settings_security_xml}" &> /dev/null; then 
  echo -e "\n<settingsSecurity/>" >> "${settings_security_xml}"
fi

# get and decrypt settings.xml
settings_xml="$(mktemp)"
kubectl get secret -n "${namespace}" "${secret_name}" -o json | jq -r '.data["settings.xml"]'  | base64 -d > "${settings_xml}"
settings="$(mktemp)"
java -jar "${SCRIPT_FOLDER}/.maven-decrypter.jar" -s "${settings_xml}" "${settings_security_xml}" > "${settings}"
rm -f "${settings_xml}"

if [[ -f "${PASSWORD_STORE_DIR}/bots/${projectFullName}/apache-maven-security-settings/master-password.gpg" ]]; then
  masterPasswordInPass="$(pass "bots/${projectFullName}/apache-maven-security-settings/master-password")"
  masterPasswordDeployed="$(jq '.masterPassword' "${settings}")"
  if [[ "${masterPasswordInPass}" == "${masterPasswordDeployed}" ]]; then
    echo "INFO: Deployed master password is identical to the one stored in pass"
  else
    echo "WARNING: Deployed master password is different from the one stored in pass"
    printf "  In pass : %s\n" "${masterPasswordInPass}"
    printf "  Deployed: %s\n" "${masterPasswordDeployed}"
  fi
fi

rm -f "${settings}"

for settingsFilename in $(jq -r '.maven.files | keys - ["settings-security.xml"] | .[]' "${config}"); do
  echo "INFO: Checking ${settingsFilename}"

  # get and decrypt settings*.xml
  settings_xml="$(mktemp)"
  kubectl get secret -n "${namespace}" "${secret_name}" -o json | jq -r ".data[\"${settingsFilename}\"]"  | base64 -d > "${settings_xml}"
  settings="$(mktemp)"
  java -jar "${SCRIPT_FOLDER}/.maven-decrypter.jar" -s "${settings_xml}" "${settings_security_xml}" > "${settings}"
  rm -f "${settings_xml}"

  for serverId in $(jq -r '.maven.files["'"${settingsFilename}"'"] | .servers | keys | .[]' "${config}"); do
    server="$(jq -c '.maven.files["'"${settingsFilename}"'"].servers["'"${serverId}"'"]' "${config}")"
    usernamePassPath="$(jq -r '.username.pass' <<< "${server}")"
    passwordPassPath="$(jq -r '.password.pass' <<< "${server}")"
    passphrasePassPath="$(jq -r '.passphrase.pass' <<< "${server}")"
    if [[ -f "${PASSWORD_STORE_DIR}/${usernamePassPath}.gpg" ]] \
      && [[ -f "${PASSWORD_STORE_DIR}/${passwordPassPath}.gpg" ]]; then
      
      passwordInPass="$(pass "${passwordPassPath}")"
      usernameInPass="$(pass "${usernamePassPath}")"
      nexusProUrl="$(jq -r '.nexusProUrl | select (.!=null)' <<< "${server}")"
      if [[ -n "${nexusProUrl}" ]]; then
        token="$("${SCRIPT_FOLDER}/../build/nexus-pro-token.sh" get_or_create "${nexusProUrl}" "${usernameInPass}" "${passwordInPass}" )"
      fi
      
      usernameDeployed="$(jq -r '.servers[] | select(.id == "'"${serverId}"'").username' "${settings}")"
      if [[ "${usernameInPass}" == "${usernameDeployed}" ]]; then
        echo "INFO: Deployed username for server ${serverId} is identical to the one in pass"
      else
        if [[ -n "${nexusProUrl}" ]] && [[ -n "${token}" ]]; then
          usernameNexus="$(jq -r '.nameCode' <<< "${token}")"
          if [[ "${usernameNexus}" == "${usernameDeployed}" ]]; then
            echo "INFO: Deployed username for server ${serverId} is identical to the token from ${nexusProUrl}"
          else
            echo "ERROR: Deployed username for server ${serverId} is different from both the one in pass and the token from ${nexusProUrl}"
            printf "  In pass : %s\n" "${usernameInPass}"
            printf "  Deployed: %s\n" "${usernameDeployed}"
            printf "  Nexus   : %s\n" "${usernameNexus}"
          fi
        else 
          echo "ERROR: Deployed username for server ${serverId} is different from the one in pass"
          printf "  In pass : %s\n" "${usernameInPass}"
          printf "  Deployed: %s\n" "${usernameDeployed}"
          echo "  (Note that no Nexus URL was set or the token was impossible to get)"
        fi
      fi

      passwordDeployed="$(jq -r '.servers[] | select(.id == "'"${serverId}"'").password' "${settings}" | base64 -d)"
      if [[ "${passwordInPass}" == "${passwordDeployed}" ]]; then
        echo "INFO: Deployed password for server ${serverId} is identical to the one in pass"
      else
        if [[ -n "${nexusProUrl}" ]] && [[ -n "${token}" ]]; then
          passwordNexus="$(jq -r '.passCode' <<< "${token}")"
          if [[ "${passwordNexus}" == "${passwordDeployed}" ]]; then
            echo "INFO: Deployed password for server ${serverId} is identical to the token from ${nexusProUrl}"
          else
            echo "ERROR: Deployed password for server ${serverId} is different from both the one in pass and the token from ${nexusProUrl}"
            printf "  In pass : %s\n" "${passwordInPass}"
            printf "  Deployed: %s\n" "${passwordDeployed}"
            printf "  Nexus   : %s\n" "${passwordNexus}"
          fi
        else 
          echo "ERROR: Deployed password for server ${serverId} is different from the one in pass"
          printf "  In pass : %s\n" "${passwordInPass}"
          printf "  Deployed: %s\n" "${passwordDeployed}"
          echo "  (Note that no Nexus URL was set for this server or the token was impossible to get)"
        fi
      fi
    elif [[ -f "${PASSWORD_STORE_DIR}/${passphrasePassPath}.gpg" ]]; then
      passphraseInPass="$(pass "${passphrasePassPath}")"
      passphraseDeployed="$(jq -r '.servers[] | select(.id == "'"${serverId}"'").password' "${settings}" | base64 -d)"
      if [[ "${passphraseInPass}" == "${passphraseDeployed}" ]]; then
        echo "INFO: Deployed passphrase for server ${serverId} is identical to the one in pass"
      else
        echo "ERROR: Deployed passphrase for server ${serverId} is different from the one in pass"
        printf "  In pass : %s\n" "${passphraseInPass}"
        printf "  Deployed: %s\n" "${passphraseDeployed}"
      fi
    fi
  done
  echo
  rm -f "${settings}"
done

rm -f "${settings_security_xml}"
