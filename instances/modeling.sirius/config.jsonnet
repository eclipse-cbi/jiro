{
  project+: {
    fullName: "modeling.sirius",
    displayName: "Eclipse Sirius",
    resourcePacks: 2,
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "zentimestamp",
    ],
  },
}
