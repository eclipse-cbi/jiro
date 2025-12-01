{
  project+: {
    fullName: "polarsys.capella",
    displayName: "Eclipse Capella",
    resourcePacks: 2
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
  storage: {
    quota:"100Gi"
  },
  seLinuxLevel: "s0:c31,c15",
}
