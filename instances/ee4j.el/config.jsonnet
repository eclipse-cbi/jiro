{
  project+: {
    fullName: "ee4j.el",
    displayName: "Jakarta Expression Language"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c37,c24",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
