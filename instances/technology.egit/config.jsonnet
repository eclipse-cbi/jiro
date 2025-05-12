{
  project+: {
    fullName: "technology.egit",
    displayName: "Eclipse EGit",
    resourcePacks: 2,
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "dashboard-view",
      "gerrit-trigger",
    ],
  },
  gerrit+: [
    { site: "gerrithub.io" }
  ],
  seLinuxLevel: "s0:c37,c14",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
