local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ecd.emfcloud", "Eclipse EMF.cloud") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "github-checks",
      ],
    },
  },
}