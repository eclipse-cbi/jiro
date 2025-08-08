{
  project+: {
    fullName: "tools.datatools",
    displayName: "Eclipse Data Tools Platform",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c34,c19",
}
