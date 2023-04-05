{
  project+: {
    fullName: "automotive.kuksa",
    displayName: "Eclipse Kuksa",
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "cobertura",
      "embeddable-build-status",
      "xunit",
    ],
  },
}
