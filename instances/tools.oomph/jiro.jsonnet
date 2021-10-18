local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.oomph", "Eclipse Oomph") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "build-name-setter",
        "mail-watcher-plugin",
        "multiple-scms",
        "zentimestamp",
      ],
    },
    clouds+: {
      kubernetes+: {
        local currentCloud = self,
        templates+: {
          "jipp-basic-agent-8gb": currentCloud.templates["basic"] {
            labels: ["basic-8gb"],
            kubernetes+: {
              resources+: {
                cpu: {
                  limit: "2000m",
                  request: "2000m",
                },
                memory: {
                  limit: "8Gi",
                  request: "8Gi",
                },
              },
            },
          },
        },
      },
    },
  },
}
