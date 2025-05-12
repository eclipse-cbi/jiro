{
  project+: {
    fullName: "ee4j.tyrus",
    displayName: "Eclipse Tyrus",
  },
  maven+: {
    showVersion: false,
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c56,c15",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
