{
  project+: {
    fullName: "ee4j.jersey",
    displayName: "Eclipse Jersey",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c44,c4",
}
