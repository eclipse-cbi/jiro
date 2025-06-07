{
  project+: {
    fullName: "technology.nebula",
    displayName: "Eclipse Nebula",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c49,c19",
}
