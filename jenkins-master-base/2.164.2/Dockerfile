#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
FROM eclipsecbijenkins/openshift-java:jdk8u212-b04_openj9-0.14.2

ARG JENKINS_HOME
ENV JENKINS_HOME="${JENKINS_HOME}"

ARG JENKINS_REF
ENV JENKINS_REF="${JENKINS_REF}"

ARG USERNAME
# These environment variables will be used in the uid_entrypoint script from the parent image
ENV USERNAME="${USERNAME}"
ENV HOME="${JENKINS_HOME}"

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION="${JENKINS_VERSION}"
ARG JENKINS_WAR
ENV JENKINS_WAR="${JENKINS_WAR}"

ARG JENKINS_WEB_ROOT
ARG JENKINS_PLUGIN_ROOT

ARG JENKINS_UC
ENV JENKINS_UC="${JENKINS_UC}"

RUN mkdir -p $JENKINS_HOME && \
  chmod_container_user rwx $JENKINS_HOME && \ 
  mkdir -p ${JENKINS_WEB_ROOT} && \
  chmod_container_user rwx ${JENKINS_WEB_ROOT} && \
  mkdir -p ${JENKINS_PLUGIN_ROOT} && \
  chmod_container_user rwx ${JENKINS_PLUGIN_ROOT} && \
  mkdir -p ${JENKINS_REF} && \
  mkdir -p $(dirname ${JENKINS_WAR})

VOLUME ["${JENKINS_HOME}", "${JENKINS_WEB_ROOT}", "${JENKINS_PLUGIN_ROOT}" ]

COPY init.groovy.d/* ${JENKINS_REF}/init.groovy.d/

ARG JENKINS_WAR_BASE_URL="https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}"
COPY jenkins.war.pub.asc "${JENKINS_WAR}.pub.asc"
RUN curl -sfSL "${JENKINS_WAR_BASE_URL}/jenkins-war-${JENKINS_VERSION}.war.asc" -o "${JENKINS_WAR}.asc" && \
  curl -sfSL "${JENKINS_WAR_BASE_URL}/jenkins-war-${JENKINS_VERSION}.war" -o "${JENKINS_WAR}" && \
  gpg -q --batch --import "${JENKINS_WAR}.pub.asc" && \
  echo -e "5\ny\n" |  gpg -q --batch --command-fd 0 --expert --edit-key 9B7D32F2D50582E6 trust 2> /dev/null && \
  gpg -q --batch --verify "${JENKINS_WAR}.asc" "${JENKINS_WAR}" 2>&1 /dev/null

COPY ./scripts /usr/local/bin
RUN chmod ug+x /usr/local/bin/*
RUN chmod_container_user "rx" /usr/local/bin/install-plugins.sh

COPY base-plugins ${JENKINS_REF}/
RUN /usr/local/bin/install-plugins.sh < ${JENKINS_REF}/base-plugins

ENTRYPOINT ["uid_entrypoint", "/usr/bin/dumb-init", "--", "/usr/local/bin/jenkins.sh"]
