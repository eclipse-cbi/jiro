{
  project+: {
    fullName: "iot.4diac",
    displayName: "Eclipse 4diac",
  },
  jenkins+: {
    plugins+: [
      "cmakebuilder",
      "copyartifact",
      "embeddable-build-status",
    ],
  },
  seLinuxLevel: "s0:c28,c7",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
