local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.paho", "Eclipse Paho") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "gradle",
      ],
    },
  }
}
