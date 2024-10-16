{
  project+: {
    fullName: "modeling.emft.emfatic",
    displayName: "Eclipse Emfatic",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c38,c12",
}
