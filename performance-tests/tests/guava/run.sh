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

echo "INFO: Downloading maven-3.6.3..."
curl -sSLf https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz | tar zxf - 

echo "INFO: Cloning https://github.com/google/guava..."
git clone --quiet https://github.com/google/guava 
cd guava 

echo "INFO: Checkouting tags/v30.1.1..."
git checkout --quiet -b v30.1.1 v30.1.1

echo "INFO: Building with Maven..."
../apache-maven-3.6.3/bin/mvn -V -B -Dmaven.repo.local="$(pwd)/m2repo" -Dmaven.repo.remote="https://repo.eclipse.org" -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn install -U -DskipTests=true 

echo "INFO: Running tests..."
if ! ../apache-maven-3.6.3/bin/mvn -V -B -Dmaven.repo.local="$(pwd)/m2repo" -Dmaven.repo.remote="https://repo.eclipse.org" -P!standard-with-extra-repos verify -U -Dmaven.javadoc.skip=true; then
  ./util/print_surefire_reports.sh
fi

echo "INFO: Done!"
