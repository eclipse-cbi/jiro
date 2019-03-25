local jenkinsReleases = import '../jenkins-master-base/releases.libsonnet';
{
  local config = self,
  local jenkinsRelease = 
    if config.jenkins.version == 'latest' then 
      jenkinsReleases.latest 
    else
      std.filter(function(r) if r.jenkins.version == config.jenkins.version then true else false, jenkinsReleases.releases)[0]
    ,

  project: {
    shortName: error 'Must set "project.shortName"',
    fullName: error 'Must set "project.fullName"',
    displayName: error 'Must set "project.displayName"',
    sponsorshipLevel: "S0",
    resourcePacks: 1,
  },
  jenkins: {
    version: "latest",
    actualVersion: jenkinsRelease.jenkins.version,
    actualRemotingVersion: jenkinsRelease.jenkins.remoting.version,
    maxConcurrency: 2*config.project.resourcePacks,
    staticAgentCount: 0,
    agentConnectionTimeout: 180,
    timezone: "America/Toronto",
    theme: "quicksilver",
    permissions: [
      {
        principal: "anonymous",
        grantedPermissions: [
          "Overall/Read",
          "Job/Read"
        ]
      },
      {
        principal: "common",
        grantedPermissions: [
          "Job/ExtendedRead"
        ]
      },
      {
        principal: "admins",
        grantedPermissions: [
          "Overall/Administer"
        ]
      },
      {
        principal: config.project.fullName,
        grantedPermissions: [
          "Credentials/View",
          "Gerrit/ManualTrigger",
          "Gerrit/Retrigger",
          "Job/Build",
          "Job/Cancel",
          "Job/Configure",
          "Job/Create",
          "Job/Delete",
          "Job/Move",
          "Job/Read",
          "Job/Workspace",
          "Agent/Build",
          "Run/Delete",
          "Run/Replay",
          "Run/Update",
          "View/Configure",
          "View/Create",
          "View/Delete",
          "View/Read",
          "SCM/Tag"
        ]
      }
    ]
  },
  docker: std.mergePatch(jenkinsRelease.docker, {
    master: {
      parentImage: config.docker.repository + "/jenkins-master-base:" + jenkinsRelease.jenkins.version,
      image: config.docker.repository + "/" + config.project.shortName,
      imageTag: jenkinsRelease.jenkins.version,
    },
    agent: {
      defaultImage: {
        name: config.docker.repository + "/jenkins-agent",
        tag: jenkinsRelease.jenkins.remoting.version,
      }
    }
  }),
  deployment: {
    host: "ci.eclipse.org",
    prefix: "/" + config.project.shortName,
    url: "https://" + config.deployment.host + config.deployment.prefix,
    uiPort: 8080,
    jnlpPort: 50000
  },
  kubernetes: {
    master: {
      namespace: "" + config.project.shortName,
      stsName: "" + config.project.shortName,
      resources: 
      { 
        local base_cpu_req=500,
        local max_cpu_req=4000,
        local min_cpu_limit=2000,
        local cpu_per_agent=150,
        local min_agent_for_additional_cpu=2,
        local cpu_limit_req_factor=2,
        local base_mem=1024,
        local mem_per_agent=256,
        local max_mem=8*1024,
        cpu: {
          request: "%dm" % std.min(max_cpu_req, base_cpu_req+std.max(0, config.jenkins.maxConcurrency-min_agent_for_additional_cpu+config.jenkins.staticAgentCount)*cpu_per_agent),
          limit: "%dm" % std.max(min_cpu_limit, cpu_limit_req_factor*std.parseInt(std.strReplace(self.request, 'm', ''))),
        },
        memory: {
          limit: "%dMi" % std.min(max_mem, base_mem+mem_per_agent*(config.jenkins.maxConcurrency+config.jenkins.staticAgentCount)),
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
    }
  },
  maven: {
    home: "/home/jenkins/.m2",
    files: {
      "settings.xml": {
        "volumeType": "Secret",
        "volumeName": "m2-secret-dir"
      },
      "settings-security.xml": {
        "volumeType": "Secret",
        "volumeName": "m2-secret-dir"
      },
      "toolchains.xml": {
        volumeType: "ConfigMap",
        volumeName: "m2-dir"
      }
    }
  },
  "secrets": {
    "gerrit-trigger-plugin": {
      "username": "genie." + config.project.shortName,
      "identityFile": "/run/secrets/jenkins/ssh/id_rsa"
    }
  }
}