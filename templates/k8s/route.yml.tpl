#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
apiVersion: "route.openshift.io/v1"
kind: "Route"
metadata:
  labels:
    org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
  name: "{{JENKINS_SHORT_NAME}}"
  namespace: "{{JENKINS_NAMESPACE}}"
spec:
  host: "{{JENKINS_HOST}}"
  path: "{{JENKINS_PREFIX}}"
  port:
    targetPort: "http"
  tls:
    insecureEdgeTerminationPolicy: "Redirect"
    termination: "edge"
  to:
    kind: "Service"
    name: "jenkins-ui"
    weight: 100
