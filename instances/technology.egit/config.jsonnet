{
  project+: {
    fullName: "technology.egit",
    displayName: "Eclipse EGit",
    resourcePacks: 2,
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "dashboard-view",
    ],
  }
}
