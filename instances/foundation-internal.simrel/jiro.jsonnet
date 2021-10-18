local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("foundation-internal.simrel", "Eclipse SimRel") {
  "config.json"+: {
    project+: {
      unixGroupName: "callisto-dev",
    },
    jenkins+: {
      plugins+: [
        "build-blocker-plugin",
        "docker-workflow",
        "mail-watcher-plugin",
        "date-parameter",
      ],
    },
  }
}
