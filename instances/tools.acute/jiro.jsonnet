local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.acute", "Eclipse aCute") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    },
  },
}
