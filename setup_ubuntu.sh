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

## Install dependencies on Ubuntu based distros

#TODO: support other distros and OS

# jsonnet - https://github.com/google/jsonnet/
if ! hash jsonnet &> /dev/null; then
  echo "jsonnet could not be found. Installing..."
  sudo apt install -y jsonnet
else
  echo "jsonnet was found."
fi

# yq - https://mikefarah.github.io/yq/
if ! hash yq &> /dev/null; then
  echo "yq could not be found. Installing..."
  #TODO: apt-key is deprecated
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64
  sudo add-apt-repository ppa:rmescandon/yq
  sudo apt update
  sudo apt install -y yq
else
  echo "yq was found."
fi

# jq - https://stedolan.github.io/jq/ 
if ! hash jq &> /dev/null; then
  echo "jq could not be found. Installing..."
  sudo apt-get install -y jq
else
  echo "jq was found."
fi

# hbs - https://www.npmjs.com/package/hbs-cli
if ! hash hbs &> /dev/null; then
  echo "hbs could not be found. Installing..."
  
  if ! hash npm &> /dev/null; then
    echo "npm could not be found. Installing..."
    sudo apt-get install -y npm
  else
    echo "npm was found."
  fi
  
  sudo npm i -g hbs-cli
else
  echo "hbs was found."
fi
