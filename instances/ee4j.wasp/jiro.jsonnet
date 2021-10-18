local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.wasp", "Eclipse WaSP") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    }
  }
}
