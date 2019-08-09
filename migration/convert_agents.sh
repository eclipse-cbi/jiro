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

#TODO: check parameters

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

  class=$(xmlstarlet sel -T -t -v "/slave/launcher/@class" ${filename})
  
  if [[ ${class} == "hudson.plugins.sshslaves.SSHLauncher" ]]; then
    host=$(xmlstarlet sel -T -t -c "/slave/launcher/host" ${filename})
    port=$(xmlstarlet sel -T -t -c "/slave/launcher/port" ${filename})
    credentials_id=$(xmlstarlet sel -T -t -c "/slave/launcher/credentialsId" ${filename})
    java_path=$(xmlstarlet sel -T -t -c "/slave/launcher/javaPath" ${filename})
    #fix javapath
#    java_path=${java_path/shared\/common/opt\/tools}
#    java_path=${java_path/jdk1.5.0-latest/oracle-jdk5-latest}
#    java_path=${java_path/jdk1.6.0-latest/oracle-jdk6-latest}
#    java_path=${java_path/jdk1.7.0-latest/oracle-jdk7-latest}
#    java_path=${java_path/jdk1.8.0-latest/oracle-jdk8-latest}
    #TODO: jvmOptions

    #use ssh-keyscan to get host key
    #only works for external slaves
    #key=$(ssh-keyscan ${host} | grep ssh-rsa)
    #only works for internal slaves
    #TODO: more than one line!?
    #key=$(ssh -C foundation "ssh-keyscan centslave2.eclipse.org | grep ssh-rsa")
    #TODO: remove host from beginning of line
    key="ssh-rsa FIXME"
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
    command=$(xmlstarlet sel -T -t -c "/slave/launcher/agentCommand" ${filename})
    #fix host
    command=${command/ci.eclipse.org/ci-staging.eclipse.org}

    cat <<EOK  >> ${temp_yaml_name}
      launcher:
        command:
          command: "${command}"
EOK
  fi
}

create_env_variables() {
  local filename=$1
  count=$(xmlstarlet sel -t -v "count(//envVars/tree-map/string)" ${filename})

  if [[ ${count} > 0 ]]; then
    cat <<EOH  >> ${temp_yaml_name}
      nodeProperties:
      - envVars:
EOH
    for (( i=1; i < ${count}; i++ ))
    do
      env_key=$(xmlstarlet sel -T -t -c "//envVars/tree-map/string[${i}]" ${filename})
      i=$((i+1))
      env_value=$(xmlstarlet sel -T -t -c "//envVars/tree-map/string[${i}]" ${filename})
      cat <<EOG  >> ${temp_yaml_name}
          env:
          - key: "${env_key}"
            value: "${env_value}"
EOG
    done
  fi
}

read_xml() {
  local filename=$1
  name=$(xmlstarlet sel -T -t -c "/slave/name" ${filename})
  description=$(xmlstarlet sel -T -t -c "/slave/description" ${filename})
  label=$(xmlstarlet sel -T -t -c "/slave/label" ${filename})
  remotefs=$(xmlstarlet sel -T -t -c "/slave/remoteFS" ${filename})
  executors=$(xmlstarlet sel -T -t -c "/slave/numExecutors" ${filename})

  create_node ${name} ${description} ${label} ${remotefs} ${executors}
 
  create_launcher ${filename}

  create_env_variables ${filename}
  
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
    read_xml ${node}/config.xml >> ${shortname}/${result_yaml_name}
  done
}

create_nodes_yaml ${short_name}