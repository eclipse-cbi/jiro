{
  project+: {
    fullName: "automotive.kuksa",
    displayName: "Eclipse Kuksa",
  },
  jenkins+: {
    plugins+: [
      "cobertura",
      "embeddable-build-status",
      "mail-watcher-plugin",
      "xunit",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
