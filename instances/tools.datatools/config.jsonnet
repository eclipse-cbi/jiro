{
  project+: {
    fullName: "tools.datatools",
    displayName: "Eclipse Data Tools Platform",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
    ],
  },
  seLinuxLevel: "s0:c34,c19",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
