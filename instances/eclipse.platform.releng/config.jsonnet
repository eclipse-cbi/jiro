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
      "github-checks",
      "git-forensics",
      "job-dsl",
      "pipeline-graph-view",
      "pipeline-utility-steps",
    ],
    staticAgentCount: 10,
    permissions+:
      permissionsTemplates.user("sravankumarl@in.ibm.com", ["Agent/Connect", "Agent/Disconnect"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=562806#c15
      permissionsTemplates.user("akurtakov@gmail.com", ["Agent/Connect", "Agent/Disconnect"])
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
  },
  storage: {
    quota:"150Gi"
  },
  seLinuxLevel: "s0:c52,c29",
}
