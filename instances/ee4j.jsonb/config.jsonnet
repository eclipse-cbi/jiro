{
  project+: {
    fullName: "ee4j.jsonb",
    displayName: "Jakarta JSON Binding",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c44,c34",
}
