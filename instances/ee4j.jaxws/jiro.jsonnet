local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jaxws", "Jakarta XML Web Services") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
        "envinject",
      ],
    },
  }
}
