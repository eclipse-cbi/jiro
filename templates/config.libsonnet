local jiroMasters = import '../../jiro-masters/masters.jsonnet';
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
    local clouds = import "clouds.libsonnet",
    # kubernetes: is the name of the cloud (default)
    # See https://github.com/eclipse-cbi/jiro/commit/fab6ff19e44936f5f794c47a69b6bd8dde09e6e8
    kubernetes: clouds.kubernetes($, (import '../../jiro-agents/agents.jsonnet')),
    // Additional clouds could be set, e.g. (if clouds.azure would be implemented)
    // "azure-kx3cr": clouds.azure($, (import '../../jiro-agents/agents.jsonnet')),
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
  maven: (import "maven.libsonnet").Maven {
    projectFullName: $.project.fullName
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