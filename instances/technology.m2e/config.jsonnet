{
  project+: {
    fullName: "technology.m2e",
    displayName: "Eclipse Maven Integration",
    resourcePacks: 2,
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "git-forensics",
    ],
  },
  seLinuxLevel: "s0:c47,c24",
}
