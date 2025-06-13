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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c60,c40",
}
