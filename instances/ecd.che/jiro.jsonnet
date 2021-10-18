local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ecd.che", "Eclipse Che") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "job-dsl",
        "purge-build-queue-plugin",
      ],
    },
  },
}
