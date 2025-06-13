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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c47,c19",
}
