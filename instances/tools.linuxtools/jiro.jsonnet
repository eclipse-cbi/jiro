local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.linuxtools", "Eclipse Linux Tools") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
        "build-with-parameters"
      ],
    },
  },
}
