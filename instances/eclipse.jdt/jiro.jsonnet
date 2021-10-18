local jiro = import '../../templates/jiro.libsonnet';

local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("eclipse.jdt", "Eclipse Java Development Tools (JDT)") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      plugins+: [
        "gerrit-code-review",
      ],
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
