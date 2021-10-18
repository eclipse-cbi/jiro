local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.ca", "Jakarta Annotations") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}
