{
  project+: {
    fullName: "modeling.xpect",
    displayName: "Eclipse Xpect",
  },
  jenkins+: {
    plugins+: [
      "matrix-communication",
      "parameterized-scheduler",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c57,c34",
}
