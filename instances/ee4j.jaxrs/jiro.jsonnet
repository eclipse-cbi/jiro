local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jaxrs", "Jakarta RESTful Web Services") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
