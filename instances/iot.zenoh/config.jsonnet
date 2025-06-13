{
  project+: {
    fullName: "iot.zenoh",
    displayName: "Eclipse zenoh",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c58,c2",
}
