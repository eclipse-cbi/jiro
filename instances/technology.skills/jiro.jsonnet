local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.skills", "Eclipse Skills") {
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
