{
  project+: {
    fullName: "ee4j.parsson",
    displayName: "Eclipse Parsson",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
}
