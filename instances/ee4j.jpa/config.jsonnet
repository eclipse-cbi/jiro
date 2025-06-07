{
  project+: {
    fullName: "ee4j.jpa",
    displayName: "Jakarta Persistence",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c44,c29",
}
