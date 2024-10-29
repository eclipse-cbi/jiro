{
  project+: {
    fullName: "technology.packaging.mpc",
    displayName: "Eclipse Marketplace Client",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c48,c37",
}
