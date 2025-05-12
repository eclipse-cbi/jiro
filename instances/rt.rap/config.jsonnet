{
  project+: {
    fullName: "rt.rap",
    displayName: "Eclipse RAP",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c52,c9",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
