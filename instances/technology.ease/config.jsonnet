{
  project+: {
    fullName: "technology.ease",
    displayName: "Eclipse Advanced Scripting Environment (EASE)"
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
