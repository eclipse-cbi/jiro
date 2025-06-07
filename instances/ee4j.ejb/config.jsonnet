{
  project+: {
    fullName: "ee4j.ejb",
    displayName: "Jakarta Enterprise Beans"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c37,c19",
}
