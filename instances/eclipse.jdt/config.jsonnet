{
  project+: {
    fullName: "eclipse.jdt",
    displayName: "Eclipse Java Development Tools (JDT)",
    resourcePacks: 3,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
  seLinuxLevel: "s0:c43,c37",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
