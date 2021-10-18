local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jsonb", "Jakarta JSON Binding") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
