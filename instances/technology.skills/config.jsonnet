{
  project+: {
    fullName: "technology.skills",
    displayName: "Eclipse Skills",
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
