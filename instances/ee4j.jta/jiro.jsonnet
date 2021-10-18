local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jta", "Jakarta Transactions") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
