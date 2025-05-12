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
      "ansicolor",
      "dashboard-view",
      "gerrit-trigger",
      "git-forensics",
      "gradle",
    ],
  },
  gradle+: {
    generate: true,
  },
  gerrit+: [
    { site: "gerrithub.io" }
  ],
  seLinuxLevel: "s0:c44,c14",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
