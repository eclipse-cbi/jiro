{
  project+: {
    fullName: "technology.oomph",
    displayName: "Eclipse Oomph",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "multiple-scms",
      "zentimestamp",
    ],
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  }
}
