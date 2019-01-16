#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************
jenkins:
  numExecutors: 0
  scmCheckoutRetryCount: 2
  mode: NORMAL
  
  globalNodeProperties:
    - envVars:
        env:
          - key: FOO
            value: BAR

  disableRememberMe: false
  agentProtocols:
    - "JNLP4-connect"
    - "Ping"

  authorizationStrategy:
    projectMatrix:
      grantedPermissions:
        - "Overall/Read:anonymous"
        - "Overall/Administer:admins"
        - "Credentials/View:{{JENKINS_FULL_NAME}}"
        - "Job/Read:anonymous"
        - "Job/ExtendedRead:common"
        - "Job/Build:{{JENKINS_FULL_NAME}}"
        - "Job/Create:{{JENKINS_FULL_NAME}}"
        - "Job/Delete:{{JENKINS_FULL_NAME}}"
        - "Job/Move:{{JENKINS_FULL_NAME}}"
        - "Job/Cancel:{{JENKINS_FULL_NAME}}"
        - "Job/Configure:{{JENKINS_FULL_NAME}}"
        - "Job/Workspace:{{JENKINS_FULL_NAME}}"
        - "Run/Delete:{{JENKINS_FULL_NAME}}"
        - "Run/Replay:{{JENKINS_FULL_NAME}}"
        - "Run/Update:{{JENKINS_FULL_NAME}}"
        - "View/Read:{{JENKINS_FULL_NAME}}"
        - "View/Delete:{{JENKINS_FULL_NAME}}"
        - "View/Create:{{JENKINS_FULL_NAME}}"
        - "View/Configure:{{JENKINS_FULL_NAME}}"
        - "SCM/Tag:{{JENKINS_FULL_NAME}}"

  markupFormatter: rawHtml
  crumbIssuer: 
    standard:
       excludeClientIPFromCrumb: false
  remotingSecurity:
    enabled: true

  securityRealm:
    ldap:
      configurations:
        - server: ldapmaster
          rootDN: dc=eclipse,dc=org
          groupMembershipStrategy: fromGroupSearch
          groupSearchBase: ou=group
          userSearch: mail={0}
          displayNameAttributeName: cn
          mailAddressAttributeName: mail

  clouds:
  - kubernetes:
      name: "kubernetes"
      containerCapStr: "{{JENKINS_JOB_CONCURRENCY}}"
      jenkinsUrl: "http://jenkins-ui.{{JENKINS_SHORT_NAME}}.svc.cluster.local{{JENKINS_PREFIX}}"
      jenkinsTunnel: "jenkins-discovery.{{JENKINS_SHORT_NAME}}.svc.cluster.local:{{JENKINS_JNLP_PORT}}"
      maxRequestsPerHostStr: "32"
      namespace: "{{JENKINS_SHORT_NAME}}"
      podRetention: "onFailure"
      templates:
      - containers:
        - image: "eclipsecbi/jenkins-jnlp-agent:3.25@sha256:62913fe4840a51e81dd00b8ec0af31e78930f8c3a3eaaf15dca821d42b71a16d"
          livenessProbe:
            failureThreshold: 0
            initialDelaySeconds: 0
            periodSeconds: 0
            successThreshold: 0
            timeoutSeconds: 0
          name: "jnlp"
          ttyEnabled: true
          command: ""
          args: ""

        instanceCap: 5
        name: "default-agent"
        namespace: "{{JENKINS_SHORT_NAME}}"
        nodeUsageMode: NORMAL
        workspaceVolume:
          emptyDirWorkspaceVolume:
            memory: false

security:
  remotingCLI:
    enabled: false

unclassified:
  location:
    adminAddress: ci-admin@eclipse.org
    url: https://{{JENKINS_HOST}}{{JENKINS_PREFIX}}
  
  mailer:
    adminAddress: ci-admin@eclipse.org
    replyToAddress: ci-admin@eclipse.org
    smtpHost: mail.eclipse.org

  globalDefaultFlowDurabilityLevel:
    durabilityHint: PERFORMANCE_OPTIMIZED

  simple-theme-plugin:
    elements:
    - cssUrl:
        url: "{{JENKINS_PREFIX}}/userContent/theme/eclipse-theme.css"
    - cssUrl:
        url: "//fonts.googleapis.com/css?family=Libre+Franklin:400,700,300,600,100"

