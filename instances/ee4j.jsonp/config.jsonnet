{
  project+: {
    fullName: "ee4j.jsonp",
    displayName: "Jakarta JSON Processing",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c44,c39",
}
