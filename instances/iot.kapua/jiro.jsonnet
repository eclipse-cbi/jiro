local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.kapua", "Eclipse Kapua") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
        "htmlpublisher",
        "nodejs"
      ]
    }
  }
}