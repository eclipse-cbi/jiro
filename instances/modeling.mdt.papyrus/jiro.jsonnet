local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mdt.papyrus", "Eclipse Papyrus") {
  "config.json"+: {
    project+: {
      resourcePacks: 3, //https://bugs.eclipse.org/bugs/show_bug.cgi?id=570916
    },
    jenkins+: {
      plugins+: [
        "dashboard-view",
        "zentimestamp",
      ],
    },
    clouds+: {
      kubernetes+: {
        local currentCloud = self,
        templates+: {
          "centos-7-agent-6gb": currentCloud.templates["centos-7"] {
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
}
