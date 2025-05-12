{
  project+: {
    fullName: "technology.subversive",
    displayName: "Eclipse Subversive",
  },
  jenkins+: {
    plugins+: [
      "subversion",
    ],
  },
  seLinuxLevel: "s0:c55,c0",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
