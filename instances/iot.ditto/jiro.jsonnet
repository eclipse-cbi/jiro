local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.ditto", "Eclipse Ditto") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "nodejs",
        "pipeline-utility-steps",
      ],
    },
  }
}