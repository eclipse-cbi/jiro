{
  project+: {
    fullName: "ee4j.cu",
    displayName: "Jakarta Concurrency"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c34,c4",
}
