local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.jgit",
    shortName: "jgit",
    displayName: "Eclipse JGit",
    sponsorshipLevel: "S1",
    resourcePacks: 2,
  },
  jenkins+: {
    theme: "quicksilver-light",
    staticAgentCount: 1,
  }
}
