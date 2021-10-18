local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("automotive.simopenpass", "Eclipse sim@openPASS") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      plugins+: [
        "mail-watcher-plugin",
      ],
    },
  },
}
