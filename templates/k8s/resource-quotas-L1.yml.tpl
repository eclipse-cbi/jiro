#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
apiVersion: v1
kind: ResourceQuota
metadata:
  name: jenkins-instance-quota
  namespace: "{{JENKINS_NAMESPACE}}"
  labels:
    org.eclipse.cbi.resource_pack.id: "L1"
spec:
  hard:
    # Jenkins master + 4 agents
    pods: 3
    # Jenkins master 50 + 4 agents 4*20 = 130GB
    requests.storage: 130Gi
    # (Jenkin master 0.5 + JNLP agents 4x0.3)=1.7 + 4vCPU
    requests.cpu: 5.7
    # (Jenkin master 1.5 + JNLP agents 4x512MB)=3.5 + 8GB
    requests.memory: 11.5Gi
    # (Jenkins master 1 + JNLP agents 4x0.4)=2.6 + 4vCPU
    limits.cpu: 6.6
    limits.memory: 11.5Gi