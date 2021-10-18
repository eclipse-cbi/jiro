local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.acceleo", "Eclipse Acceleo") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "jacoco",
        "warnings-ng",
      ],
    },
  }
}
