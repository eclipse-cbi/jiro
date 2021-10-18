local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emf", "Eclipse Modeling Framework") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "mail-watcher-plugin",
        "multiple-scms",
        "zentimestamp",
      ],
    },
  }
}
