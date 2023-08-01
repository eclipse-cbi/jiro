{
  project+: {
    fullName: "modeling.emf.egf",
    displayName: "Eclipse Generation Factories"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "jacoco",
    ],
  },
}
