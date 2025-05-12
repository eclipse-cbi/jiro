{
  project+: {
    fullName: "iot.keypop",
    displayName: "Eclipse Keypop",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ],
  },
  gradle+: {
    generate: true,
  },
  seLinuxLevel: "s0:c60,c40",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
