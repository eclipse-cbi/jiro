{
  project+: {
    fullName: "foundation-internal.simrel",
    displayName: "Eclipse SimRel",
    unixGroupName: "callisto-dev",
  },
  jenkins+: {
    plugins+: [
      "docker-workflow",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
