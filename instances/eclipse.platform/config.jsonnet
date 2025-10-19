{
  project+: {
    fullName: "eclipse.platform",
    displayName: "Eclipse Platform",
    resourcePacks: 4,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
      "pipeline-github",
    ],
  },
  seLinuxLevel: "s0:c51,c35",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
