local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jaxb-impl", "Eclipse Implementation of JAXB") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
        "copyartifact",
      ],
    },
  }
}
