{
  project+: {
    fullName: "technology.birt",
    displayName: "Eclipse Business Intelligence and Reporting Tools (BIRT)",
  },
  jenkins+: {
    plugins+: [
      "extended-choice-parameter",
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c30,c20",
}
