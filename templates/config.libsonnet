local jenkinsReleases = import '../jenkins-master-base/releases.libsonnet';
local jiroAgents = import '../../jiro-agents/remoting.libsonnet';
local permissions = import 'permissions.libsonnet';
{
  local jenkinsRelease = jenkinsReleases.releases[$.jenkins.version],
  
  project: {
    shortName: std.split(self.fullName, ".")[std.length(std.split(self.fullName, "."))-1],
    fullName: error 'Must set "project.fullName"',
    displayName: error 'Must set "project.displayName"',
    unixGroupName: $.project.fullName,
    resourcePacks: 1,
  },
  jenkins: {
    version: "latest",
    actualVersion: jenkinsRelease.jenkins.version,
    remotingVersion: jenkinsRelease.jenkins.remoting.version,
    maxConcurrency: 2 * $.project.resourcePacks,
    staticAgentCount: 0,
    agentConnectionTimeout: 180,
    timezone: "America/Toronto",
    theme: "quicksilver",
    permissions: permissions.projectPermissions($.project.unixGroupName, 
      permissions.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",]),
  },
  docker: std.mergePatch(jenkinsRelease.docker, {
    master: {
      parentImage: $.docker.repository + "/jenkins-master-base:" + jenkinsRelease.jenkins.version,
      image: $.docker.repository + "/" + $.project.shortName,
      imageTag: jenkinsRelease.jenkins.version,
    },
  }),
  clouds: [
    {
      name: "kubernetes",
      namespace: $.kubernetes.master.namespace, # should be changed to something agent-specific to fix #5
      podRetention: "never",
      templates: [
        {
          name: agent.name, 
          mode: if std.objectHas(agent, "mode") then std.asciiUpper(agent.mode) else std.asciiUpper("exclusive"),
          labels: if std.objectHas(agent, "labels") then agent.labels else [],
          local versionSpecificAgent=jiroAgents.agents[agent.name].versions[jenkinsRelease.jenkins.remoting.version],
          maven: {
            home: versionSpecificAgent.home + "/.m2",
          },
          local currentAgent=self,
          kubernetes: {
            resources: $.kubernetes.agents.defaultResources,
            volumes: [
              {
                name: "m2-secret-dir",
                secret: { name: "m2-secret-dir", },
                mounts: [
                  {
                    mountPath: currentAgent.maven.home + "/" + self.subPath,
                    subPath: "settings-security.xml"
                  },
                ] + [
                  {
                    mountPath: currentAgent.maven.home + "/" + self.subPath,
                    subPath: settingsFile,
                  } for settingsFile in std.objectFields($.maven.files)
                ],
              },
              {
                name: "m2-dir",
                configMap: { name: "m2-dir", },
                mounts: [
                  {
                    mountPath: currentAgent.maven.home + "/" + self.subPath,
                    subPath: "toolchains.xml"
                  },
                ],
              },
            ],
          },
        } + jiroAgents.agents[agent.name].versions[jenkinsRelease.jenkins.remoting.version] for agent in jiroAgents.providedAgents
      ],
    },
  ],
  deployment: {
    host: "ci.eclipse.org",
    prefix: "/" + $.project.shortName,
    url: "https://" + $.deployment.host + $.deployment.prefix,
    uiPort: 8080,
    jnlpPort: 50000,
    controlPort: 8081,
  },
  kubernetes: {
    master: {
      namespace: $.project.shortName,
      stsName: $.project.shortName,
      resources: { 
        local Const = import "k8s/resource-packs.libsonnet",
        cpu: {
          request: "%dm" % std.min(Const.master_max_cpu_req, Const.master_base_cpu_req + std.max(0, $.jenkins.maxConcurrency - Const.master_min_agent_for_additional_resources + $.jenkins.staticAgentCount) * Const.master_cpu_per_agent),
          limit: "%dm" % std.max(Const.master_min_cpu_limit, Const.master_cpu_burst * std.parseInt(std.strReplace(self.request, 'm', ''))),
        },
        memory: {
          limit: "%dMi" % std.min(Const.master_max_mem, Const.master_base_mem + Const.master_mem_per_agent * ($.jenkins.maxConcurrency + $.jenkins.staticAgentCount)),
          request: self.limit,
        },
      },
      probe: {
        liveness: {
          delaySeconds: 480,
          periodSeconds: 30,
          timeoutSeconds: 30,
          failureThreshold: 5
        },
        readiness: {
          delaySeconds: 1,
          periodSeconds: 5,
          timeoutSeconds: 10,
          failureThreshold: 5
        }
      }
    },
    agents: {
      namespace: $.project.shortName,
      defaultResources: {
        local Const = import "k8s/resource-packs.libsonnet",
        local Kube = import "k8s/kube.libsonnet",
        cpu: {
          request: "%dm" % std.min(Const.agent_max_cpu_per_pod_or_container, Const.pack_cpu * $.project.resourcePacks / $.jenkins.maxConcurrency),
          limit: "%dm" % std.min(Const.agent_max_cpu_per_pod_or_container, std.max(Const.pack_cpu * $.project.resourcePacks / $.jenkins.maxConcurrency + (Const.jnlp_cpu * Const.jnlp_cpu_burst), Const.agent_min_cpu_limit)),
        },
        memory: {
          limit: "%dMi" % std.min(Const.agent_max_mem_per_pod_or_container, Const.pack_mem * $.project.resourcePacks / $.jenkins.maxConcurrency),
          request: self.limit,
        },
      },
    },
  },
  maven: {
    generate: true,
    files: {
      "settings.xml": {
        servers: {
          "repo.eclipse.org": {
            username: {
              pass: "nexus/username",
            },
            password: {
              pass: "nexus/password",
            },
          },
          ossrh: {
            nexusProUrl: if std.startsWith($.project.fullName, "ee4j") then "https://jakarta.oss.sonatype.org" else "https://oss.sonatype.org",
            username: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/password",
            },
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/" + $.project.fullName + "/gpg/passphrase"
            },
          },
        },
        mirrors: {
          "eclipse.maven.central.mirror": {
            name: "Eclipse Central Proxy",
            url: "https://repo.eclipse.org/content/repositories/maven_central/",
            mirrorOf: "central",
          },
        },
      },
      "settings-security.xml": {
        master: {
          pass: "bots/" + $.project.fullName + "/apache-maven-security-settings"
        },
      },
    },
  },
  secrets: {
    "gerrit-trigger-plugin": {
      username: "genie." + $.project.shortName,
      identityFile: "/run/secrets/jenkins/ssh/id_rsa",
    }
  }
}