{
  project+: {
    fullName: "ee4j.jaxb-impl",
    displayName: "Eclipse Implementation of JAXB",
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
  seLinuxLevel: "s0:c43,c12",
}
