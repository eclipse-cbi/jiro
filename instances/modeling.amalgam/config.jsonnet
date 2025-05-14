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
  seLinuxLevel: "s0:c29,c4",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
