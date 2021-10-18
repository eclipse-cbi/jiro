local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.amalgam", "Eclipse Amalgamation") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "zentimestamp",
      ],
    },
  }
}
