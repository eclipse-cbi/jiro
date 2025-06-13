{
  project+: {
    fullName: "automotive.mosaic",
    displayName: "Eclipse Mosaic",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c48,c32",
}
