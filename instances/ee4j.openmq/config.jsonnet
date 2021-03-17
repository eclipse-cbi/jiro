{
  project+: {
    fullName: "ee4j.openmq",
    displayName: "Eclipse OpenMQ",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
}
