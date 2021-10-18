local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("eclipse.platform", "Eclipse Platform") {
  "config.json"+: {
    project+: {
      resourcePacks: 3,
    },
    jenkins+: {
      plugins+: [
        "gerrit-code-review",
      ],
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
        },
      },
    },
  },
  "k8s/statefulset.json"+: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            container + {
              env: [
                # Required for gerrit-code-review https://github.com/jenkinsci/gerrit-code-review-plugin/releases/tag/gerrit-code-review-0.4.6,
                if (env.name == "JAVA_OPTS") then
                  env + {
                    value: env.value + " -Dhudson.remoting.ClassFilter=com.google.gerrit.extensions.common.AvatarInfo,com.google.gerrit.extensions.common.ReviewerUpdateInfo"
                  } else
                  env
                for env in super.env
              ]
            } for container in super.containers
          ],
        },
      },
    },
  },
}