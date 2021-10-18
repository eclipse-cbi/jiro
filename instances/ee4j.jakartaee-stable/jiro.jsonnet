local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jakartaee-stable", "Jakarta Stable APIs") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
        "envinject",
      ],
    },
  }
}
