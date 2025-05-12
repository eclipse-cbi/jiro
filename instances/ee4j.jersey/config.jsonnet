{
  project+: {
    fullName: "ee4j.jersey",
    displayName: "Eclipse Jersey",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c44,c4",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
