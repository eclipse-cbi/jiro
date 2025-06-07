{
  project+: {
    fullName: "ee4j.mail",
    displayName: "Jakarta Mail",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c47,c29",
}
