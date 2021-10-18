local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jakartaee-platform", "Jakarta EE Platform") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light"
    },
    maven+: {
      showVersion: false,
    },
  }
}
