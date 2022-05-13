#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2022 Eclipse Foundation and others.
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

print_version() {
  if [ $# -ge 1 ] && [ -n "$1" ]
  then
    echo "${1##* }" 
  fi
}

## Install dependencies on Ubuntu based distros

#TODO: support other distros and OS

# jsonnet - https://github.com/google/jsonnet/
if ! hash jsonnet &> /dev/null; then
  echo "jsonnet could not be found. Installing..."
  sudo apt install -y jsonnet
  echo -n "jsonnet version : "; print_version "$(jsonnet --version)"
else
  echo -n "jsonnet was found, version : "; print_version "$(jsonnet --version)"
fi

# yq - https://github.com/mikefarah/yq
if ! hash yq &> /dev/null; then
  echo "yq could not be found. Installing..."
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod a+x /usr/local/bin/yq
  echo -n "yq version : "; print_version "$(yq --version)"
else
  echo -n "yq was found, version : "; print_version "$(yq --version)"
fi

# jq - https://stedolan.github.io/jq/ 
if ! hash jq &> /dev/null; then
  echo "jq could not be found. Installing..."
  sudo wget -qO /usr/local/bin/jq https://github.com/stedolan/jq/releases/latest/download/jq-linux64
  sudo chmod a+x /usr/local/bin/jq
  echo -n "jq version : "; print_version "$(jq --version)"
else
  echo -n "jq was found, version : "; print_version "$(jq --version)"
fi

# hbs - https://www.npmjs.com/package/hbs-cli
if ! hash hbs &> /dev/null; then
  echo "hbs could not be found. Installing..."
  
  if ! hash npm &> /dev/null; then
    echo "npm could not be found. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo -n "npm version : "; print_version "$(npm --version)"
  else
    echo -n "npm was found, version : "; print_version "$(npm --version)"
  fi
  
  sudo npm i -g hbs-cli
  echo -n "hbs version : "; print_version "$(hbs --version)"
else
  echo -n "hbs was found, version : "; print_version "$(hbs --version)"
fi

