local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.apogy", "Eclipse Apogy") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
      ],
    },
  },
}
