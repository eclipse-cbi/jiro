{
  project+: {
    fullName: "modeling.ecp",
    displayName: "Eclipse EMF Client Platform",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c36,c10",
}
