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
  seLinuxLevel: "s0:c57,c34",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
