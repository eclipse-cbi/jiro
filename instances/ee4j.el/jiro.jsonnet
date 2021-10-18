local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.el", "Jakarta Expression Language") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}