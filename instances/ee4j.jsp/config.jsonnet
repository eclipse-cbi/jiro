{
  project+: {
    fullName: "ee4j.jsp",
    displayName: "Jakarta Server Pages",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c45,c0",
}
