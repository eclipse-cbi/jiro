# GENERATED FILE - DO NOT EDIT

#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
# <templates/Dockerfile.tpl>
FROM eclipsecbijenkins/jenkins-master-base:2.150.2

EXPOSE 8080
EXPOSE 50000

RUN mkdir -p /usr/share/jenkins/ref/userContent/theme/
COPY jenkins/quicksilver.css.override /usr/share/jenkins/ref/userContent/theme/
# </templates/Dockerfile.tpl>

# <gen-dockerfile.sh>
COPY jenkins/plugins-list /usr/share/jenkins/ref/plugins-list
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins-list
USER 10001
# </gen-dockerfile.sh>

