#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "jenkins-instance-limit-range-default"
  namespace: "{{JENKINS_NAMESPACE}}"
spec:
  limits:
    - type: "Pod"
      min:
        cpu: 200m
        memory: 8Mi
    - type: "Container"
      min:
        cpu: 100m
        memory: 4Mi
      default:
        cpu: 500m
        memory: 512Mi
      defaultRequest:
        cpu: 300m 
        memory: 512Mi