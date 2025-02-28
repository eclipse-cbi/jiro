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
  },
  seLinuxLevel: "s0:c45,c30",
}
