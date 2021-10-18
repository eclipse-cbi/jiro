local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.birt", "Eclipse Business Intelligence and Reporting Tools (BIRT)") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "extended-choice-parameter",
      ]
    }
  },
}
