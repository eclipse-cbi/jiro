{
  project+: {
    fullName: "technology.tea",
    displayName: "Eclipse TEA"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c55,c10",
}
