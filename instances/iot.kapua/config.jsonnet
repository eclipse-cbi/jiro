{
  project+: {
    fullName: "iot.kapua",
    displayName: "Eclipse Kapua",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "htmlpublisher",
    ]
  }
}
