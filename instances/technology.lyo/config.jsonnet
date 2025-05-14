{
  project+: {
    fullName: "technology.lyo",
    displayName: "Eclipse Lyo"
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  maven+: {
    showVersion: false,
  },
  seLinuxLevel: "s0:c47,c19",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
