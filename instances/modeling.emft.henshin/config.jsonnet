{
  project+: {
    fullName: "modeling.emft.henshin",
    displayName: "Eclipse Henshin"
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "git-forensics",
    ],
  },
  seLinuxLevel: "s0:c41,c35",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
