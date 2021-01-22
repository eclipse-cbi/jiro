{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.263.2",
    staticAgentCount: 3,
  },
  gradle+: {
    generate: true,
  },
  deployment+: {
    cluster: "okd-c1"
  },
}