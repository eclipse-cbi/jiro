{
  project+: {
    fullName: "modeling.amalgam",
    displayName: "Eclipse Amalgamation"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "zentimestamp",
    ],
  },
}
