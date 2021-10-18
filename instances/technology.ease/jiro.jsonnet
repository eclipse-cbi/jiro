local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.ease", "Eclipse Advanced Scripting Environment (EASE)") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "blueocean",
        "code-coverage-api",
        "copyartifact",
        "embeddable-build-status",
      ],
    },
  },
}
