{
  project+: {
    fullName: "tools.mat",
    displayName: "Eclipse Memory Analyzer",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c47,c34",
}
