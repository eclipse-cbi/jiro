{
  project+: {
    fullName: "modeling.emft.henshin",
    displayName: "Eclipse Henshin"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c41,c35",
}
