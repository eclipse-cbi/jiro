{
  project+: {
    fullName: "foundation-internal.simrel",
    displayName: "Eclipse SimRel",
    unixGroupName: "callisto-dev",
  },
  jenkins+: {
    plugins+: [
      "build-blocker-plugin",
      "docker-workflow",
      "mail-watcher-plugin",
    ],
  },
}
