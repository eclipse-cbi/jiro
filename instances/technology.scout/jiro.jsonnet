local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.scout", "Eclipse Scout") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "job-dsl",
      ],
    },
  },
}
