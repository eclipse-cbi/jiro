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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c46,c30",
}
