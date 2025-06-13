{
  project+: {
    fullName: "ecd.emfcloud",
    displayName: "Eclipse EMF.cloud",
  },
  jenkins+: {
    plugins+: [
      "github-checks",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c38,c17",
}
