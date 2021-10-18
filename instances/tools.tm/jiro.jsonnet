local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.tm", "Eclipse Target Management") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
        "description-setter",
        "warnings-ng",
      ]
    }
  },
}
