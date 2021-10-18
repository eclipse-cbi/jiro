local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("automotive.mosaic", "Eclipse Mosaic") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
      ],
    },
  },
}
