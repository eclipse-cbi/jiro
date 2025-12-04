{
  project+: {
    fullName: "modeling.egf",
    displayName: "Eclipse Generation Factories"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c37,c9",
}
