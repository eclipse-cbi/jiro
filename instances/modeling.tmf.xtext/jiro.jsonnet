local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.tmf.xtext", "Eclipse Xtext") {
  "config.json"+: {
    project+: {
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
        "build-user-vars-plugin"
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
                pass: "bots/" + $["config.json"].project.fullName + "/oss.sonatype.org/username",
              },
              password: {
                pass: "bots/" + $["config.json"].project.fullName + "/oss.sonatype.org/password",
              },
            },
          },
        },
      }
    }
  }
}
