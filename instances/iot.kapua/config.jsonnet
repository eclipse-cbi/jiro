{
  project+: {
    fullName: "iot.kapua",
    displayName: "Eclipse Kapua",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "htmlpublisher",
      "nodejs"
    ]
  }
}
