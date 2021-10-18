local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.epsilon", "Eclipse Epsilon") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "slack",
        "embeddable-build-status",
      ],
    },
  }
}
