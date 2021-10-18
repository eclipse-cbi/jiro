local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.lyo", "Eclipse Lyo") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
      ],
    },
    maven+: {
      showVersion: false,
    },
  },
}
