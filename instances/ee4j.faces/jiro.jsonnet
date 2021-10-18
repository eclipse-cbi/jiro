local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.faces", "Jakarta Server Faces") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    },
  },
}