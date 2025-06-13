{
  project+: {
    fullName: "modeling.emfcompare",
    displayName: "Eclipse EMF Compare",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c38,c22",
}
