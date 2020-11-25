{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.249.3-jdk11",
    staticAgentCount: 3,
  },
  gradle+: {
    generate: true,
  },
  deployment+: {
    cluster: "okd-c1"
  },
}