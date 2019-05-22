#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
FROM adoptopenjdk/openjdk8-openj9:jdk8u202-b08-alpine-slim

# Workaround for https://github.com/AdoptOpenJDK/openjdk-docker/issues/75
# SEVERE: Failed to initialize Jenkins
# hudson.util.AWTProblem: java.lang.NullPointerException
#         at hudson.WebAppMain.contextInitialized(WebAppMain.java:193)
# ...
# Caused by: java.lang.NullPointerException
#         at sun.awt.FontConfiguration.getVersion(FontConfiguration.java:1264)
RUN ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1
ENV LD_LIBRARY_PATH /usr/lib

RUN apk add --no-cache \
  bash \
  coreutils \
  curl \
  dumb-init \
  git \
  gnupg \
  openssh-client \
  rsync \
  ttf-dejavu \
  unzip \
  wget

COPY ./scripts /usr/local/bin
RUN chmod_container_user "rw" /etc/passwd && \
  chmod_container_user "rx" /usr/local/bin/uid_entrypoint

ENTRYPOINT [ "uid_entrypoint" ]