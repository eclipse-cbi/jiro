local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "eclipse.platform.releng",
    displayName: "Eclipse Platform Releng",
    resourcePacks: 5,
    unixGroupName: "eclipse.platform",
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "gerrit-code-review",
      "job-dsl",
    ],
    staticAgentCount: 10,
    permissions+:
      permissionsTemplates.projectPermissions("sravankumarl@in.ibm.com", ["Agent/Connect", "Agent/Disconnect"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=562806#c15
      permissionsTemplates.projectPermissions("akurtakov@gmail.com", ["Agent/Connect", "Agent/Disconnect"])
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "jipp-centos-7-agent-6gb": currentCloud.templates["centos-7"] {
          labels: ["centos-7-6gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
        },
        "jipp-centos-8-agent-4cpu": currentCloud.templates["centos-8"] {
          labels: ["centos-8-4cpu"],
          kubernetes+: {
            resources+: {
              cpu: {
                limit: "4000m",
                request: "4000m",
              },
            },
          },
        },
      },
    },
  },
  maven+: {
    local superSettings = super.files["settings.xml"],
    files+: {
      "settings-deploy-ossrh-jdt.xml": {
        servers: {
          "repo.eclipse.org": superSettings.servers["repo.eclipse.org"],
          ossrh: {
            nexusProUrl: superSettings.servers.ossrh.nexusProUrl,
            username: {
              pass: "bots/eclipse.jdt/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/eclipse.jdt/oss.sonatype.org/password",
            }
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/eclipse.jdt/gpg/passphrase"
            }
          }
        },
        mirrors: superSettings.mirrors,
      },
      "settings-deploy-ossrh-pde.xml": {
        servers: {
          "repo.eclipse.org": superSettings.servers["repo.eclipse.org"],
          ossrh: {
            nexusProUrl: superSettings.servers.ossrh.nexusProUrl,
            username: {
              pass: "bots/eclipse.pde/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/eclipse.pde/oss.sonatype.org/password",
            }
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/eclipse.pde/gpg/passphrase"
            }
          }
        },
        mirrors: superSettings.mirrors,
      },
      "settings-deploy-ossrh-releng.xml": {
        servers: {
          "repo.eclipse.org": superSettings.servers["repo.eclipse.org"],
          ossrh: {
            nexusProUrl: superSettings.servers.ossrh.nexusProUrl,
            username: {
              pass: "bots/eclipse.platform.releng/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/eclipse.platform.releng/oss.sonatype.org/password",
            }
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/eclipse.platform.releng/gpg/passphrase"
            }
          }
        },
        mirrors: superSettings.mirrors,
      },
    },
  }
}