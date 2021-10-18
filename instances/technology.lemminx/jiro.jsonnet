local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.lemminx", "Eclipse LemMinX") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "blueocean",
        "embeddable-build-status",
      ],
    },
  },
}
