local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.jgit", "Eclipse JGit") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      theme: "quicksilver-light",
      staticAgentCount: 1,
      plugins+: [
        "dashboard-view",
        "git-forensics",
        "gradle",
      ],
    },
    gradle+: {
      generate: true,
    },
  },
}
