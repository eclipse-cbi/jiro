{
  project+: {
    fullName: "modeling.capra",
    displayName: "Eclipse Capra",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c31,c20",
}
