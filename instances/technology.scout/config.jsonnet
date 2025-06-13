{
  project+: {
    fullName: "technology.scout",
    displayName: "Eclipse Scout",
  },
  jenkins+: {
    plugins+: [
      "job-dsl",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c52,c49",
}
