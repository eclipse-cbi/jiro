{
  project+: {
    fullName: "tools.tracecompass",
    displayName: "Eclipse Trace Compass",
    resourcePacks: 2
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  }
}
