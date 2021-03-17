{
  project+: {
    fullName: "ee4j.metro",
    displayName: "Eclipse Metro",
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
