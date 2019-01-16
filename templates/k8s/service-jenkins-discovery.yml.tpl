#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
apiVersion: "v1"
kind: "Service"
metadata:
  labels:
    org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
  name: "jenkins-discovery"
  namespace: "{{JENKINS_NAMESPACE}}"
spec:
  ports:
  - name: "jnlp"
    port: {{JENKINS_JNLP_PORT}}
    protocol: "TCP"
    targetPort: {{JENKINS_JNLP_PORT}}
  selector:
    org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
