local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.parsson", "Eclipse Parsson") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
