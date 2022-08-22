{
  project+: {
    fullName: "tools.cdt",
    displayName: "Eclipse CDT",
    resourcePacks: 4,
  },
  jenkins+: {
    plugins+: [
      "nodejs",
      "throttle-concurrents",
      "javadoc",
      "pipeline-github",
    ],
  },
}
