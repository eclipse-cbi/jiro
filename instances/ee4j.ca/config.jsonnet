{
  project+: {
    fullName: "ee4j.ca",
    displayName: "Jakarta Annotations"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c31,c5",
}
