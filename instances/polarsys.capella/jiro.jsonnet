local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("polarsys.capella", "Eclipse Capella") {
  "config.json"+: {
    project+: {
      resourcePacks: 2
    },
    jenkins+: {
      plugins+: [
        "description-setter",
        "jacoco",
        "performance",
        "pipeline-github",
        "pipeline-utility-steps",
      ],
    },
  },
}
