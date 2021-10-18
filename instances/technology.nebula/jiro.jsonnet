local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.nebula", "Eclipse Nebula") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "embeddable-build-status",
      ],
    },
  },
}
