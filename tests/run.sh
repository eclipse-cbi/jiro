#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

JAVA_OPTS="-XshowSettings:vm \
  -Djdk.nativeCrypto=false \
  -Dsun.zip.disableMemoryMapping=true \
  -Dhudson.lifecycle=hudson.lifecycle.ExitLifecycle \
  -Djenkins.model.Jenkins.slaveAgentPort=50000 \
  -Djenkins.model.Jenkins.slaveAgentPortEnforce=true \
  -Djenkins.slaves.JnlpSlaveAgentProtocol3.enabled=false \
  -Djenkins.install.runSetupWizard=false"

JENKINS_OPTS="--prefix=/jenkins \
  --webroot=/var/cache/jenkins/war \
  --pluginroot=/var/cache/jenkins/plugins"

TEST_IMAGE="testjenkins:latest"

docker build --rm -t ${TEST_IMAGE} \
  -f ${SCRIPT_FOLDER}/Dockerfile ${SCRIPT_FOLDER}

docker run -it --rm -e JAVA_OPTS="${JAVA_OPTS}" -e JENKINS_OPTS="${JENKINS_OPTS}" \
  -p 8080:8080 -p 50000:50000 ${TEST_IMAGE}