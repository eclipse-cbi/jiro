local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jca", "Jakarta Connectors") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
