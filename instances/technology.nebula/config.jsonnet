{
  project+: {
    fullName: "technology.nebula",
    displayName: "Eclipse Nebula",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
    ],
  },
}
