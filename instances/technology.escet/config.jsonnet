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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c39,c14",
}
