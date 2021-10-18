local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jsonp", "Jakarta JSON Processing") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
