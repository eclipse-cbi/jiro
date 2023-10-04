local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "modeling.tmf.xtext",
    displayName: "Eclipse Xtext",
    resourcePacks: 2,
  },
  jenkins+: {
    staticAgentCount: 2,
    plugins+: [
      "copyartifact",
      "downstream-buildview",
      "envinject",
      "gradle",
      "groovy",
      "htmlpublisher",
      "parameterized-scheduler",
      "show-build-parameters",
      "slack",
      "build-user-vars-plugin",
      "matrix-communication"
    ],
  },
  gradle+: {
    generate: true,
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "centos-7-6gb": currentCloud.templates["centos-7"] {
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
        "centos-8-6gb": currentCloud.templates["centos-8"] {
          labels: ["centos-8-6gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
          env+: {
            JENKINS_REMOTING_JAVA_OPTS: [
              "-showversion",
              "-XshowSettings:vm",
              "-Xmx512m",
              "-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true",
              "-Dorg.jenkinsci.plugins.gitclient.CliGitAPIImpl.useSETSID=true"
            ],
          },
        },
      },
    },
  },
  maven+: {
    files+: {
      "settings.xml"+: {
        "servers"+: {
          "ossrh-s01": {
            nexusProUrl: "https://s01.oss.sonatype.org",
            username: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/password",
            },
          },
        },
      },
    }
  }
}
