local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.cdt", "Eclipse CDT") {
  "config.json"+: {
    project+: {
      resourcePacks: 4,
    },
    jenkins+: {
      plugins+: [
        "nodejs",
        "throttle-concurrents",
        "javadoc",
      ],
    },
  },
}
