{
  project+: {
    fullName: "technology.handly",
    displayName: "Eclipse Handly",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c41,c20",
}
