{
  project+: {
    fullName: "technology.lyo",
    displayName: "Eclipse Lyo"
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  maven+: {
    showVersion: false,
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
