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
  }
}
