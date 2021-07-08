{
  project+: {
    fullName: "iot.kapua",
    displayName: "Eclipse Kapua",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "htmlpublisher",
      "nodejs"
    ]
  }
}
