local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.emf.mwe", "Eclipse Modeling Workflow Engine") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "slack",
        "parameterized-scheduler",
      ],
    },
  }
}
