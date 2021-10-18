local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emf-parsley", "Eclipse EMF Parsley") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
        "mail-watcher-plugin",
        "warnings-ng",
      ],
    },
  }
}
