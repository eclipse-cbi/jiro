local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ecd.theia", "Eclipse Theia") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "embeddable-build-status",
        "mail-watcher-plugin",
        "pipeline-utility-steps",
      ],
    },
  },
}