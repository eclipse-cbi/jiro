{
  project+: {
    fullName: "polarsys.capella",
    displayName: "Eclipse Capella",
    resourcePacks: 2
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "description-setter",
      "jacoco",
      "performance",
      "pipeline-github",
      "pipeline-utility-steps",
    ],
  },
}
