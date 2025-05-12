{
  project+: {
    fullName: "technology.escet",
    displayName: "Eclipse ESCET",
    resourcePacks: 2,
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ],
  },
  develocity+: {
    generate: true,
  },
  seLinuxLevel: "s0:c39,c14",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
