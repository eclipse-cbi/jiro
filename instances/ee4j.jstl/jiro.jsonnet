local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jstl", "Jakarta Standard Tag Library") {
  "config.json"+: {
    maven+: {
      showVersion: false,
    }
  }
}
