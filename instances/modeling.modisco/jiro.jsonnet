local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.modisco", "Eclipse MoDisco") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light",
      plugins+: [
        "buckminster",
      ],
    },
  }
}
