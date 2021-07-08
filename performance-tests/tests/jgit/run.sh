#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
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

WORKSPACE="$(mktemp -d)"
cd "${WORKSPACE}"

echo "INFO: Cloning https://git.eclipse.org/r/jgit/jgit..."
git clone https://git.eclipse.org/r/jgit/jgit .

echo "INFO: Checkouting tags/v5.8.1.202007141445-r..."
git checkout --quiet -b v5.8.1.202007141445-r v5.8.1.202007141445-r

"${JAVA_HOME}/bin/java" -version
mkdir -p "${WORKSPACE}/tmp"

echo "INFO: Downloading maven-3.6.3..."
curl -sSLf https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz | tar zxf - 
PATH="${WORKSPACE}/apache-maven-3.6.3/bin:${PATH}"

echo "INFO: Run tests..."
mvn -V -B --errors -T 2 \
  -Dmaven.repo.local="${WORKSPACE}/.repository" \
  -Djava.io.tmpdir="${WORKSPACE}/tmp/" \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
  -Declipse.p2.mirrors=false \
  -f pom.xml \
  -Pstatic-checks,ecj \
  -Djgit.test.long=true \
  clean \
  verify \
  pmd:pmd

echo "INFO: Build..."
mvn -V -B --errors -T 2 \
  -Dmaven.repo.local="${WORKSPACE}/.repository" \
  -Djava.io.tmpdir="${WORKSPACE}/tmp/" \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
  -Declipse.p2.mirrors=false \
  -f pom.xml \
  -Pecj \
  -DskipTests=true \
  install #\
#-Peclipse-sign,ecj \ # we don't sign
#  deploy:deploy # we don't deploy in this test

echo "INFO: Deploy (fake)..."
mvn -V -B --errors -T 2 \
  -Dmaven.repo.local="${WORKSPACE}/.repository" \
  -Djava.io.tmpdir="${WORKSPACE}/tmp/" \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
  -Declipse.p2.mirrors=false \
  clean \
  install \
  -f org.eclipse.jgit.packaging/pom.xml #\
  #deploy:deploy \
  #-Peclipse-sign \
  #-Peclipse-pack \

