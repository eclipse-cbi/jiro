local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jpa", "Jakarta Persistence") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
