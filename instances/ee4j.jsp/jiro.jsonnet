local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jsp", "Jakarta Server Pages") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
