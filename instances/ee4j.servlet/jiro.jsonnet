local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.servlet", "Jakarta Servlet") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
      ],
    },
  }
}