tool:
  jdk:
    installations:
    - home: "openjdk-latest"
      name: "/opt/tools/java/openjdk/latest"
    - home: "openjdk-jdk11-latest"
      name: "/opt/tools/java/openjdk/jdk-11/latest"
    - home: "openjdk-jdk10-latest"
      name: "/opt/tools/java/openjdk/jdk-10/latest"
    - home: "openjdk-jdk9-latest"
      name: "/opt/tools/java/openjdk/jdk-9/latest"
    - home: "adoptopenjdk-hotspot-latest"
      name: "/opt/tools/java/adoptopenjdk/hotspot-latest"
    - home: "adoptopenjdk-hotspot-jdk11-latest"
      name: "/opt/tools/java/adoptopenjdk/hotspot-jdk-11/latest"
    - home: "adoptopenjdk-hotspot-jdk10-latest"
      name: "/opt/tools/java/adoptopenjdk/hotspot-jdk-10/latest"
    - home: "adoptopenjdk-hotspot-jdk9-latest"
      name: "/opt/tools/java/adoptopenjdk/hotspot-jdk-9/latest"
    - home: "adoptopenjdk-hotspot-jdk8-latest"
      name: "/opt/tools/java/adoptopenjdk/hotspot-jdk-8/latest"
    - home: "adoptopenjdk-openj9-latest"
      name: "/opt/tools/java/adoptopenjdk/openj9-latest"
    - home: "adoptopenjdk-openj9-jdk11-latest"
      name: "/opt/tools/java/adoptopenjdk/openj9-jdk-11/latest"
    - home: "adoptopenjdk-openj9-jdk10-latest"
      name: "/opt/tools/java/adoptopenjdk/openj9-jdk-10/latest"
    - home: "adoptopenjdk-openj9-jdk9-latest"
      name: "/opt/tools/java/adoptopenjdk/openj9-jdk-9/latest"
    - home: "adoptopenjdk-openj9-jdk8-latest"
      name: "/opt/tools/java/adoptopenjdk/openj9-jdk-8/latest"
    - home: "oracle-latest"
      name: "/opt/tools/java/oracle/latest"
    - home: "oracle-jdk10-latest"
      name: "/opt/tools/java/oracle/jdk-10/latest"
    - home: "oracle-jdk9-latest"
      name: "/opt/tools/java/oracle/jdk-9/latest"
    - home: "oracle-jdk8-latest"
      name: "/opt/tools/java/oracle/jdk-8/latest"
    - home: "oracle-jdk7-latest"
      name: "/opt/tools/java/oracle/jdk-7/latest"
    - home: "oracle-jdk6-latest"
      name: "/opt/tools/java/oracle/jdk-6/latest"
    - home: "oracle-jdk5-latest"
      name: "/opt/tools/java/oracle/jdk-5/latest"
  ant:
    installations:
    - home: "/opt/tools/apache-ant/latest"
      name: "apache-ant-latest"
  maven:
    installations:
    - home: "/opt/tools/apache-maven/latest"
      name: "apache-maven-latest"
    - home: "/opt/tools/apache-maven/3.5.4"
      name: "apache-maven-3.5.4"
    - home: "/opt/tools/apache-maven/3.3.9"
      name: "apache-maven-3.3.9"
    - home: "/opt/tools/apache-maven/3.2.5"
      name: "apache-maven-3.2.5"
  git:
    installations:
    - home: "/usr/local/bin/git"
      name: "git"

credentials:
  system:
    domainCredentials:
      - domain :
          name: "oss.sonatype.org"
          description: "oss.sonatype.org domain"
          specifications:
            - hostnameSpecification:
                includes: "oss.sonatype.org"
        credentials:
          - usernamePassword:
              scope:    SYSTEM
              id:       ossrh
              username: ${oss_sonatype_org_username}
              password: ${oss_sonatype_org_password}