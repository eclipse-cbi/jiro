local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mmt.qvt-oml", "Eclipse QVT Operational") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light",
      plugins+: [
        "buckminster",
      ],
    },
  }
}
