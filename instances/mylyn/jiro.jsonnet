local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("mylyn", "Eclipse Mylyn") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "xunit",
        "warnings-ng",
      ]
    }
  },
}
