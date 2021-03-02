{
  project+: {
    fullName: "modeling.ecp",
    displayName: "Eclipse EMF Client Platform",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
}
