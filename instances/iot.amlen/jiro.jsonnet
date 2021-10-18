local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.amlen", "Eclipse Amlen") {
  "config.json"+: {
    deployment+: {
      cluster: "okd-c1"
    },
  }
}
