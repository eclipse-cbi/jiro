local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("eclipse.jdt.ls", "Eclipse JDT Language Server") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "build-timestamp",
        "copyartifact",
        "envinject",
        "issue-link",
        "mattermost",
      ],
    },
  },
}