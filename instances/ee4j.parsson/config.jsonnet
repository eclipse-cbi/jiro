{
  project+: {
    fullName: "ee4j.parsson",
    displayName: "Eclipse Parsson",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c51,c15",
}
