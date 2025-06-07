{
  project+: {
    fullName: "ee4j.jaf",
    displayName: "Jakarta Activation",
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
  seLinuxLevel: "s0:c42,c24",
}
