{
  project+: {
    fullName: "mylyn",
    displayName: "Eclipse Mylyn",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "xunit",
      "warnings-ng",
    ]
  }
}
