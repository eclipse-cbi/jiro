local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mdt.etrice", "Eclipse eTrice") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "gradle",
        "postbuild-task",
      ],
    },
    gradle+: {
      generate: true,
    }
  }
}
