local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.yasson", "Eclipse Yasson") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
