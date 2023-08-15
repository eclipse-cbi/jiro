{
  project+: {
    fullName: "ee4j.glassfish",
    displayName: "Eclipse Glassfish",
    resourcePacks: 17
  },
  jenkins+: {
    agentConnectionTimeout: 300,
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact",
      "view-job-filters",
    ],
  }
}
