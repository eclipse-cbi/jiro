local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.gef", "Eclipse GEF") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "build-name-setter",
        "copyartifact",
        "parameterized-scheduler",
        "slack",
      ],
    },
  },
}
