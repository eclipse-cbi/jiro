{
  project+: {
    fullName: "mylyn",
    displayName: "Eclipse Mylyn",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "xunit",
      "warnings-ng",
    ]
  }
}
