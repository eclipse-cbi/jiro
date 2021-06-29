{
  project+: {
    fullName: "eclipse.jdt",
    displayName: "Eclipse Java Development Tools (JDT)",
    resourcePacks: 2,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
