{
  project+: {
    fullName: "ee4j.jakartaconfig",
    displayName: "Jakarta Config",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c56,c35",
}
