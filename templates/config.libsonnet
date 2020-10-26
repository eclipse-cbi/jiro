local jiroMasters = import '../../jiro-masters/masters.jsonnet';
local permissions = import 'permissions.libsonnet';
local clouds = import "clouds.libsonnet";
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
  clouds: clouds.kubernetes("kubernetes", self, (import '../../jiro-agents/agents.jsonnet')),
  deployment: {
    host: "ci.eclipse.org",
    prefix: "/" + $.project.shortName,
    url: "https://" + $.deployment.host + $.deployment.prefix,
    uiPort: 8080,
    jnlpPort: 50000,
    controlPort: 8081,
    cluster: "ci-c1",
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
      namespace: $.kubernetes.master.namespace,  # should be changed to something agent-specific to fix #5
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
    # .mavenrc: will add --batch-mode
    interactiveMode: false,
    # .mavenrc: will add -V
    showVersion: !std.startsWith($.project.fullName, "ee4j"),
    # .mavenrc: will set -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener to given level
    transferListenerLogLevel: "warn",
    # will append everything from there to .mavenrc file
    mavenrc: "",

    files: {
      "settings.xml": {
        color: "always",
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
    },
    dockerconfigjson: {
      "dockerconfigjson-for-pull-as-default": {
        serviceAccount: "default",
        # The namespace inside which this secret should be created
        namespace: $.kubernetes.agents.namespace,
        # type of secret to link: mount or pull (or both). See oc secrets link  --help
        type: ["pull",], 
        servers: {
          "https://index.docker.io/v1/": {
            username: {
              pass: "docker.com/default-image-puller/%s/username" % $.deployment.cluster
            },
            password: {
              pass: "docker.com/default-image-puller/%s/password" % $.deployment.cluster
            },
          },
          # Add more here if required, e.g. quay.io, etc...
        },
      },
      ["dockerconfigjson-for-pull-as-%s" % $.project.shortName]: self["dockerconfigjson-for-pull-as-default"] {
        serviceAccount: $.project.shortName,
        namespace: $.kubernetes.master.namespace,
      },
    },
  }
}