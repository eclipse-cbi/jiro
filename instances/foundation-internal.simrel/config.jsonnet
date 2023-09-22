{
  project+: {
    fullName: "foundation-internal.simrel",
    displayName: "Eclipse SimRel",
    unixGroupName: "callisto-dev",
  },
  jenkins+: {
    version: "2.414.2",
    plugins+: [
      "build-blocker-plugin",
      "docker-workflow",
      "mail-watcher-plugin",
      "date-parameter",
    ],
  },
}
