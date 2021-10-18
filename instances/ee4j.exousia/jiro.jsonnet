local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.exousia", "Eclipse Exousia") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    },
  },
}