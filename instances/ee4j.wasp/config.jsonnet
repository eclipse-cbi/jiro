{
  project+: {
    fullName: "ee4j.wasp",
    displayName: "Eclipse WaSP",
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c56,c55",
}
