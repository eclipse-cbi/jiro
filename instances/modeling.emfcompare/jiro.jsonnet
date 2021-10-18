local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emfcompare", "Eclipse EMF Compare") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
      ],
    },
  }
}
