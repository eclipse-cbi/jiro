local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("automotive.kuksa", "Eclipse Kuksa") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "cobertura",
        "embeddable-build-status",
        "xunit",
      ],
    },
  },
}
