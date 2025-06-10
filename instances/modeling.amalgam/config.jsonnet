{
  project+: {
    fullName: "modeling.amalgam",
    displayName: "Eclipse Amalgamation"
  },
  jenkins+: {
    plugins+: [
      "zentimestamp",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c29,c4",
}
