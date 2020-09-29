{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.235.3",
    staticAgentCount: 3,
  },
  gradle+: {
    generate: true,
  },
  deployment+: {
    cluster: "okd-c1"
  },
}