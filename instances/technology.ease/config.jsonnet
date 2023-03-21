{
  project+: {
    fullName: "technology.ease",
    displayName: "Eclipse Advanced Scripting Environment (EASE)"
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "blueocean",
      "code-coverage-api",
      "copyartifact",
      "embeddable-build-status",
    ],
  },
}
