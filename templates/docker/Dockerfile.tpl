#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
# <templates/Dockerfile.tpl>
FROM {{JENKINS_MASTER_PARENT_IMAGE}}

EXPOSE {{JENKINS_UI_PORT}}
EXPOSE {{JENKINS_JNLP_PORT}}

RUN mkdir -p {{JENKINS_REF}}/userContent/theme/
COPY eclipse-theme.css.override {{JENKINS_REF}}/userContent/theme/
# </templates/Dockerfile.tpl>

