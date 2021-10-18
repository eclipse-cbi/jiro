local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.grizzly", "Eclipse Grizzly") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "envinject",
      ],
    },
  }
}
