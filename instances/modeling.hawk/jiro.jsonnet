local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.hawk", "Eclipse Hawk") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "slack",
      ],
    },
  }
}
