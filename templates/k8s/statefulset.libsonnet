local Kube = import "kube.libsonnet";
{
  gen(config): Kube.StatefulSet(config.kubernetes.master.stsName, config) {
    local agents = import "../../../jiro-agents/remoting.libsonnet",
    local defaultJnlpAgent = agents.agents["basic-agent"].versions[config.jenkins.remotingVersion],
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          "org.eclipse.cbi.jiro/project.fullName": config.project.fullName,
        },
      },
      serviceName: config.project.shortName,
      template: {
        metadata: {
          labels: Kube.JiroLabels(config),
          name: config.project.shortName,
        },
        spec: {
          serviceAccountName: config.project.shortName,
          terminationGracePeriodSeconds: 1200,
          containers: [
            {
              name: "jenkins",
              image: "%s:%s" % [config.docker.master.image, config.docker.master.imageTag ],
              imagePullPolicy: "Always",
              livenessProbe: {
                httpGet: {
                  path: config.deployment.prefix + "/login",
                  port: config.deployment.uiPort,
                  scheme: "HTTP",
                },
                initialDelaySeconds: config.kubernetes.master.probe.liveness.delaySeconds,
                periodSeconds: config.kubernetes.master.probe.liveness.periodSeconds,
                failureThreshold: config.kubernetes.master.probe.liveness.failureThreshold,
                timeoutSeconds: config.kubernetes.master.probe.liveness.timeoutSeconds,
              },
              readinessProbe: {
                tcpSocket: {
                  port: config.deployment.uiPort,
                },
                initialDelaySeconds: config.kubernetes.master.probe.readiness.delaySeconds,
                periodSeconds: config.kubernetes.master.probe.readiness.periodSeconds,
                failureThreshold: config.kubernetes.master.probe.readiness.failureThreshold,
                timeoutSeconds: config.kubernetes.master.probe.readiness.timeoutSeconds,
              },
              ports: [
                {
                  containerPort: config.deployment.uiPort,
                  protocol: "TCP",
                },
                {
                  containerPort: config.deployment.jnlpPort,
                  protocol: "TCP",
                },
              ],
              resources: {
                requests: {
                  cpu: config.kubernetes.master.resources.cpu.request,
                },
                limits: {
                  cpu: config.kubernetes.master.resources.cpu.limit,
                  memory: config.kubernetes.master.resources.memory.limit,
                },
              },
              lifecycle: {
                preStop: {
                  exec: {
                    # be even smarter and implement this in a script with a wait for job to complete. Adjust terminationGracePeriodSeconds accordingly
                    command: ["/bin/sh","-c","java -cp " + config.docker.master.webroot + "/winstone.jar winstone.tools.WinstoneControl shutdown --host=localhost --port=" + config.deployment.controlPort + " >/dev/termination-log 2>&1"],
                  },
                },
              },
              volumeMounts: [
                {
                  mountPath: config.docker.master.home,
                  name: "jenkins-home",
                },
                {
                  mountPath: config.docker.master.webroot,
                  name: "jenkins-war",
                },
                {
                  mountPath: config.docker.master.pluginroot,
                  name: "jenkins-plugins",
                },
                {
                  mountPath: "/etc/jenkins/",
                  name: "jenkins-config",
                  readOnly: true,
                },
              ] + if std.objectHas(config.secrets, "gerrit-trigger-plugin") then [ 
                {
                  mountPath: "/run/secrets/jenkins/ssh",
                  name: "gerrit-ssh-keys",
                  readOnly: true,
                } 
              ] else [],
              env: [
                {
                  name: "JAVA_OPTS",
                    # -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle
                    # -Xshareclasses:verbose,name=jenkins,cacheDir=/var/cache/openj9/sharedclasses/jenkins,groupAccess,fatal
                    # Djdk.nativeCrypto=false is a workaround for
                    # https://github.com/eclipse/openj9/issues/3637
                  value: std.join(" ", [
                    "-XshowSettings:vm",
                    "-Duser.timezone=" + config.jenkins.timezone,
                    "-Djdk.nativeCrypto=false",
                    "-Dsun.zip.disableMemoryMapping=true",
                    "-Dhudson.lifecycle=hudson.lifecycle.ExitLifecycle",
                    "-Dhudson.slaves.NodeProvisioner.initialDelay=0",
                    "-Dhudson.slaves.NodeProvisioner.MARGIN=50",
                    "-Dhudson.slaves.NodeProvisioner.MARGIN0=0.85",
                    "-Dhudson.footerURL=https://" + config.deployment.host,
                    "-Dhudson.model.UsageStatistics.disabled=true",
                    "-Djenkins.model.Jenkins.slaveAgentPort=" + config.deployment.jnlpPort,
                    "-Djenkins.model.Jenkins.slaveAgentPortEnforce=true",
                    "-Djenkins.model.Jenkins.exitCodeOnRestart=0",
                    "-Djenkins.slaves.JnlpSlaveAgentProtocol3.enabled=false",
                    "-Djenkins.install.runSetupWizard=false",
                    "-Djenkins.ui.refresh=true",
                    "-Djenkins.security.ManagePermission=true",
                    "-DexecutableWar.jetty.disableCustomSessionIdCookieName=false",
                    "-DexecutableWar.jetty.sessionIdCookieName=JSESSIONID." + config.project.shortName,
                    "-Dcasc.jenkins.config=/etc/jenkins/jenkins.yaml",
                    "-Dio.jenkins.plugins.casc.ConfigurationAsCode.initialDelay=5000",
                    "-Dorg.csanchez.jenkins.plugins.kubernetes.pipeline.PodTemplateStepExecution.defaultImage=%s/%s:%s" % [defaultJnlpAgent.docker.repository, defaultJnlpAgent.docker.image.name, defaultJnlpAgent.docker.image.tag],
                    "-Dorg.csanchez.jenkins.plugins.kubernetes.PodTemplate.connectionTimeout=" + config.jenkins.agentConnectionTimeout,
                    "-Dkubernetes.websocket.ping.interval=30000",
                    ])
                },
                {
                  name: "JENKINS_OPTS",
                  value: std.join(" ", [
                    "--prefix=" + config.deployment.prefix,
                    "--webroot=" + config.docker.master.webroot,
                    "--pluginroot=" + config.docker.master.pluginroot,
                    "--controlPort=" + config.deployment.controlPort,
                  ]),
                },
              ],
            },
          ],
          volumes: [
            {
              name: "jenkins-war",
              emptyDir: {}
            },
            {
              name: "jenkins-plugins",
              emptyDir: {}
            },
            {
              name: "jenkins-config",
              configMap: {
                name: "jenkins-config",
              },
            },
          ] + if std.objectHas(config.secrets, "gerrit-trigger-plugin") then [ 
            {
              name: "gerrit-ssh-keys",
              secret: {
                secretName: "gerrit-ssh-keys",
              },
            } 
          ] else [],
        },
      },
      volumeClaimTemplates: [
        {
          metadata: {
            name: "jenkins-home",
          },
          spec: {
            accessModes: [ "ReadWriteOnce", ],
            resources: {
              requests: {
                storage: "50Gi",
              },
            },
          },
        },
      ],
    },
  },
}
