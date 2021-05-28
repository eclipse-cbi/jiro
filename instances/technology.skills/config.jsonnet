{
  project+: {
    fullName: "technology.skills",
    displayName: "Eclipse Skills",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "blueocean",
      "code-coverage-api",
      "copyartifact",
      "embeddable-build-status",
    ],
  },
}
