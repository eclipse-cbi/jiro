{
  project+: {
    fullName: "ee4j.yasson",
    displayName: "Eclipse Yasson",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c57,c54",
}
