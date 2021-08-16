{
  project+: {
    fullName: "technology.jgit",
    displayName: "Eclipse JGit",
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
}
