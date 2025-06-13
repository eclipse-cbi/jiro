{
  project+: {
    fullName: "ee4j.tyrus",
    displayName: "Eclipse Tyrus",
  },
  maven+: {
    showVersion: false,
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c56,c15",
}
