{
  project+: {
    fullName: "foundation-internal.simrel",
    displayName: "Eclipse SimRel",
    unixGroupName: "callisto-dev",
  },
  jenkins+: {
    plugins+: [
      "docker-workflow",
      "build-blocker-plugin",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
