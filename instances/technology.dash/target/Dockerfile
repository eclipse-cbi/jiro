# GENERATED FILE - DO NOT EDIT

#*******************************************************************************
# Copyright (c) 2018-2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
# <templates/Dockerfile.tpl>
FROM docker.io/eclipsecbi/jiro-master:2.235.1-jdk11

EXPOSE 8080
EXPOSE 50000

RUN mkdir -p /usr/share/jenkins/ref/userContent/theme/
COPY jenkins/quicksilver.css.override /usr/share/jenkins/ref/userContent/theme/
COPY jenkins/title.js /usr/share/jenkins/ref/userContent/theme/
# </templates/Dockerfile.tpl>

# <gen-dockerfile.sh>
USER 10001
# </gen-dockerfile.sh>

