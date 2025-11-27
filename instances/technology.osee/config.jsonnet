{
  project+: {
    fullName: "technology.osee",
    displayName: "Eclipse OSEE"
  },
  jenkins+: {
    plugins+: [
      "nodejs",
    ],
  },
  storage: {
    quota:"100Gi",
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c50,c35",
}
