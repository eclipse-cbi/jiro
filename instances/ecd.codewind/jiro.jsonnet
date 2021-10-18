local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ecd.codewind", "Eclipse Codewind") {
  "config.json"+: {
    project+: {
      resourcePacks: 3,
    },
    jenkins+: {
      staticAgentCount: 1,
      plugins+: [
        "basic-branch-build-strategies",
        "embeddable-build-status",
        "golang",
        "mail-watcher-plugin",
        "nodejs",
        "pipeline-github",
        "htmlpublisher",
      ],
    },
  },
}
