{
  project+: {
    fullName: "technology.usssdk",
    displayName: "Eclipse User Storage Service SDK",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c56,c35",
}
