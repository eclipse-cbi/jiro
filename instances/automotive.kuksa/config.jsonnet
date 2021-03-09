{
  project+: {
    fullName: "automotive.kuksa",
    displayName: "Eclipse Kuksa",
  },
  jenkins+: {
    plugins+: [
      "xunit",
      "embeddable-build-status",
      "cobertura",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
