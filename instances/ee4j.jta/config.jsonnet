{
  project+: {
    fullName: "ee4j.jta",
    displayName: "Jakarta Transactions",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c45,c10",
}
