{
  project+: {
    fullName: "foundation-internal.simrel",
    displayName: "Eclipse SimRel",
    unixGroupName: "technology.simrel",
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
