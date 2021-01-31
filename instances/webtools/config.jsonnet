{
  project+: {
    fullName: "webtools",
    displayName: "Eclipse Web Tools Platform Project",
  },
  jenkins+: {
    plugins+: [
      "ansicolor",
      "dashboard-view",
      "description-setter",
      "log-parser",
      "show-build-parameters",
    ],
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  }
}
