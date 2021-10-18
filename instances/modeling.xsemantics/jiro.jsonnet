local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.xsemantics", "Eclipse Xsemantics") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "mail-watcher-plugin",
      ],
    },
  }
}
