{
  project+: {
    fullName: "iot.tahu",
    displayName: "Eclipse Tahu",
  },
  jenkins+: {
    plugins+: [
      "maven-plugin",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c58,c32",
}
