#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
  name: "{{JENKINS_STS_NAME}}"
  namespace: "{{JENKINS_NAMESPACE}}"
spec:
  replicas: 1
  selector:
    matchLabels:
      org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
  serviceName: "{{JENKINS_SHORT_NAME}}"
  template:
    metadata:
      labels:
        org.eclipse.jenkins.master.shortname: "{{JENKINS_SHORT_NAME}}"
      name: "{{JENKINS_SHORT_NAME}}"
    spec:
      serviceAccountName: {{JENKINS_SHORT_NAME}}
      terminationGracePeriodSeconds: 1200
      containers:
      - name: jenkins
        image: {{JENKINS_MASTER_IMAGE}}:{{JENKINS_MASTER_IMAGE_TAG}}@sha256:{{JENKINS_MASTER_IMAGE_SHA256}}
        imagePullPolicy: IfNotPresent
        livenessProbe:
          httpGet:
            path: {{JENKINS_PREFIX}}/login
            port: {{JENKINS_UI_PORT}}
            scheme: HTTP
          initialDelaySeconds: {{JENKINS_LIVENESS_DELAY}}
          periodSeconds: {{JENKINS_LIVENESS_PERIOD}}
          failureThreshold: {{JENKINS_LIVENESS_FAILURE_THRESHOLD}}
          timeoutSeconds: {{JENKINS_LIVENESS_TIMEOUT}}
        readinessProbe: 
          httpGet:
            path: {{JENKINS_PREFIX}}/login
            port: {{JENKINS_UI_PORT}}
          periodSeconds: {{JENKINS_READINESS_PERIOD}}
          timeoutSeconds: {{JENKINS_READINESS_TIMEOUT}}
          initialDelaySeconds: {{JENKINS_READINESS_DELAY}}
        ports:
        - containerPort: {{JENKINS_UI_PORT}}
          protocol: TCP
        - containerPort: {{JENKINS_JNLP_PORT}}
          protocol: TCP
        resources:
          requests:
            cpu: {{JENKINS_CPU_REQUEST}}
          limits:
            cpu: {{JENKINS_CPU_LIMIT}}
            memory: {{JENKINS_MEMORY_LIMIT}}
        volumeMounts:
        - mountPath: "{{JENKINS_HOME}}"
          name: jenkins-home
        - mountPath: "{{JENKINS_WEB_ROOT}}"
          name: jenkins-war
        - mountPath: "{{JENKINS_PLUGIN_ROOT}}"
          name: jenkins-plugins
        - mountPath: "/etc/jenkins/"
          name: jenkins-config
          readOnly: true
        - mountPath: "/run/secrets/jenkins"
          name: jenkins-secrets
          readOnly: true
        env:
          - name: JAVA_OPTS
              # -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle
              # -Xshareclasses:verbose,name=jenkins,cacheDir=/var/cache/openj9/sharedclasses/jenkins,groupAccess,fatal
              # Djdk.nativeCrypto=false is a workaround for 
              # https://github.com/eclipse/openj9/issues/3637
            value: >-
              -XshowSettings:vm 
              -Djdk.nativeCrypto=false
              -Dsun.zip.disableMemoryMapping=true
              -Dhudson.lifecycle=hudson.lifecycle.ExitLifecycle
              -Dhudson.slaves.NodeProvisioner.initialDelay=0
              -Dhudson.slaves.NodeProvisioner.MARGIN=50
              -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85
              -Dhudson.footerURL=https://{{JENKINS_HOST}}
              -Djenkins.model.Jenkins.slaveAgentPort={{JENKINS_JNLP_PORT}}
              -Djenkins.model.Jenkins.slaveAgentPortEnforce=true
              -Djenkins.slaves.JnlpSlaveAgentProtocol3.enabled=false
              -Djenkins.install.runSetupWizard=false
              -Dcasc.jenkins.config=/etc/jenkins/jenkins.yaml
              -Dorg.csanchez.jenkins.plugins.kubernetes.pipeline.PodTemplateStepExecution.defaultImage=eclipsecbi/jenkins-jnlp-agent:3.25@sha256:62913fe4840a51e81dd00b8ec0af31e78930f8c3a3eaaf15dca821d42b71a16d
          - name: JENKINS_OPTS
            value: >- 
              --prefix={{JENKINS_PREFIX}}
              --webroot={{JENKINS_WEB_ROOT}}
              --pluginroot={{JENKINS_PLUGIN_ROOT}}
          - name: SECRETS
            value: /run/secrets/jenkins
      volumes:
      - name: jenkins-war
        emptyDir: {}
      - name: jenkins-plugins
        emptyDir: {}
      - name: jenkins-config
        configMap:
          name: jenkins-config
      - name: jenkins-secrets
        secret:
          secretName: jenkins-secrets
  volumeClaimTemplates:
  - metadata:
      name: jenkins-home
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 50Gi
