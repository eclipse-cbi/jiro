local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emf.egf", "Eclipse Generation Factories") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
      ],
    },
  }
}
