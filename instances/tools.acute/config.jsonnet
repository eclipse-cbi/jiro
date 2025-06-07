{
  project+: {
    fullName: "tools.acute",
    displayName: "Eclipse aCute"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c28,c17",
}
