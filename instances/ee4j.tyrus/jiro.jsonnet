local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.tyrus", "Eclipse Tyrus") {
  "config.json"+: {
    maven+: {
      showVersion: false,
    },
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
