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
  seLinuxLevel: "s0:c29,c4",
}
