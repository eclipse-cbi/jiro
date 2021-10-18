local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.websocket", "Jakarta Websocket") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
