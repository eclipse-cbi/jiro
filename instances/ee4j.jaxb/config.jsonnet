{
  project+: {
    fullName: "ee4j.jaxb",
    displayName: "Jakarta XML Binding",
  },
  jenkins+: {
    plugins+: [
      "envinject",
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c43,c17",
}
