{
  project+: {
    fullName: "ee4j.jsp",
    displayName: "Jakarta Server Pages",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c45,c0",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
