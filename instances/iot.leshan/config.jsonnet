{
  project+: {
    fullName: "iot.leshan",
    displayName: "Eclipse Leshan",
  },
  jenkins+: {
    plugins+: [
      "declarative-pipeline-migration-assistant",
    ],
  },
  seLinuxLevel: "s0:c46,c30",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
