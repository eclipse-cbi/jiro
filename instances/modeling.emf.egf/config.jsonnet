{
  project+: {
    fullName: "modeling.emf.egf",
    displayName: "Eclipse Generation Factories"
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
