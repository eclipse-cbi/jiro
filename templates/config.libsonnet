local jiroMasters = import '../../jiro-masters/masters.jsonnet';
local jiroAgents = import '../../jiro-agents/agents.jsonnet';
local permissions = import 'permissions.libsonnet';
{ 
  project: {
    shortName: std.split(self.fullName, ".")[std.length(std.split(self.fullName, "."))-1],
    fullName: error 'Must set "project.fullName"',
    displayName: error 'Must set "project.displayName"',
    unixGroupName: $.project.fullName,
    resourcePacks: 1,
  },
  jenkins: {
    version: "latest",
    maxConcurrency: 2 * $.project.resourcePacks,
    staticAgentCount: 0,
    agentConnectionTimeout: 180,
    timezone: "America/Toronto",
    theme: "quicksilver",
    # see https://github.com/jenkinsci/docker/pull/577
    pluginsForceUpgrade: true,
    permissions: permissions.projectPermissions($.project.unixGroupName, 
      permissions.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",]),
  },
  jiroMaster: if ($.jenkins.version == "latest") then jiroMasters.masters[jiroMasters.latest] else jiroMasters.masters[$.jenkins.version],
  docker: {
    master: {
      registry: $.jiroMaster.docker.registry,
      repository: "eclipsecbijenkins",
      image: $.project.fullName,
      tag: $.jiroMaster.version,
    },
  },
  clouds: {
    "c1-ci": {
      kind: "kubernetes",
      namespace: $.kubernetes.master.namespace, # should be changed to something agent-specific to fix #5
      podRetention: "never",
      templates: {
        [agentName]: {
          local jiroAgent = jiroAgents[agentName],
          mode: if std.objectHas(jiroAgent, "mode") then std.asciiUpper(jiroAgent.mode) else std.asciiUpper("exclusive"),
          labels: if std.objectHas(jiroAgent, "labels") then jiroAgent.labels else [],
          envVars: {
            MAVEN_OPTS: [ "-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn" ],
            MAVEN_CONFIG: ["-B", "-e"],
          } + { [envKey]: jiroAgent.env[envKey] for envKey in std.objectFields(jiroAgent.env) },
          kubernetes: {
            resources: $.kubernetes.agents.defaultResources,
            local dot_m2 = jiroAgent.home + "/.m2",
            volumes: (if $.maven.generate then [
              {
                name: "m2-secret-dir",
                secret: { name: "m2-secret-dir", },
                mounts: [
                  {
                    mountPath: dot_m2 + "/" + self.subPath,
                    subPath: settingsFile,
                  } for settingsFile in std.objectFields($.maven.files)
                ],
              },
              {
                name: "m2-dir",
                configMap: { name: "m2-dir", },
                mounts: [
                  {
                    mountPath: dot_m2 + "/" + self.subPath,
                    subPath: "toolchains.xml"
                  },
                ],
              },
            ] else []) + (if $.gradle.generate then [
              {
                local dot_gradle = jiroAgent.home + "/.gradle",
                name: "gradle-secret-dir",
                configMap: { name: "gradle-secret-dir", },
                mounts: [
                  {
                    mountPath: dot_gradle + "/" + self.subPath,
                    subPath: propertiesFile,
                  } for propertiesFile in std.objectFields($.gradle.files)
                ],
              },
            ] else []),
          },
        } + jiroAgents[agentName].variants[$.jiroMaster.remoting.version] for agentName in std.objectFields(jiroAgents) 
      },
    },
  },
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
  gradle: {
    generate: false,
    
    files: {
      "gradle.properties": {
        eclipseRepoUsername: {
          pass: "nexus/username",
        },
        eclipseRepoPassword: {
          pass: "nexus/password",
        },
      }
    }
  },
  secrets: {
    "gerrit-trigger-plugin": {
      username: "genie." + $.project.shortName,
      identityFile: "/run/secrets/jenkins/ssh/id_rsa",
    }
  }
}