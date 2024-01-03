{
  project+: {
    fullName: "technology.simrel",
    displayName: "Eclipse SimRel",
  },
  jenkins+: {
    plugins+: [
      "build-blocker-plugin",
      "docker-workflow",
      "mail-watcher-plugin",
      "date-parameter",
    ],
  },
}
