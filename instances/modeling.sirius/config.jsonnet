{
  project+: {
    fullName: "modeling.sirius",
    displayName: "Eclipse Sirius",
    resourcePacks: 2,
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "zentimestamp",
    ],
  },
}
