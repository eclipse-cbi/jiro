{
  project+: {
    fullName: "eclipse.pde",
    displayName: "Eclipse Plugin Development Environment (PDE)",
    resourcePacks: 3,
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "git-forensics",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c51,c25",
}
