local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.datatools", "Eclipse Data Tools Platform") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
        "description-setter",
      ],
    },
  },
}
