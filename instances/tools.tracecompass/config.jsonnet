{
  project+: {
    fullName: "tools.tracecompass",
    displayName: "Eclipse Trace Compass",
    resourcePacks: 2
  },
  jenkins+: {
    version: "2.414.1",
    plugins+: [
      "gerrit-trigger"
    ]
  }
}
