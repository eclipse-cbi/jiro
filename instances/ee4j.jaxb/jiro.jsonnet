local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jaxb", "Jakarta XML Binding") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    }
  }
}
