local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.justj", "Eclipse JustJ") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "build-with-parameters",
        "mail-watcher-plugin",
      ],
    },
  },
}
