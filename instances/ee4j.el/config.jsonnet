{
  project+: {
    fullName: "ee4j.el",
    displayName: "Jakarta Expression Language"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c37,c24",
}
