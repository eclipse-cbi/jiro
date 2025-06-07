{
  project+: {
    fullName: "ee4j.jaxws",
    displayName: "Jakarta XML Web Services",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "envinject",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c43,c27",
}
