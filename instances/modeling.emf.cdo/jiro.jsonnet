local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emf.cdo", "Eclipse CDO Model Repository") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "build-name-setter",
        "mail-watcher-plugin",
        "zentimestamp",
      ],
    },
  }
}
