{
  project+: {
    fullName: "tools.tm",
    displayName: "Eclipse Target Management",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
      "warnings-ng",
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c55,c45",
}
