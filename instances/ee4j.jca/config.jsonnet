{
  project+: {
    fullName: "ee4j.jca",
    displayName: "Jakarta Connectors",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c43,c32",
}
