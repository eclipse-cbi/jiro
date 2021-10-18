local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.ecp", "Eclipse EMF Client Platform") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
      ],
    },
  }
}
