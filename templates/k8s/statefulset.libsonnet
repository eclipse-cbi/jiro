local Kube = import "kube.libsonnet";
{
  gen(config): Kube.StatefulSet(config.kubernetes.master.stsName, config) {
    local agents = import "../../../jiro-agents/agents.jsonnet",
    local defaultJnlpAgent = agents[config.kubernetes.master.defaultJnlpAgentLabel].variants[config.jiroMaster.remoting.version],
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
          affinity: {
            nodeAffinity: {
              preferredDuringSchedulingIgnoredDuringExecution: [
                {
                  weight: 1,
                  preference: {
                    matchExpressions: [
                      {
                        key: "speed",
                        operator: "NotIn",
                        values: ["fast"]
                      }
                    ]
                  }
                }
              ]
            }
          },
          terminationGracePeriodSeconds: 1200,
          containers: [
            {
              name: "jenkins",
              image: "%s/%s/%s:%s" % [config.docker.master.registry, config.docker.master.repository, config.docker.master.image, config.docker.master.tag ],
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
                    command: ["/bin/sh","-c","java -cp " + config.jiroMaster.webroot + "/executable/winstone.jar winstone.tools.WinstoneControl shutdown --host=localhost --port=" + config.deployment.controlPort + " >/dev/termination-log 2>&1"],
                  },
                },
              },
              volumeMounts: [
                {
                  mountPath: config.jiroMaster.home,
                  name: "jenkins-home",
                },
                {
                  mountPath: config.jiroMaster.webroot,
                  name: "jenkins-war",
                },
                {
                  mountPath: config.jiroMaster.pluginroot,
                  name: "jenkins-plugins",
                },
                {
                  mountPath: "/etc/jenkins/",
                  name: "jenkins-config",
                  readOnly: true,
                },
              ] + (if std.objectHas(config.secrets, "gerrit-trigger-plugin") then [
                {
                  mountPath: "/run/secrets/jenkins/ssh",
                  name: "gerrit-ssh-keys",
                  readOnly: true,
                }
             ] else [])
                + (if std.objectHas(config, "gerrit") then [
                {
                  mountPath: "/run/secrets/jenkins/ssh-" + gerrit.site,
                  name: std.strReplace(gerrit.site, '.', '-') + "-ssh-keys",
                  readOnly: true,
                }
                for gerrit in config.gerrit
              ] else []),
              securityContext: if std.objectHas(config, "seLinuxLevel") then
                {
                  "seLinuxOptions": {
                    "level": config.seLinuxLevel,
                    "type": "spc_t",
                  },
                } else if config.kubernetes.master.autoSeLixux then {
                   "seLinuxOptions": {
                    "level": config.kubernetes.master.seLinuxLevel,
                    "type": "spc_t",
                  },
                } else {},
              env: [
                {
                  name: "JAVA_OPTS",
                    # -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle
                    # -Xshareclasses:verbose,name=jenkins,cacheDir=/var/cache/openj9/sharedclasses/jenkins,groupAccess,fatal
                  value: std.join(" ", [
                    "-showversion",
                    "-XshowSettings:vm",
                    "-XX:+AlwaysPreTouch",
                    "-XX:+ParallelRefProcEnabled",
                    "-XX:+DisableExplicitGC",

                    "-Duser.timezone=" + config.jenkins.timezone,

                    # not needed anymore since https://issues.jenkins-ci.org/browse/JENKINS-56307
                    // "-Dhudson.slaves.NodeProvisioner.initialDelay=0",
                    // "-Dhudson.slaves.NodeProvisioner.MARGIN=50",
                    // "-Dhudson.slaves.NodeProvisioner.MARGIN0=0.85",

                    "-Dhudson.footerURL=https://" + config.deployment.host,
                    "-Dhudson.model.UsageStatistics.disabled=true",
                    "-Dhudson.lifecycle=hudson.lifecycle.ExitLifecycle",
                    "-Djenkins.model.Jenkins.exitCodeOnRestart=0",
                    "-Djenkins.model.Jenkins.slaveAgentPort=" + config.deployment.jnlpPort,
                    "-Djenkins.model.Jenkins.slaveAgentPortEnforce=true",
                    "-Djenkins.slaves.JnlpSlaveAgentProtocol3.enabled=false",
                    "-Djenkins.install.runSetupWizard=false",

                    # since https://www.jenkins.io/changelog-stable/#v2.222.1
                    "-Djenkins.ui.refresh=true",
                    "-Djenkins.security.ManagePermission=true",

                    # See https://issues.jenkins.io/browse/JENKINS-50379
                    "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=7200",

                    # See https://github.com/jenkinsci/extras-executable-war/blob/master/README.md
                    "-DexecutableWar.jetty.disableCustomSessionIdCookieName=false",
                    "-DexecutableWar.jetty.sessionIdCookieName=JSESSIONID." + config.project.shortName,

                    "-Dcasc.jenkins.config=/etc/jenkins/jenkins.yaml",

                    # Useless for Jenkins >= 2.199 and JCasC >= 1.36
                    # See https://github.com/jenkinsci/configuration-as-code-plugin#compatibility-with-jenkins--2199-for-jcasc--136
                    "-Dio.jenkins.plugins.casc.ConfigurationAsCode.initialDelay=5000",

                    # https://support.cloudbees.com/hc/en-us/articles/360030405571-Change-the-default-JNLP-image-for-kubernetes-agents-provisioning
                    "-Dorg.csanchez.jenkins.plugins.kubernetes.pipeline.PodTemplateStepExecution.defaultImage=%s/%s/%s:%s" % [defaultJnlpAgent.docker.registry, defaultJnlpAgent.docker.repository, defaultJnlpAgent.docker.image, defaultJnlpAgent.docker.tag],

                    # https://github.com/jenkinsci/kubernetes-plugin/blob/master/README.md#specifying-a-different-default-agent-connection-timeout
                    "-Dorg.csanchez.jenkins.plugins.kubernetes.PodTemplate.connectionTimeout=" + config.jenkins.agentConnectionTimeout,

                    # https://github.com/fabric8io/kubernetes-client/blob/master/README.md
                    "-Dkubernetes.websocket.ping.interval=30000",
                    ])
                },
                {
                  name: "JENKINS_OPTS",
                  value: std.join(" ", [
                    "--prefix=" + config.deployment.prefix,
                    "--webroot=" + config.jiroMaster.webroot,
                    "--pluginroot=" + config.jiroMaster.pluginroot,
                    "--controlPort=" + config.deployment.controlPort,
                  ]),
                }
              ] + if config.jenkins.pluginsForceUpgrade then [
                {
                  # see https://github.com/jenkinsci/docker/pull/577
                  name: "PLUGINS_FORCE_UPGRADE",
                  value: "%s" % config.jenkins.pluginsForceUpgrade,
                },
                {
                  # see https://github.com/jenkinsci/docker/pull/577
                  name: "TRY_UPGRADE_IF_NO_MARKER",
                  value: "%s" % config.jenkins.pluginsForceUpgrade,
                }
              ] else [],
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
          ] + (if std.objectHas(config.secrets, "gerrit-trigger-plugin") then [
            {
              name: "gerrit-ssh-keys",
              secret: {
                secretName: "gerrit-ssh-keys",
              },
            }
          ] else [])
            + (if std.objectHas(config, "gerrit") then [
            {
              name: std.strReplace(gerrit.site, '.', '-') + "-ssh-keys",
              secret: {
                secretName: gerrit.site + "-ssh-keys",
              },
            }
            for gerrit in config.gerrit
          ] else []),
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
                storage: if std.objectHas(config, "storage") && std.objectHas(config.storage, "quota") then
                  config.storage.quota
                else
                  "50Gi",  //default value
              },
            },
          },
        },
      ],
    },
  },
}
