#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

script_name="$(basename ${0})"
short_name="${1:-}"
temp_yaml_name="temp.yml"
result_yaml_name="nodes.yml"

if [[ -z "${short_name}" ]]; then
  printf "ERROR: short name must not be empty\n"
  exit 1
fi

printf "Short name: ${short_name}\n"

# the executable name is different on some OSes (e.g. it's 'xml' on SuSE)
xmlstarlet_bin=xmlstarlet

#TODO: check parameters

xmlstarlet_wrapper() {
  # hide "Unsupported version '1.1'" errors
  ${xmlstarlet_bin} "$@" 2>/dev/null
}

create_node() {
  local name=$1
  local description=$2
  local label=$3
  local remotefs=$4
  local executors=$5
  cat <<EOF  >> ${temp_yaml_name}
  - permanent:
      name: "${name}"
      nodeDescription: "${description}"
      labelString: "${label}"
      remoteFS: '${remotefs}'
      numExecutors: ${executors}
      mode: EXCLUSIVE
      retentionStrategy: "always"
EOF
}

create_launcher() {
  local filename=$1

  class=$(xmlstarlet_wrapper sel -T -t -v "/slave/launcher/@class" ${filename})
  
  if [[ ${class} == "hudson.plugins.sshslaves.SSHLauncher" ]]; then
    host=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/host" ${filename})
    port=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/port" ${filename})
    credentials_id=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/credentialsId" ${filename})
    java_path=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/javaPath" ${filename} || true)
    #fix javapath
#    java_path=${java_path/shared\/common/opt\/tools}
#    java_path=${java_path/jdk1.5.0-latest/oracle-jdk5-latest}
#    java_path=${java_path/jdk1.6.0-latest/oracle-jdk6-latest}
#    java_path=${java_path/jdk1.7.0-latest/oracle-jdk7-latest}
#    java_path=${java_path/jdk1.8.0-latest/oracle-jdk8-latest}
    #TODO: jvmOptions

    #use ssh-keyscan to get host key
    if [[ ${host} == *".eclipse.org"* ]]; then
      #only works for internal agents
      #TODO: more than one line!?
      key=$(ssh -C foundation "ssh-keyscan ${host} | grep ssh-rsa")
    else
      #only works for external agents
      key=$(ssh-keyscan ${host} | grep ssh-rsa)
    fi

    #remove host from beginning of line
    key=${key/${host} /}
    cat <<EOJ  >> ${temp_yaml_name}
      launcher:
        ssh:
          host: "${host}"
          port: "${port}"
          credentialsId: "${credentials_id}"
          javaPath: "${java_path}"
          sshHostKeyVerificationStrategy:
            manuallyProvidedKeyVerificationStrategy:
              key: "${key}"
EOJ
  elif [[ ${class} == "hudson.slaves.CommandLauncher" ]]; then
    command=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/agentCommand" ${filename})
    #fix host
    command=${command/ci.eclipse.org/ci-staging.eclipse.org}

    cat <<EOK  >> ${temp_yaml_name}
      launcher:
        command:
          command: '${command}'
EOK
  elif [[ ${class} == "hudson.slaves.JNLPLauncher" ]]; then
    tunnel=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/tunnel" ${filename})
    
    disabled=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/workDirSettings/disabled" ${filename})
    internalDir=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/workDirSettings/internalDir" ${filename})
    failIfWorkDirIsMissing=$(xmlstarlet_wrapper sel -T -t -c "/slave/launcher/workDirSettings/failIfWorkDirIsMissing" ${filename})
    #TODO: workDirPath

    cat <<EOL  >> ${temp_yaml_name}
      launcher:
        jnlp:
          tunnel: "${tunnel}"
          workDirSettings:
            disabled: ${disabled}
            internalDir: "${internalDir}"
            failIfWorkDirIsMissing: ${failIfWorkDirIsMissing}
EOL
  fi
}

create_node_properties() {
  local filename=$1
  env_count=$(xmlstarlet_wrapper sel -t -v "count(//envVars/tree-map/string)" ${filename})
  tools_count=$(xmlstarlet_wrapper sel -t -v "count(//hudson.tools.ToolLocationNodeProperty/locations/hudson.tools.ToolLocationNodeProperty_-ToolLocation)" ${filename})

  if [[ ${env_count} > 0 || ${tools_count} > 0 ]]; then
    cat <<EOM  >> ${temp_yaml_name}
      nodeProperties:
EOM
fi

  # Env variables
  if [[ ${env_count} > 0 ]]; then
    cat <<EOH  >> ${temp_yaml_name}
      - envVars:
          env:
EOH
    for (( i=1; i < ${env_count}; i++ ))
    do
      env_key=$(xmlstarlet_wrapper sel -T -t -c "//envVars/tree-map/string[${i}]" ${filename})
      i=$((i+1))
      env_value=$(xmlstarlet_wrapper sel -T -t -c "//envVars/tree-map/string[${i}]" ${filename})
      cat <<EOG  >> ${temp_yaml_name}
          - key: "${env_key}"
            value: '${env_value}'
EOG
    done
  fi

  # Tool Locations
  if [[ ${tools_count} > 0 ]]; then
    cat <<EON  >> ${temp_yaml_name}
      - toolLocation:
          locations:
EON
    for (( i=1; i <= ${tools_count}; i++ ))
    do
      type=$(xmlstarlet_wrapper sel -T -t -c "////hudson.tools.ToolLocationNodeProperty/locations/hudson.tools.ToolLocationNodeProperty_-ToolLocation[${i}]/type" ${filename})
      name=$(xmlstarlet_wrapper sel -T -t -c "////hudson.tools.ToolLocationNodeProperty/locations/hudson.tools.ToolLocationNodeProperty_-ToolLocation[${i}]/name" ${filename})
      home=$(xmlstarlet_wrapper sel -T -t -c "////hudson.tools.ToolLocationNodeProperty/locations/hudson.tools.ToolLocationNodeProperty_-ToolLocation[${i}]/home" ${filename})
      cat <<EOO  >> ${temp_yaml_name}
          - home: '${home}'
            key: "${type}@${name}"
EOO
    done
  fi

# TODO: "Disable Xvnc execution on this node" (not supported by JCasC yet?)

}

read_xml() {
  local filename=$1
  name=$(xmlstarlet_wrapper sel -T -t -c "/slave/name" ${filename})
  description=$(xmlstarlet_wrapper sel -T -t -c "/slave/description" ${filename})
  label=$(xmlstarlet_wrapper sel -T -t -c "/slave/label" ${filename})
  remotefs=$(xmlstarlet_wrapper sel -T -t -c "/slave/remoteFS" ${filename})
  executors=$(xmlstarlet_wrapper sel -T -t -c "/slave/numExecutors" ${filename})
  create_node "${name}" "${description}" "${label}" "${remotefs}" "${executors}"
 
  create_launcher ${filename}

  create_node_properties ${filename}
  
  cat ${temp_yaml_name}
}

create_nodes_yaml() {
  local shortname=$1
  cat <<EOI  > ${shortname}/${result_yaml_name}
jenkins:
  nodes:
EOI

  for node in ${shortname}/nodes/*/
  do
    echo $node
    > ${temp_yaml_name}
    read_xml ${node}config.xml >> ${shortname}/${result_yaml_name}
  done
}

create_nodes_yaml ${short_name}