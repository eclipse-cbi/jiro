{
  project+: {
    fullName: "modeling.emf.egf",
    displayName: "Eclipse Generation Factories"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  seLinuxLevel: "s0:c37,c9",
}
