local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.sirius", "Eclipse Sirius") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      plugins+: [
        "zentimestamp",
      ],
    },
  }
}
