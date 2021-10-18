local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.cu", "Jakarta Concurrency") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}
