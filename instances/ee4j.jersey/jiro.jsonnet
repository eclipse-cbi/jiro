local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jersey", "Eclipse Jersey") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
