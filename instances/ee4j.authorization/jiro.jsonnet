local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.authorization", "Jakarta Authorization") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}
